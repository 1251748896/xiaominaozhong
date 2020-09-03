//
//  AFRequest+Cancel.h
//  KxrDoctor
//
//  Created by Mac on 15/10/18.
//  Copyright © 2015年 kouxiaoer. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface AFHTTPRequestOperation (Cancel)

- (void)clearBlockAndCancel;

@end
