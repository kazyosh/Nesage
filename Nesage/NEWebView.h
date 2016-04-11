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
- (void)newebView:(NEWebView *)newebView contentLoaded:(NSURL *)url;

@end

@interface NEWebView : WebView <NSDraggingDestination>
-(void)loadMarkdown:(NSURL *)url;
-(void)reload;

-(NSData *)dataWithFileExtension:(NSString *)extension;
-(NSData *)dataAsHtml;

@property (assign) id<NEWebViewDelegate> delegate;
@property (copy, readonly) NSString *stringHtml;
@property (copy) NSURL *markdownUrl;
@end
