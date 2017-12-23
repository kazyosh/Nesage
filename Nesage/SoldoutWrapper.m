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

@implementation SoldoutWrapper
+ (NSString *)htmlWithData:(NSData *)data {
    struct buf *ib;
    ib = bufnew([data length]);
    bufput(ib, [data bytes], [data length]);
    struct buf *ob = bufnew(OUTPUT_UNIT);
    markdown(ob, ib, &nat_html);
    return [NSString stringWithCString:ob->data encoding:NSUTF8StringEncoding];
}
@end
