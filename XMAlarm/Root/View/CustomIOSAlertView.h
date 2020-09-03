//
//  CustomIOSAlertView.h
//  OnMobile
//
//  Created by bo.chen on 17/4/17.
//  Copyright © 2017年 keruyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomIOSAlertViewDelegate

@optional
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CustomIOSAlertView : UIView<CustomIOSAlertViewDelegate>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, strong) UIView *dialogView;    // Dialog's container view
@property (nonatomic, strong) UIView *containerView; // Container within the dialog (place your ui elements here)

@property (nonatomic, weak) id<CustomIOSAlertViewDelegate> delegate;
@property (nonatomic, strong) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;
@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UIView *titleLine;//标题下面的线

@property (nonatomic, copy) void (^onButtonTouchUpInside)(CustomIOSAlertView *alertView, int buttonIndex);

- (instancetype)initWithTitle:(NSString *)title;

- (void)show;
- (void)close;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(CustomIOSAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;

@end
