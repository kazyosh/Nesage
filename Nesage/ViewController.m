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

#import "Document.h"
#import "NEWebView.h"
#import "SavePanelAccessoryView.h"

#import "ViewController.h"

@interface ViewController()<NSDraggingDestination, NSComboBoxDataSource, NSComboBoxDelegate, WebPolicyDelegate, NEWebViewDelegate>

@property (weak) IBOutlet NEWebView *webView;
@property (copy) NSURL* savedPath;
@property FSEventStreamRef fseventStream;
@property (strong) NSSavePanel *savePanel;
@end

@implementation ViewController

- (Document *)document
{
    return (Document *)[[NSDocumentController sharedDocumentController] documentForWindow:[[self view] window]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
    self.webView.policyDelegate = self;
    [self loadInitialHtml];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    Document *doc = [self document];
    if (doc.fileURL) {
        NSLog(@"%@", doc.fileURL.description);
        [self.webView loadHTMLString:[self document].htmlString baseURL:[self document].fileURL];
    }
    [doc addObserver:self forKeyPath:@"markdownData" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear
{
    [[self document] removeObserver:self forKeyPath:@"markdownData"];
    [super viewWillDisappear];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"markdownData"]) {
        dispatch_async(
                       dispatch_get_main_queue(),
                       ^{
                           [self.webView loadHTMLString:[self document].htmlString baseURL:[self document].fileURL];
                       }
                       );
    }
}

- (void)loadInitialHtml {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index"
                                                     ofType:@"html"];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView.mainFrame loadRequest:request];
}

#pragma mark - Menu Actions

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
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
            [[self document] exportAsPdf:self.webView.mainFrame.frameView.documentView
                               exportURL:[self.savePanel URL]];
        }
        else {
            [[self document] exportAsHtml:[self.savePanel URL]];
        }
    };
}

#pragma mark - NEWebViewDelegate
- (BOOL)newebView:(NEWebView *)newebView concludeDroppedFile:(NSURL *)url
{
    if ([url.pathExtension isEqualToString:@"md"]) {
        [self document].fileURL = url;
        self.view.window.title = [url lastPathComponent];
        return YES;
    }
    return NO;
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
        [self.webView loadHTMLString:[self document].htmlString baseURL:[self document].fileURL];
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
