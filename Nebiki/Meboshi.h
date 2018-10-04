//
//  Meboshi.h
//  Nebiki
//
// Copyright (c) 2018 kazyosh
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface Meboshi : NSObject
+ (NSArray<NSString *> *)markdownStyles;
+ (NSArray<NSString *> *)codeHilightStyles;
+ (NSString *)toHtmlWithTitle:(NSString *)title
                         data:(NSData *)data;
+ (NSString *)toHtmlWithTitle:(NSString *)title
                         data:(NSData *)data
          optionalHeaderItems:(NSArray<NSString *> *)headerItems
                markdownStyle:(NSString *)markdownStyle
             codeHilightStyle:(NSString *)codeStyle;
+ (NSString *)cssForMarkdownStyle:(NSString *)styleName;
+ (NSString *)cssForCodeHilight:(NSString *)styleName;
@end
