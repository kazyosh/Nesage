//
//  NEWebView.m
//  Nesage
//
// Copyright (c) 2016 kazyosh
//
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import "NEWebView.h"
#import "MMMarkdown/MMMarkdown.h"

@interface NEWebView() <WebFrameLoadDelegate>
{
    CGPoint _savedPosition;
}

@end
@implementation NEWebView
- (void)awakeFromNib {
    [self registerForDraggedTypes:@[NSPasteboardURLReadingFileURLsOnlyKey]];
    self.frameLoadDelegate = self;
}

-(void)loadMarkdown:(NSURL *)url {
    self.markdownUrl = url;
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *markdown   = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:markdown
                                                   extensions:MMMarkdownExtensionsGitHubFlavored
                                                        error:NULL];
    [self.mainFrame loadHTMLString:htmlString baseURL:url];
}

- (void)reload
{
    if (self.markdownUrl) {
        [self rememberScrollPosition];
        [self loadMarkdown:self.markdownUrl];
    }
    else {
        [super reload:nil];
    }
}

-(NSData *)dataWithFileExtension:(NSString *)extension
{
    if ([extension isEqualToString:@"html"]) {
        NSString *html = [self stringHtml];
        return [NSData dataWithBytes:[html UTF8String] length:[html length]];
    }
    else {
        return nil;
    }
}

-(NSData *)dataAsHtml
{
    NSString *html = [self stringHtml];
    return [NSData dataWithBytes:[html UTF8String] length:[html length]];
}

- (NSString *)stringHtml {
    NSString *innerHTML = [self stringByEvaluatingJavaScriptFromString:
                      @"document.all[0].innerHTML"];
    NSMutableString *result = [NSMutableString stringWithFormat:@"<!DOCTYPE html>"];
    [result appendString:@"<html>"];
    [result appendString:innerHTML];
    [result appendString:@"</html>"];
    return result;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard* board = [sender draggingPasteboard];
    NSArray* files = [board propertyListForType:NSFilenamesPboardType];
    if ([files count]) {
        NSURL *url = [NSURL fileURLWithPath:[files objectAtIndex:0]];
        if (self.delegate) {
            if([self.delegate newebView:self concludeDroppedFile:url]) {
                [self loadMarkdown:url];
                [self.delegate newebView:self contentLoaded:url];
            }
        }
    }
}

- (void)rememberScrollPosition {
    NSScrollView* sv = self.mainFrame.frameView.documentView.enclosingScrollView;
    if (sv) {
        NSRect currentRect = [sv documentVisibleRect];
        if (currentRect.origin.y > 0) {
            _savedPosition = currentRect.origin;
        }
    }else{
        _savedPosition = NSZeroPoint;
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    CGFloat savedY = _savedPosition.y;
    if (frame == self.mainFrame && savedY > 0) {
        [self.mainFrame.frameView.documentView scrollPoint:_savedPosition];
        _savedPosition = NSZeroPoint;
    }
}
@end
