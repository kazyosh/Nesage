//
//  Meboshi.m
//  Nebiki
//
// Copyright (c) 2018 kazyosh
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import "SoldoutWrapper.h"

#import "Meboshi.h"

@implementation Meboshi

+ (NSArray<NSString *> *)markdownStyles {
    NSMutableArray<NSString *> *result = [[NSMutableArray alloc] init];
    [result addObject:@"github"];
    return result;
}

+ (NSArray<NSString *> *)codeHilightStyles {
    NSMutableArray<NSString *> *result = [[NSMutableArray alloc] init];
    [result addObject:@"github"];
    return result;
}

+ (NSString *)toHtmlWithTitle:(NSString *)title
                         data:(NSData *)data
                markdownStyle:(NSString *)markdownStyle
             codeHilightStyle:(NSString *)codeStyle {
    return [Meboshi toHtmlWithTitle:title data:data
                                css:[Meboshi markdownCss:markdownStyle]
                            codeCss:[Meboshi codeCss:codeStyle]];
}

+ (NSString *)toHtmlWithTitle:(NSString *)title data:(NSData *)data css:(NSString *)css codeCss:(NSString *)codeCss {
    NSString *soldouted = [SoldoutWrapper htmlWithData:data];
    NSLog(@"%@", soldouted);
    NSString *htmlDocType = @"<!DOCTYPE html>\n";
    NSString *htmlHeadStart = [NSString stringWithFormat:@"<html><head>\n<meta charset=\"UTF-8\">\n<title>%@</title>\n", title];
    NSString *htmlStyle = [NSString stringWithFormat:@"<style type=\"text/css\">%@</style>\n<style type=\"text/css\">%@</style>\n", css, codeCss];
    NSString *htmlHeadEnd = @"</head>\n";
    NSString *htmlBody = [NSString stringWithFormat:@"<body>\n%@</body></html>", soldouted];
    return [NSString stringWithFormat:@"%@%@%@%@%@", htmlDocType, htmlHeadStart, htmlStyle, htmlHeadEnd, htmlBody];
}

+ (NSString *)markdownCss:(NSString *)styleName {
//    NSString *resource = [NSString stringWithFormat:@"styles/%@", styleName];
    NSString *path = [[NSBundle mainBundle] pathForResource:styleName
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

+ (NSString *)codeCss:(NSString *)styleName {
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
