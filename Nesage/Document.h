//
//  Document.h
//  Nesage
//
// Copyright (c) 2016 kazyosh
//
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument
@property (copy) NSData *markdownData;
@property (readonly, copy) NSString *htmlString;
@property (copy) NSURL *exportURL;

- (void)exportAsHtml:(NSURL *)exportURL;
- (void)exportAsPdf:(NSView *)view exportURL:(NSURL *)exportURL;
@end

