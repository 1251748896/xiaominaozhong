//
//  LYFHudView.m
//  kkkk
//
//  Created by Mac mini on 2018/4/19.
//  Copyright © 2018年 Mac mini. All rights reserved.
//

#import "LYFHudView.h"

@implementation LYFHudView

+ (void)showText:(NSString *)text {
    
    if ([self isNullString:text]) {
        return;
    }
    
    NSInteger textLen = text.length;
    
    if (textLen == 0) {
        return;
    }
    
    CGFloat showTime = 1.0;
    
    UIViewController *vc = [self getCurrentVC];
    
    if (vc == nil) {
        NSLog(@"没有找到当前的控制器");
        return;
    }
    
    UIFont *textFont = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    CGFloat edge = 20;
    CGFloat labelMargin = 15;
    CGFloat maxWidth = vc.view.bounds.size.width - edge*2 - labelMargin*2;
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont} context:nil];
    
    CGFloat bgViewW = textRect.size.width + labelMargin*2;
    CGFloat bgViewH = textRect.size.height + labelMargin*2;
    
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor blackColor];
    backView.frame = CGRectMake(0, 0, bgViewW, bgViewH);
    backView.layer.cornerRadius = 5.0;
    backView.layer.masksToBounds = YES;
    backView.center = vc.view.center;
    [vc.view addSubview:backView];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.numberOfLines = 0;
    label.bounds = CGRectMake(0, 0, textRect.size.width, textRect.size.height);
    label.font = textFont;
    label.center = CGPointMake(CGRectGetWidth(backView.bounds)/2.0, CGRectGetHeight(backView.bounds)/2.0);
    label.textColor = [UIColor whiteColor];
    [backView addSubview:label];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(showTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [backView removeFromSuperview];
    });
}

+ (void)showLoadingAnimationOnView:(UIView *)view {
    
}

+ (void)hiddenLoadingAnimationOnView:(UIView *)view {
    
}

+ (void)showLoadingAnimation {
    
}

+ (void)hiddenLoadingAnimation {
    
}


+ (BOOL)isNullString:(NSString *)text {
    if (text == nil) {
        return YES;
    }
    
    if ([text isEqualToString:@"null"]) {
        return YES;
    }
    
    if ([text isEqualToString:@"(null)"]) {
        return YES;
    }
    
    if ([text isEqualToString:@"<null>"]) {
        return YES;
    }
    
    if ([text isEqualToString:@"nil"]) {
        return YES;
    }
    return NO;
}

+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
