//
//  AFRequest+Cancel.m
//  KxrDoctor
//
//  Created by Mac on 15/10/18.
//  Copyright © 2015年 kouxiaoer. All rights reserved.
//

#import "AFRequest+Cancel.h"

@implementation AFHTTPRequestOperation (Cancel)

- (void)clearBlockAndCancel {
    if (self) {
        [self setCompletionBlockWithSuccess:NULL failure:NULL];
        [self setDownloadProgressBlock:NULL];
        [self cancel];
    }
}

@end
