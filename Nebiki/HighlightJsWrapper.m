//
//  HighlightJs.m
//  Nesage
//
// Copyright (c) 2017 kazyosh
//
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "HighlightJsWrapper.h"

@interface HighlightJsWrapper()
@property JSContext *context;
@end

@implementation HighlightJsWrapper

+ (HighlightJsWrapper *)sharedInstance {
    static HighlightJsWrapper* _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HighlightJsWrapper alloc]
                     initSharedInstance];
    });
    return _instance;
}

- (id)initSharedInstance {
    self = [super init];
    if (self) {
        self.context = [[JSContext alloc] init];
        [self.context evaluateScript:@"var window = {};"];
        NSError *error;
        NSString *path = [[NSBundle bundleForClass:[HighlightJsWrapper class]] pathForResource:@"highlight.pack"
                                               ofType:@"js"];
        NSString* script = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            script = @"";
        }
        [self.context evaluateScript:script];
    }
    return self;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)hilight:(NSString *)code language:(NSString *)lang {
    NSString *fixedCode = [code stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    fixedCode = [fixedCode stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\'"];
    fixedCode = [fixedCode stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    fixedCode = [fixedCode stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\'"];
    fixedCode = [fixedCode stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *script = [NSString stringWithFormat:@"window.hljs.highlight(\"%@\",\"%@\").value;", lang, fixedCode];
    JSValue *result = [self.context evaluateScript:script];
    return [result toString];
}

@end
