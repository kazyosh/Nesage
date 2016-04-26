//
//  NEWebView.h
//  Nesage
//
// Copyright (c) 2016 kazyosh
//
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class NEWebView;
@protocol NEWebViewDelegate <NSObject>

- (BOOL)newebView:(NEWebView *)newebView concludeDroppedFile:(NSURL *)url;

@end

@interface NEWebView : WebView <NSDraggingDestination>
@property (assign) id<NEWebViewDelegate> delegate;

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)URL;
@end
