//
//  ViewController.m
//  Nesage
//
// Copyright (c) 2016 kazyosh
//
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//
#import <WebKit/WebKit.h>

#import "NEWebView.h"
#import "SavePanelAccessoryView.h"

#import "ViewController.h"

@interface ViewController()<NSDraggingDestination, NSComboBoxDataSource, NSComboBoxDelegate, NEWebViewDelegate>

@property (weak) IBOutlet NEWebView *webView;
@property (copy) NSURL* sourcePath;
@property (copy) NSURL* savedPath;
@property FSEventStreamRef fseventStream;
@property (strong) NSSavePanel *savePanel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
    [self loadInitialHtml];
}

- (void)loadInitialHtml {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index"
                                                     ofType:@"html"];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView.mainFrame loadRequest:request];
}

#pragma mark - Menu Actions
- (void)openDocument:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.resolvesAliases = YES;
    panel.allowedFileTypes = @[@"md"];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        NSArray* urls = [panel URLs];
        self.sourcePath = [urls objectAtIndex:0];
        [self.webView loadMarkdown:self.sourcePath];
    };
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (void)startFileUpdateOvserving
{
    CFStringRef mypath = (__bridge CFStringRef)([self.sourcePath path]);
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
    FSEventStreamContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFAbsoluteTime latency = 3.0; /* Latency in seconds */
    
    /* Create the stream, passing in a callback */
    self.fseventStream = FSEventStreamCreate(NULL,
                                             &fseventCallbak,
                                             &context,
                                             pathsToWatch,
                                             kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                             latency,
                                             kFSEventStreamCreateFlagFileEvents /* Flags explained in reference */
                                             );
    FSEventStreamScheduleWithRunLoop(self.fseventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(self.fseventStream);
}

void fseventCallbak(
                    ConstFSEventStreamRef streamRef,
                    void *clientCallBackInfo,
                    size_t numEvents,
                    void *eventPaths,
                    const FSEventStreamEventFlags eventFlags[],
                    const FSEventStreamEventId eventIds[])
{
    int i;
    char **paths = eventPaths;
    
    // printf("Callback called\n");
    for (i=0; i<numEvents; i++) {
        /* flags are unsigned long, IDs are uint64_t */
        printf("Change %llu in %s, flags %u\n", eventIds[i], paths[i], (unsigned int)eventFlags[i]);
    }
    
    ViewController *vc = (__bridge ViewController *)clientCallBackInfo;
    [vc.webView reload];
}

- (void)performClose:(id)sender {
    if (self.fseventStream) {
        FSEventStreamStop(self.fseventStream);
        FSEventStreamInvalidate(self.fseventStream);
        FSEventStreamRelease(self.fseventStream);
        self.fseventStream = NULL;
    }
    [self loadInitialHtml];
}

- (void)exportDocument:(id)sender {
    if (self.savePanel == nil) {
        self.savePanel = [NSSavePanel savePanel];
        self.savePanel.allowedFileTypes = @[@"html", @"HTML", @"pdf", @"PDF"];
        self.savePanel.extensionHidden = NO;
        SavePanelAccessoryView *accessoryView = [[SavePanelAccessoryView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 380.0, 60.0)];
        accessoryView.fileFormat.delegate = self;
        self.savePanel.accessoryView = accessoryView;
    }
    else {
        NSString *pathExtension = [self.savePanel.nameFieldStringValue pathExtension];
        if ([pathExtension length]) {
            SavePanelAccessoryView *accessoryView = (SavePanelAccessoryView *)self.savePanel.accessoryView;
            [accessoryView.fileFormat selectItemWithObjectValue:pathExtension];
        }
    }
    
    if ([self.savePanel runModal] == NSFileHandlingPanelOKButton) {
        NSURL *savePath = [self.savePanel URL];
        if ([[savePath pathExtension] isEqualToString:@"pdf"]) {
            [self saveAsPdf:savePath];
        }
        else {
            [self saveAsHtml:savePath];
        }
    };
}

- (void)saveAsHtml:(NSURL *)savePath
{
    NSString *html = self.webView.stringHtml;
    if ([html writeToURL:savePath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        self.savedPath = savePath;
    }
}

- (void)saveAsPdf:(NSURL *)savePath
{
    NSMutableDictionary* pd = [NSMutableDictionary
                               dictionaryWithDictionary:[[NSPrintInfo sharedPrintInfo] dictionary]];
    [pd setObject:NSPrintSaveJob forKey:NSPrintJobDisposition];
    [pd setObject:savePath forKey:NSPrintJobSavingURL];
    
    NSPrintInfo* pi = [[NSPrintInfo alloc] initWithDictionary:pd];
    [pi setHorizontalPagination:NSAutoPagination];
    [pi setVerticalPagination:NSAutoPagination];
    [pi setVerticallyCentered:NO];
    
    NSPrintOperation* po = [NSPrintOperation printOperationWithView:self.webView.mainFrame.frameView.documentView
                                                          printInfo:pi];
    [po setShowsPrintPanel:NO];
    [po setShowsProgressPanel:NO];
    
    if ([po runOperation]) {
        self.savedPath = savePath;
    }
}

#pragma mark - NEWebViewDelegate
- (BOOL)newebView:(NEWebView *)newebView concludeDroppedFile:(NSURL *)url
{
    return YES;
}

- (void)newebView:(NEWebView *)newebView contentLoaded:(NSURL *)url
{
    self.sourcePath = url;
    self.view.window.title = [self.sourcePath lastPathComponent];
    [self startFileUpdateOvserving];
}

#pragma mark - webView delegates
- (WebView *) webView:(WebView *) sender createWebViewWithRequest:(NSURLRequest *) request
{
    NSURL *url = [[request URL] absoluteURL];
    [[NSWorkspace sharedWorkspace] openURL:url];
    return NULL;
}

- (void) webView:(WebView *)sender
decidePolicyForNewWindowAction:(NSDictionary *)actionInformation
         request:(NSURLRequest *)request newFrameName:(NSString *)frameName
decisionListener:(id)listener
{
    NSURL *url = [[request URL] absoluteURL];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request
          frame:(WebFrame *)frame
decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSInteger navigationType = [[actionInformation objectForKey:WebActionNavigationTypeKey] integerValue];
    if (navigationType == WebNavigationTypeLinkClicked) {
        NSURL *url = [[request URL] absoluteURL];
        [[NSWorkspace sharedWorkspace] openURL:url];
        [listener ignore];
    }
    else if (navigationType == WebNavigationTypeReload) {
        [self.webView reload];
        [listener ignore];
    }
    else {
        [listener use];
    }
}

#pragma mark - NSComboBoxDelegate
- (void)comboBoxSelectionDidChange:(NSNotification *)notification;
{
    if (notification.object) {
        NSComboBox *cb = notification.object;
        NSString *newExtension = [cb itemObjectValueAtIndex:[cb indexOfSelectedItem]];
        NSString *fileName;
        if ([[self.savePanel.nameFieldStringValue pathExtension] length]) {
            fileName = [self.savePanel.nameFieldStringValue stringByDeletingPathExtension];
        }
        else {
            fileName = self.savePanel.nameFieldStringValue;
        }
        fileName = [fileName stringByAppendingPathExtension:newExtension];
        [self.savePanel setNameFieldStringValue:fileName];
        NSLog(@"%@ -> %@", self.savePanel.nameFieldStringValue, fileName);
    }
}

@end
