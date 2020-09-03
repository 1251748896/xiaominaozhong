//
//  RegisterViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "RegisterViewController.h"
#import "AccountInputView.h"

@interface RegisterViewController ()
<UITextFieldDelegate>
{
    AccountInputView    *_telView;
    AccountInputView    *_vrcView;
    AccountInputView    *_pwdView;
    NSMutableArray      *_verifiedCodeArray;
}
@property (nonatomic, strong) TPKeyboardAvoidingScrollView *contentView;

@property (nonatomic, strong) UIButton *codeBtn;
@property(nonatomic, strong) NSTimer *verificationCodeTimer;
@property(nonatomic, assign) NSTimeInterval reCodeTime;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _verifiedCodeArray = [NSMutableArray array];
    self.titleLabel.text = @"注册";
    [self setupView];
}

- (void)setupView {
    self.contentView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, deviceWidth, deviceHeight)];
    if (@available(iOS 11.0, *)) {
        self.contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view insertSubview:self.contentView atIndex:0];
    
    _telView = [[AccountInputView alloc] initWithIconName:@"logins_icon_phone" placeholder:@"请输入手机号"];
    _telView.frame = CGRectMake(20, 64+30, deviceWidth-40, 46);
    _telView.textFd.keyboardType = UIKeyboardTypeNumberPad;
    _telView.objKey = @"mobile";
    _telView.objName = @"手机号";
    _telView.regex = @"1\\d{10}";
    _telView.textFd.delegate = self;
    [_telView.textFd addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_telView];
    
    _vrcView = [[AccountInputView alloc] initWithIconName:@"logins_icon_Captcha" placeholder:@"请输入验证码"];
    _vrcView.frame = CGRectMake(_telView.left, _telView.bottom+20, _telView.width-115, _telView.height);
    _vrcView.textFd.keyboardType = UIKeyboardTypeNumberPad;
    _vrcView.objKey = @"valicode";
    _vrcView.objName = @"验证码";
    _vrcView.textFd.delegate = self;
    [_vrcView.textFd addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_vrcView];
    
    self.codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.codeBtn.frame = CGRectMake(_telView.right-105, _vrcView.top, 105, _telView.height);
//    self.codeBtn.layer.borderColor = kColor1.CGColor;
//    self.codeBtn.layer.borderWidth = 1;
//    self.codeBtn.layer.cornerRadius = 4;
//    self.codeBtn.layer.masksToBounds = YES;
    [self.codeBtn setBackgroundImage:[[UIImage imageNamed:@"logins_bg_captcha"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)] forState:UIControlStateNormal];
    [self.codeBtn setTitleColor:HexRGBA(0x5A5A5A, 255) forState:UIControlStateNormal];
    self.codeBtn.titleLabel.font = [UIFont systemFontOfSize:Expand6(14, 15)];
    self.codeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.codeBtn.titleLabel.minimumScaleFactor = 0.8;
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.codeBtn addTarget:self action:@selector(codeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.codeBtn];
    
    _pwdView = [[AccountInputView alloc] initWithIconName:@"logins_icon_password" placeholder:@"请设置登录密码(4-16个字符)"];
    _pwdView.frame = CGRectMake(_telView.left, _vrcView.bottom+20, _telView.width, _telView.height);
    _pwdView.textFd.keyboardType = UIKeyboardTypeASCIICapable;
    _pwdView.textFd.autocorrectionType = UITextAutocorrectionTypeNo;
    _pwdView.textFd.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _pwdView.objKey = @"password";
    _pwdView.objName = @"密码";
    [self.contentView addSubview:_pwdView];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(20, _pwdView.bottom+30, deviceWidth-40, 46);
    loginBtn.layer.cornerRadius = 2;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.backgroundColor = HexRGBA(0x248FEC, 255);
    [loginBtn setTitleColor:HexGRAY(0xFF, 255) forState:UIControlStateNormal];
    [loginBtn setTitleColor:HexRGBA(0xACAEB2, 255) forState:UIControlStateDisabled];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:Expand6(16, 17)];
    [loginBtn setTitle:@"完成" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:loginBtn];
}

- (NSArray *)inputCells {
    return @[_telView, _vrcView, _pwdView];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _telView.textFd) {
        // 手机号只能输入11位 限制
        NSString *tmpTxt = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return tmpTxt.length <= 11;
    }
    return YES;
}

- (void)textFieldDidChanged:(UITextField *)textField {
    if (textField == _telView.textFd && textField.text.length == 11) {
        [textField resignFirstResponder];
    }
}

#pragma mark - vrc code

- (void)canSendVerifyCode {
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    
    if (current <= self.reCodeTime) {
        
        self.codeBtn.userInteractionEnabled = NO;
        [self.codeBtn setTitle:[NSString stringWithFormat:@"%.0f秒后重发", self.reCodeTime - current] forState:UIControlStateNormal];
        
    }
    else {
        if (self.verificationCodeTimer) {
            [self.verificationCodeTimer invalidate];
            self.verificationCodeTimer = nil;
        }
        self.codeBtn.userInteractionEnabled = YES;
        [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
}

- (void)codeBtnPressed:(id)sender {
    NSString *error = [_telView checkValueError];
    if (error.length > 0) {
        [self.view showErrorText:error];
        return;
    }
    
    [self.view showLoadingView:@"正在发送验证码" disableTouch:YES];
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:_telView.textFd.text zone:@"86" result:^(NSError *error) {
        if (!error) {
            //请求成功
            [self.view hideLoadingView];
            //删除记录的验证
            [_verifiedCodeArray removeAllObjects];
            
            //2分钟后重发
            NSInteger resend_time = 120;
            if (self.verificationCodeTimer) {
                [self.verificationCodeTimer invalidate];
                self.verificationCodeTimer = nil;
            }
            self.reCodeTime = [[[NSDate date] dateByAddingTimeInterval:resend_time] timeIntervalSince1970];
            self.verificationCodeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(canSendVerifyCode) userInfo:nil repeats:YES];
        } else {
            DEBUG_LOG(@"%@", error);
            [self.view showErrorText:@"验证码发送失败"];
        }
    }];
}

#pragma mark - action

- (void)loginBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
    if (_pwdView.textFd.text.length < 4 || _pwdView.textFd.text.length > 16) {
        [self.view showErrorText:@"密码需要4-16个字符"];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //检查参数
    for (AccountInputView *fieldObj in self.inputCells) {
        NSString *error = [fieldObj checkValueError];
        if (error.length > 0) {
            [self.view showErrorText:error];
            return;
        }
        [params setValue:fieldObj.textFd.text forKey:fieldObj.objKey];
    }
    params[@"password"] = [params[@"password"] md5FromString];
    
    [self.view showLoadingView:YES];
    [self verifyCode:params[@"valicode"] mobile:params[@"mobile"] block:^{
        //请求自己的服务器
        [self execRequest:params successBlock:^(id body) {
            [self.view hideLoadingView];
            
            NSDictionary *userInfo = @{@"mobile": _telView.textFd.text, @"password": _pwdView.textFd.text};
            [[NSNotificationCenter defaultCenter] postNotificationName:kRegisterDidFinish object:nil userInfo:userInfo];
        } failBlock:^(NSString *message, NSInteger code) {
            [self.view showErrorText:message];
        }];
    }];
}

- (void)verifyCode:(NSString *)code mobile:(NSString *)mobile block:(NoparamBlock)successBlock {
    if ([_verifiedCodeArray indexOfObject:code] == NSNotFound) {
        //未验证
        [SMSSDK commitVerificationCode:code phoneNumber:mobile zone:@"86" result:^(NSError *error) {
            if (!error) {
                [_verifiedCodeArray addObject:code];
                //验证成功
                if (successBlock) {
                    successBlock();
                }
            } else {
                DEBUG_LOG(@"%@", error);
                [self.view showErrorText:@"验证码错误"];
            }
        }];
    } else {
        if (successBlock) {
            successBlock();
        }
    }
}

- (void)execRequest:(NSDictionary *)params successBlock:(SuccessBlock)success failBlock:(FailBlock)fail {
    [Api register:params successBlock:success failBlock:fail];
}

@end
