//
//  LoginViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/4.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ForgetPwdViewController.h"
#import "AccountInputView.h"
#import "AlarmManager.h"

@interface LoginViewController ()
<UITextFieldDelegate>
{
    AccountInputView    *_telView;
    AccountInputView    *_pwdView;
}
@property (nonatomic, strong) TPKeyboardAvoidingScrollView *contentView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"登录";
    [self customRightTextBtn:@"注册" action:@selector(registerBtnPressed:)];
    [self setupView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerDidFinish:) name:kRegisterDidFinish object:nil];
}

#pragma mark - view

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
    
    _pwdView = [[AccountInputView alloc] initWithIconName:@"logins_icon_password" placeholder:@"请输入密码"];
    _pwdView.frame = CGRectMake(_telView.left, _telView.bottom+10, _telView.width, _telView.height);
    _pwdView.textFd.keyboardType = UIKeyboardTypeASCIICapable;
    _pwdView.textFd.autocorrectionType = UITextAutocorrectionTypeNo;
    _pwdView.textFd.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _pwdView.objKey = @"password";
    _pwdView.objName = @"密码";
    _pwdView.textFd.secureTextEntry = YES;
    [self.contentView addSubview:_pwdView];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(20, _pwdView.bottom+30, deviceWidth-40, 46);
    loginBtn.layer.cornerRadius = 2;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.backgroundColor = HexRGBA(0x248FEC, 255);
    [loginBtn setTitleColor:HexGRAY(0xFF, 255) forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:Expand6(16, 17)];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:loginBtn];
    
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetBtn.frame = CGRectMake(20, loginBtn.bottom+5, deviceWidth-40, 44);
    forgetBtn.titleLabel.font = [UIFont systemFontOfSize:Expand6(13, 14)];
    [forgetBtn setTitleColor:HexRGBA(0x4598DE, 255) forState:UIControlStateNormal];
    [forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetBtn addTarget:self action:@selector(forgetBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:forgetBtn];
}

- (NSArray *)inputCells {
    return @[_telView, _pwdView];
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
        [_pwdView.textFd becomeFirstResponder];
    }
}

- (void)registerDidFinish:(NSNotification *)notification {
    [self.navigationController popToViewController:self animated:YES];
    [self.view endEditing:YES];
    
    _telView.textFd.text = notification.userInfo[@"mobile"];
    _pwdView.textFd.text = notification.userInfo[@"password"];
    
    [self loginBtnPressed:nil];
}

#pragma mark - action

- (void)loginBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
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
    [Api login:params successBlock:^(id body) {
        [self.view hideLoadingView];
        
        UserModel *userObj = [UserModel modelFromJSONDictionary:body];
        [[UserManager sharedInstance] userDidChange:userObj];
        [[AlarmManager sharedInstance] bindAlarmData];
        [[RootNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
    } failBlock:^(NSString *message, NSInteger code) {
        [self.view showErrorText:message];
    }];
}

- (void)registerBtnPressed:(id)sender {
    RegisterViewController *controller = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)forgetBtnPressed:(id)sender {
    ForgetPwdViewController *controller = [[ForgetPwdViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
