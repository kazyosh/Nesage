//
//  HighlightJs.h
//  Nesage
//
//  Created by Kazuhiro YOSHIDA on 2018/02/16.
//  Copyright © 2018年 ProSoftware,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HighlightJsWrapper : NSObject
+ (HighlightJsWrapper *)sharedInstance;
- (NSString *)hilight:(NSString *)code language:(NSString *)lang;
@end
