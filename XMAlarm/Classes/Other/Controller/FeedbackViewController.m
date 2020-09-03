//
//  FeedbackViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/30.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "FeedbackViewController.h"
#import "SAMTextView.h"

@interface FeedbackViewController ()
<UITextViewDelegate>
@end

@implementation FeedbackViewController {
    SAMTextView *_textView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"建议反馈";
    [self setupView];
}

#pragma mark - view

- (void)setupView {
    TPKeyboardAvoidingScrollView *contentView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, deviceHeight)];
    if (@available(iOS 11.0, *)) {
        contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view insertSubview:contentView atIndex:0];
    
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, 278)];
//    bgView.backgroundColor = HexGRAY(0xFF, 255);
//    [contentView addSubview:bgView];
    
//    _emailFd = [[UITextField alloc] initWithFrame:CGRectMake(10, 15, deviceWidth-20, 34)];
//    _emailFd.textColor = HexGRAY(0x2E, 255);
//    _emailFd.font = [UIFont systemFontOfSize:16];
//    _emailFd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"您的电子邮箱" attributes:@{NSForegroundColorAttributeName: HexRGBA(0xb4b7c0, 255)}];
//    [bgView addSubview:_emailFd];
//    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(_emailFd.left, _emailFd.bottom-0.5, _emailFd.width, 0.5)];
//    line.backgroundColor = HexRGBA(0xe6e8f0, 255);
//    [bgView addSubview:line];
    
    _textView = [[SAMTextView alloc] initWithFrame:CGRectMake(15, self.topView.bottom+20, deviceWidth-30, 135)];
    _textView.layer.borderColor = HexRGBA(0xD1D6DE, 255).CGColor;
    _textView.layer.borderWidth = 1;
    _textView.layer.cornerRadius = 2;
    _textView.layer.masksToBounds = YES;
    _textView.delegate = self;
    _textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _textView.textColor = HexGRAY(0x33, 255);
    _textView.font = [UIFont systemFontOfSize:Expand6(14, 15)];
    _textView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入您的建议……" attributes:@{NSForegroundColorAttributeName: HexRGBA(0xB3B3B3, 255), NSFontAttributeName: [UIFont systemFontOfSize:15]}];
    [contentView addSubview:_textView];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(_textView.left+2, _textView.bottom+5, _textView.width, 20)];
    lbl.textColor = HexGRAY(0x99, 255);
    lbl.font = [UIFont systemFontOfSize:11];
    lbl.text = @"100个字符以内";
    [contentView addSubview:lbl];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(15, _textView.bottom+50, deviceWidth-30, 46);
    sureBtn.layer.cornerRadius = 2;
    sureBtn.layer.masksToBounds = YES;
    sureBtn.backgroundColor = HexRGBA(0x248FEC, 255);
    [sureBtn setTitleColor:HexGRAY(0xFF, 255) forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [sureBtn setTitle:@"提交" forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:sureBtn];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length >= 100) {
        return NO;
    }
    return YES;
}

- (void)sureBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
    if (_textView.text.length <= 0) {
        [self.view showErrorText:@"请输入建议与反馈"];
        return;
    }
    
    if (_textView.text.length > 100) {
        [self.view showErrorText:@"很抱歉，您的建议超过100字"];
        return;
    }
    
    NSDictionary *params = @{@"uid": TheUser.id, @"content": _textView.text};
    
    [self.view showLoadingView:YES];
    [Api saveSuggest:params successBlock:^(id body) {
        [self.view showSuccessText:@"感谢您的宝贵意见"];
        self.view.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } failBlock:^(NSString *message, NSInteger code) {
        [self.view showErrorText:message];
    }];
}

@end
