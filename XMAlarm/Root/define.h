//
//  define.h
//  OnMobile
//
//  Created by bo.chen on 15/9/25.
//  Copyright © 2015年 keruyun. All rights reserved.
//

#ifndef define_h
#define define_h

#ifdef DEBUG
#define DEBUG_LOG(format, ...) NSLog((@"%@(%d)%s:\n" format), [[NSString stringWithCString:__FILE__ encoding:NSASCIIStringEncoding] lastPathComponent], __LINE__, __FUNCTION__, ##__VA_ARGS__)
#else
#define DEBUG_LOG(format, ...)
#endif

#define FONTSTYLE @"Helvetica"
#define FONTSTYLEBOLD @"Helvetica-Bold"

#define deviceWidth [UIScreen mainScreen].bounds.size.width
#define deviceHeight [UIScreen mainScreen].bounds.size.height
#define iPhoneX (deviceHeight >= 812)
#define TopGap (iPhoneX ? 24 : 0)
#define BottomGap (iPhoneX ? 34 : 0)
#define GAP20 (20+TopGap)
#define topBarHeight 44
#define tabBarHeight (49+BottomGap)

extern CGFloat scaleRatio;
#define CGRectExpand(x,y,w,h) CGRectMake((x)*scaleRatio,(y)*scaleRatio,(w)*scaleRatio,(h)*scaleRatio)
#define CGSizeExpand(x,y) CGSizeMake((x)*scaleRatio,(y)*scaleRatio)
#define Expand6(x,y) (scaleRatio == 1 ? (x) : (y))

// 改变到每个app >>
#ifdef DEBUG
#define kAPIServer @"http://api.yupukeji.com/"
#else
#define kAPIServer @"http://api.yupukeji.com/"
#endif
#define kAppStoreLink @"https://itunes.apple.com/us/app/%E5%B0%8F%E7%A7%98%E9%97%B9%E9%92%9F/id1310228030?l=zh&ls=1&mt=8"
#define kAppStoreId @"1310228030"
#define kShareAppLink @"http://www.yupukeji.com/share.html"

//jpush
#define kJpushAppKey @"500b323069b46d1c8c140ff9"
//友盟
#define kUmengAppKey @"59dd9124e88bad338400001f"
#define kChannel @"AppStore"

#define SafeRelease(a) if (a) {[a release]; a = nil;}
#define RemoveAllSubviews(view) for (UIView *subview in view.subviews) [subview removeFromSuperview];
#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongObj(o) __strong typeof(o) strong##o = o;
//检查数组下标获取数组对象 无效下标返回nil
#define safeGetArrayObject(array, index)    \
    (index)<[array count]?[array objectAtIndex:(index)]:nil;

// << 计算文本宽度
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define MB_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
#define MB_TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define MB_MULTILINE_TEXTSIZE(text, font, maxSize) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
#define MB_MULTILINE_TEXTSIZE(text, font, maxSize) [text length] > 0 ? [text \
sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByTruncatingTail] : CGSizeZero;
#endif
// 计算文本宽度 >>

#define HexGRAY(w,a) [UIColor colorWithWhite:(w)/255.0 alpha:(a)/255.0]
#define HexRGBA(rgb,a) [UIColor colorWithRed:(((rgb) & 0xFF0000) >> 16)/255.0 green:(((rgb) & 0xFF00) >> 8)/255.0 blue:(((rgb) & 0xFF))/255.0 alpha:(a)/255.0]
#define UIColorFromRGB(rgb) HexRGBA(rgb, 255)
#define UIColorFromRGBA(rgb,a) HexRGBA(rgb, (a)*255)
#define UIViewAutoresizingAlignCenter UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin

#define SSJKString(a) (a) ? [(a) description] : @""
#define APPDisplayName [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]
#define APPVersionName [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]
#define APPVersionCode [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]
#define kAppVersionKey @"AppVersion"
#define User_Default [NSUserDefaults standardUserDefaults]
#define APNSToken @"APNSToken"

#define kKeychainServiceName @"com.ypkj.xmalarm"
#define kDeviceIDKey @"appDeviceID"
#define DeviceID [User_Default objectForKey:kDeviceIDKey]

#define isRetina [UIScreen mainScreen].scale == 2.0

typedef void (^NoparamBlock)();
typedef void (^IndexBlock)(NSInteger index);
typedef void (^ObjectBlock)(id obj);

// UI
#define kColor1 HexRGBA(0x2d2f3c, 255)
#define kColor2 HexRGBA(0x2a2937, 255)
#define kColor3 HexRGBA(0x39BE5B, 255) //蓝色
#define kColor4 HexGRAY(0xFF, 0.4*255) //灰色

#define NAVBARCOLOR kColor1
#define NAVTEXTCOLOR HexGRAY(0xFF, 255)

#define BKGCOLOR HexGRAY(0xFF, 255)
#define BTNACTIVECOLOR kColor3

#define kPlayBannerHeight 56
#define PageSize 30

//#define kAutoFMID 300604
#define kAutoFMID 999819

#define kAdvertRatio 0.368

//刷新闹钟列表
#define kRefreshAlarmList @"RefreshAlarmList"
//更新显示的闹钟时间
#define kUpdateAlarmListView @"UpdateAlarmListView"
#define kRegisterDidFinish @"RegisterDidFinish"

//User_Default
#define kDisclaimerKnownKey @"DisclaimerKnown"
#define kDisclaimerAlertTimeKey @"DisclaimerAlertTime"

#endif
