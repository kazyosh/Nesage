//
//  HighlightJs.h
//  Nesage
//
// Copyright (c) 2018 kazyosh
//
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface HighlightJsWrapper : NSObject
+ (HighlightJsWrapper *)sharedInstance;
- (NSString *)hilight:(NSString *)code language:(NSString *)lang;
@end
