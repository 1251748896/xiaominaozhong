//
//  AsyncRun.m
//  OnMobile
//
//  Created by bo.chen on 17/1/6.
//  Copyright © 2017年 keruyun. All rights reserved.
//

#import "AsyncRun.h"

void AsyncRun(NoparamBlock run) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        run();
    });
}

void AsyncRunInMain(NoparamBlock run) {
    dispatch_async(dispatch_get_main_queue(), ^{
        run();
    });
}

void AsyncRunAfter(NoparamBlock run, int seconds) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        run();
    });
}
