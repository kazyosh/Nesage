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

@interface NEWebView() <WebFrameLoadDelegate, NSDraggingDestination>
{
    CGPoint _savedPosition;
}

@end
@implementation NEWebView
- (void)awakeFromNib {
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[NSFilePromiseReceiver readableDraggedTypes]];
    [array addObject: NSURLPboardType];
    [self registerForDraggedTypes:array];
    self.frameLoadDelegate = self;
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)URL {
    if ([self.mainFrameURL length]) {
        [self rememberScrollPosition];
    }
    [self.mainFrame loadHTMLString:string baseURL:URL];
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

#pragma mark - Drag&Drop
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard* board = [sender draggingPasteboard];
    NSArray* files = [board propertyListForType:NSFilenamesPboardType];
    if ([files count]) {
        NSURL *url = [NSURL fileURLWithPath:[files objectAtIndex:0]];
        if ([[url pathExtension] isEqualToString:@"md"]) {
            return YES;
        }
    }
    return NO;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard* board = [sender draggingPasteboard];
    NSArray* files = [board propertyListForType:NSFilenamesPboardType];
    if ([files count]) {
        NSURL *url = [NSURL fileURLWithPath:[files objectAtIndex:0]];
        if (self.delegate) {
            [self.delegate newebView:self concludeDroppedFile:url];
        }
    }
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
    NSLog(@"entered");
    return NSDragOperationCopy;
    
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender{
    return NSDragOperationCopy;
    
}


- (void)draggingExited:(id <NSDraggingInfo>)sender{
    NSLog(@"exited");
    
}
@end
