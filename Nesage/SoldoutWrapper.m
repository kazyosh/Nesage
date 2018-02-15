//
//  SoldoutWrapper.m
//  Nesage
//
// Copyright (c) 2017 kazyosh
//
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#include "markdown.h"
#include "renderers.h"
#include "buffer.h"

#import "SoldoutWrapper.h"

#define OUTPUT_UNIT 64

void tildeblockcode(char* lang, struct buf *ob, struct buf *text, void *opaque) {
    NSUInteger len = text->size;
    NSString *langString = [NSString string];
    if (lang) {
        int ii = 0;
        while (lang[ii] != '\n') {
            langString = [langString stringByAppendingFormat:@"%c", lang[ii]];
            ii++;
        }
    }
    NSString *string = [[NSString alloc] initWithBytes:text->data length:len encoding:NSUTF8StringEncoding];
    NSLog(@"%@", string);
    discount_html.blockcode(ob, text, opaque);
    len = text->size;
    string = [[NSString alloc] initWithBytes:text->data length:len encoding:NSUTF8StringEncoding];
    NSLog(@"%@", string);
}

@implementation SoldoutWrapper
+ (NSString *)htmlWithData:(NSData *)data {
    struct buf *ib;
    ib = bufnew([data length]);
    bufput(ib, [data bytes], [data length]);
    struct buf *ob = bufnew(OUTPUT_UNIT);
    struct mkd_renderer renderer = discount_html;
    renderer.tildeblockcode = tildeblockcode;
    markdown(ob, ib, &renderer);
    return [NSString stringWithCString:ob->data encoding:NSUTF8StringEncoding];
}

@end
