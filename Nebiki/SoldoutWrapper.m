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

#import "HighlightJsWrapper.h"
#import "SoldoutWrapper.h"

#define OUTPUT_UNIT 64

void tildeblockcode(char* lang, struct buf *ob, struct buf *text, void *opaque) {
    NSString *langString = [NSString string];
    if (lang) {
        int ii = 0;
        while (lang[ii] != '\n') {
            langString = [langString stringByAppendingFormat:@"%c", lang[ii]];
            ii++;
        }
        NSString *string = [[NSString alloc] initWithBytes:text->data length:text->size encoding:NSUTF8StringEncoding];
        NSString *highlighted = [[HighlightJsWrapper sharedInstance] hilight:string language:langString];
        if (ob->size) bufputc(ob, '\n');
        NSString *precode = [NSString stringWithFormat:@"<pre><code class=\"%@\">", langString];
        BUFPUTSL(ob, precode.UTF8String);
        bufput(ob, [highlighted UTF8String], [highlighted lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        BUFPUTSL(ob, "</code></pre>\n");
    }
    else {
        discount_html.blockcode(ob, text, opaque);
    }
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
