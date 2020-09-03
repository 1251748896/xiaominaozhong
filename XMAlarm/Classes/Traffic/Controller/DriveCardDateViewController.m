//
//  DriveCardDateViewController.m
//  XMAlarm
//
//  Created by Mac mini on 2018/4/26.
//  Copyright © 2018年 com.xmm. All rights reserved.
//

#import "DriveCardDateViewController.h"
#import "DateAlertView.h"
#import "TrafficLimitViewController.h"
@interface DriveCardDateViewController ()

@end

@implementation DriveCardDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"年检日期";
    WeakSelf
    StrongObj(weakSelf)
    NSDate *date = [NSDate date];
    if (self.alarm.yearCheckDate) {
        date = self.alarm.yearCheckDate;
    }
    DateAlertView *alertView = [[DateAlertView alloc] initWithTitle:@"年检时间" date:date mode:UIDatePickerModeDate];
    
    alertView.sureBlock = ^(NSDate *date) {
        strongweakSelf.alarm.yearCheckDate = date;
        [strongweakSelf sureBtnPressed];
    };
    
    alertView.cancleBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    [alertView show];
    
}
- (void)sureBtnPressed {
    if (self.initAdd) {
        TrafficLimitViewController *controller = [[TrafficLimitViewController alloc] init];
        controller.alarm = self.alarm;
        controller.showState = self.showState;
        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        //只保留1个vc在数组当中
        NSInteger cou = viewControllers.count - 1;
        for (int j=0; j<cou; j++) {
            [viewControllers removeLastObject];
        }
        [viewControllers addObject:controller];
        [self.navigationController setViewControllers:viewControllers animated:YES];
    } else {
        if (_fixDateBlock) {
            _fixDateBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
