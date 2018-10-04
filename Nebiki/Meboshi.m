//
//  Meboshi.m
//  Nebiki
//
// Copyright (c) 2018 kazyosh
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import <AppKit/AppKit.h>

#import "SoldoutWrapper.h"
#import "Meboshi.h"

@implementation Meboshi

+ (NSArray<NSString *> *)markdownStyles {
    NSBundle *bundle = [NSBundle bundleForClass:[Meboshi class]];
    NSArray* pathArray = [bundle pathsForResourcesOfType:@"css"
                                              inDirectory:@"markdownStyles"];
    NSMutableArray<NSString *> *result = [[NSMutableArray alloc] init];
    for (NSString *path in pathArray) {
        NSString *fileName = [path lastPathComponent];
        [result addObject:[fileName componentsSeparatedByString:@"."][0]];
    }
    return result;
}

+ (NSArray<NSString *> *)codeHilightStyles {
    NSMutableArray<NSString *> *result = [[NSMutableArray alloc] init];
    [result addObject:@"github"];
    return result;
}

+ (NSString *)toHtmlWithTitle:(NSString *)title
                         data:(NSData *)data {
    if (@available(macOS 10_14, *)) {
        if ([[NSAppearance currentAppearance].name isEqual:NSAppearanceNameDarkAqua]) {
            return [Meboshi toHtmlWithTitle:title
                                       data:data
                        optionalHeaderItems:nil
                              markdownStyle:@"solarized-dark"
                           codeHilightStyle:@"solarized-dark"];
        }
    }
    return [Meboshi toHtmlWithTitle:title
                               data:data
                optionalHeaderItems:nil
                      markdownStyle:@"github"
                   codeHilightStyle:@"github"];
}

+ (NSString *)toHtmlWithTitle:(NSString *)title
                         data:(NSData *)data
          optionalHeaderItems:(NSArray<NSString *> *)headerItems
                markdownStyle:(NSString *)markdownStyle
             codeHilightStyle:(NSString *)codeStyle {
    
    NSString *soldouted = [SoldoutWrapper htmlWithData:data];
    NSMutableString *htmlString = [[NSMutableString alloc] initWithString:@"<!DOCTYPE html>\n" ];
    [htmlString appendFormat:@"<html><head>\n<meta charset=\"UTF-8\">\n<title>%@</title>\n", title];
    if ([markdownStyle length]) {
        [htmlString appendFormat:@"<style type=\"text/css\">%@</style>\n", [Meboshi cssForMarkdownStyle:markdownStyle]];
        [htmlString appendFormat:@"<style type=\"text/css\">%@</style>\n", [Meboshi cssForMarkdownStyle:@"light-default"]];
    }
    if ([codeStyle length]) {
        [htmlString appendFormat:@"<style type=\"text/css\">%@</style>\n", [Meboshi cssForCodeHilight:codeStyle]];
    }
    if ([headerItems count]) {
        for (NSString *item in headerItems) {
            [htmlString appendString:item];
        }
    }
    [htmlString appendString:@"</head>\n"];
    [htmlString appendFormat:@"<body>\n%@</body></html>\n", soldouted];
    return htmlString;
}

+ (NSString *)cssForMarkdownStyle:(NSString *)styleName {
    NSString *resource = [NSString stringWithFormat:@"markdownStyles/%@", styleName];
    NSBundle *bundle = [NSBundle bundleForClass:[Meboshi class]];
    NSString *path = [bundle pathForResource:resource
                                      ofType:@"css"];
    NSError *error;
    NSString *result = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return @"";
    }
    else {
        return result;
    }
}

+ (NSString *)cssForCodeHilight:(NSString *)styleName {
    NSString *resource = [NSString stringWithFormat:@"styles/%@", styleName];
    NSBundle *bundle = [NSBundle bundleForClass:[Meboshi class]];
    NSString *path = [bundle pathForResource:resource
                                      ofType:@"css"];
    NSError *error;
    NSString *result = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return @"";
    }
    else {
        return result;
    }
}
@end
