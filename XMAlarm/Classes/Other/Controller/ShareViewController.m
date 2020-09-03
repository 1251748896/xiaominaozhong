//
//  ShareViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/10/1.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareBtnView.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"分享";
    [self customRightImgBtn:[UIImage imageNamed:@"nav_share"] img2:nil action:@selector(shareBtnPressed:)];
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DEBUG_LOG(@"xxx");
}

#pragma mark - action

- (void)shareBtnPressed:(id)sender {
    ShareBtnView *btnView = [[ShareBtnView alloc] initWithFrame:CGRectZero];
    WeakSelf
    btnView.sureBlock = ^(NSInteger index) {
        [weakSelf shareByIndex:index];
    };
    [btnView show];
}

- (void)shareByIndex:(NSInteger)index {
    SSDKPlatformType platformType = 0 == index ? SSDKPlatformSubTypeWechatSession : SSDKPlatformSubTypeWechatTimeline;
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupWeChatParamsByText:@"生活在这快节奏的都市，人们每天忙忙碌碌，没个尽头。在忙碌、充实的日子里，我们需要记忆的事务也越来越多、越来越繁琐，造成大家的记忆负担也越来越重，有时可能稍有不慎，就错过了很多重要的事情，给我们的生活带来了烦恼。" title:@"小秘闹钟-2017尾号限行提醒" url:[NSURL URLWithString:kShareAppLink] thumbImage:[UIImage imageNamed:@"img_logo"] image:[UIImage imageNamed:@"img_logo"] musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil sourceFileExtension:nil sourceFileData:nil type:SSDKContentTypeWebPage forPlatformSubType:platformType];
    [ShareSDK share:platformType parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                [self.view showSuccessText:@"分享成功"];
                break;
            }
            case SSDKResponseStateFail:
            {
                [self.view showErrorText:@"分享失败"];
                break;
            }
            default:
                break;
        }
    }];
}

#pragma mark - view

- (void)setupView {
    TPKeyboardAvoidingScrollView *contentView = [[TPKeyboardAvoidingScrollView alloc] init];
    if (@available(iOS 11.0, *)) {
        contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(GAP20+topBarHeight);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    UIImageView *logoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_logo"]];
    [contentView addSubview:logoIcon];
    
    UILabel *versionLbl = [[UILabel alloc] init];
    versionLbl.textColor = HexRGBA(0x333333, 255);
    versionLbl.font = [UIFont systemFontOfSize:Expand6(14, 15)];
    versionLbl.textAlignment = NSTextAlignmentCenter;
    versionLbl.text = @"小秘闹钟-2017尾号限行提醒";
    [contentView addSubview:versionLbl];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = HexRGBA(0xE3E3E3, 255);
    [contentView addSubview:line];
    
    UILabel *infoLbl = [[UILabel alloc] init];
    infoLbl.textColor = HexRGBA(0x666666, 255);
    infoLbl.font = [UIFont systemFontOfSize:Expand6(12, 13)];
    infoLbl.numberOfLines = 0;
    NSString *infoStr = @"生活在这快节奏的都市，人们每天忙忙碌碌，没个尽头。在忙碌、充实的日子里，我们需要记忆的事务也越来越多、越来越繁琐，造成大家的记忆负担也越来越重，有时可能稍有不慎，就错过了很多重要的事情，给我们的生活带来了烦恼。\n小秘闹钟基于这种现状，致力于通过科技手段把用户的记忆包袱减到最小，不要有因遗忘而给我们带来的不必要的烦恼。\n目前小秘闹钟主要以闹钟为基础、以提醒为支撑、以限行为创新，努力为不同需求的人群提供多样化的提醒服务。\n如果您在使用过程中，发现我们的产品有任何的问题或者需要改进的地方，请在个人中心的“意见与建议”里提出，我们将会视情况给予一定奖励以示感谢！\n最后希望通过我们不断的努力和大家的帮助，不断完善我们的产品，为更多的用户提供更有价值的服务！";
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:infoStr attributes:@{NSParagraphStyleAttributeName: style}];
    infoLbl.attributedText = attrStr;
    [contentView addSubview:infoLbl];
    
    CGFloat qrWidth = 105;
    UIImageView *qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake((deviceWidth-qrWidth)/2, 50, qrWidth, qrWidth)];
    qrImageView.image = [UIImage qrImageForString:kShareAppLink imageSize:2*105];
    [contentView addSubview:qrImageView];
    
    [logoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 70));
        make.top.mas_equalTo(25);
        make.centerX.equalTo(contentView);
    }];
    [versionLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(contentView);
        make.top.equalTo(logoIcon.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(Expand6(24, 26));
    }];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(contentView);
        make.top.equalTo(versionLbl.mas_bottom).mas_offset(25);
        make.height.mas_equalTo(1);
    }];
    CGSize size = [infoLbl sizeThatFits:CGSizeMake(deviceWidth-30, CGFLOAT_MAX)];
    [infoLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(deviceWidth-30);
        make.top.equalTo(line.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(ceilf(size.height));
    }];
    [qrImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(qrWidth, qrWidth));
        make.centerX.equalTo(contentView);
        make.top.equalTo(infoLbl.mas_bottom).mas_offset(25);
    }];
    [contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(qrImageView.mas_bottom).offset(25).priorityLow();
        make.bottom.greaterThanOrEqualTo(self.view);
    }];
}

@end
