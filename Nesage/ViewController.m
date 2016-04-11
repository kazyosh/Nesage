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

@end
