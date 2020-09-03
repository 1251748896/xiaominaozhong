//
//  ScheduleViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ScheduleViewController.h"
#import "SAMTextView.h"

@interface ScheduleViewController ()
<UITextViewDelegate>
{
    UILabel     *_timeLbl;
    SAMTextView     *_noteView;
}
@property (nonatomic, strong) UIView *footerView;
@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"待办事项";
    [self customRightTextBtn:@"确定" action:@selector(sureBtnPressed:)];
    [self setupView];
    //添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - view

- (void)setupView {
    _timeLbl = [[UILabel alloc] init];
    _timeLbl.textColor = HexGRAY(0x66, 255);
    _timeLbl.font = [UIFont systemFontOfSize:11];
    [self.view addSubview:_timeLbl];
    
    _noteView = [[SAMTextView alloc] init];
    _noteView.delegate = self;
    _noteView.textColor = HexGRAY(0x33, 255);
    _noteView.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_noteView];
    [_noteView becomeFirstResponder];
    
    //E3 F7 2390EE
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, deviceHeight-(15+42+15), deviceWidth, 15+42+15)];
    self.footerView.backgroundColor = HexGRAY(0xFF, 255);
    [self.view addSubview:self.footerView];
    
    _timeLbl.text = [NSDateFormatter stringFromDate:self.schedule.updateTime formatStr:@"yyyy.MM.dd HH:mm"];
    _noteView.text = self.schedule.note;
    [_timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.equalTo(self.view).mas_offset(-12);
        make.top.equalTo(self.topView.mas_bottom).mas_offset(6);
        make.height.mas_equalTo(20);
    }];
    [_noteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_timeLbl);
        make.top.equalTo(_timeLbl.mas_bottom).mas_offset(2);
        make.bottom.equalTo(self.footerView.mas_top);
    }];
    
    UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    delBtn.layer.borderWidth = 1;
    delBtn.layer.borderColor = HexGRAY(0xE3, 255).CGColor;
    delBtn.layer.cornerRadius = 21;
    delBtn.layer.masksToBounds = YES;
    delBtn.backgroundColor = HexGRAY(0xE7, 255);
    [delBtn setTitleColor:HexRGBA(0xFF0000, 255) forState:UIControlStateNormal];
    delBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(delBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:delBtn];
    [delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(15, 15, 15, 15));
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.schedule.note = textView.text;
}

#pragma mark - UIKeyboardNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame {
    if (beginFrame.origin.y == deviceHeight) {
        self.footerView.top = deviceHeight-self.footerView.height-(toFrame.size.height-BottomGap);
    }
    else if (toFrame.origin.y == deviceHeight) {
        self.footerView.top = deviceHeight-self.footerView.height;
    }
    else {
        self.footerView.top = deviceHeight-self.footerView.height-(toFrame.size.height-BottomGap);
    }
}

#pragma mark - action

- (void)sureBtnPressed:(id)sender {
    self.schedule.updateTime = [NSDate date];
    [self.schedule save];
    [self backBtnPressed:nil];
}

- (void)delBtnPressed:(id)sender {
    if (self.schedule.primaryId) {
        [self.schedule remove];
    }
    [self backBtnPressed:nil];
}

@end
