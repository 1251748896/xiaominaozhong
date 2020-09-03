//
//  SelectRingViewController.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/5.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "SelectRingViewController.h"
#import "VoicePlayer.h"
#import "RiseAlarm.h"
#import "ShiftAlarm.h"
#import "CustomAlarm.h"
#import "RepeatRemind.h"
#import "TempRemind.h"
#import "AlarmManager.h"

@interface SelectRingViewController ()
@property (nonatomic, strong) NSString *ringName;
@end

@implementation SelectRingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"铃声选择";
    self.ringName = self.alarm.ringName;
    [self customRightTextBtn:@"确定" action:@selector(sureBtnPressed:)];
    [self dataFactory];
}

- (NSArray *)cellClasses {
    return @[[SelectRingCell class]];
}

- (void)dataFactory {
    [self.dataSource removeAllObjects];
    
    //添加不响铃
    [self.dataSource insertObject:[NSURL fileURLWithPath:DontRingName] atIndex:0];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
#ifdef UseBundleRing
    NSURL *directoryURL = [NSBundle mainBundle].bundleURL;
#else
    NSURL *directoryURL = [NSURL URLWithString:@"/Library/Ringtones/"];
#endif
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            if ([self isAlarm] && [[url pathExtension] isEqualToString:@"m4r"]) {
                [self.dataSource addObject:url];
            } else if (![self isAlarm] && [[url pathExtension] isEqualToString:@"caf"]) {
                [self.dataSource addObject:url];
            }
        }
    }
    
    [self.dataSource sortUsingComparator:^NSComparisonResult(NSURL *  _Nonnull obj1, NSURL *  _Nonnull obj2) {
        NSString *filename1 = [obj1 lastPathComponent];
        NSString *filename2 = [obj2 lastPathComponent];
        NSDictionary *configDict1 = [AlarmManager sharedInstance].ringConfigDict[filename1];
        NSDictionary *configDict2 = [AlarmManager sharedInstance].ringConfigDict[filename2];
        if (configDict1 && configDict2) {
            return [configDict1[@"sort"] compare:configDict2[@"sort"]];
        } else if (configDict2) {
            return NSOrderedDescending;
        } else if (configDict1) {
            return NSOrderedAscending;
        } else {
            return [filename1 compare:filename2];
        }
    }];

    [self refreshView];
}

- (BOOL)isAlarm {
//    return [self.alarm isMemberOfClass:[RiseAlarm class]] ||
//    [self.alarm isMemberOfClass:[ShiftAlarm class]] ||
//    [self.alarm isMemberOfClass:[CustomAlarm class]];
    return YES;
}

#pragma mark - view

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[VoicePlayer sharedInstance] stop];
}

#pragma mark - action

- (void)sureBtnPressed:(id)sender {
    if (self.sureBlock) {
        self.sureBlock(self.ringName);
    }
    [super backBtnPressed:nil];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectRingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectRingCell"];
    NSString *title = [self.dataSource[indexPath.row] lastPathComponent];
    BOOL checked = [self.ringName isEqualToString:title];
    cell.dataDict = @{@"title": [[AlarmManager sharedInstance] nameByRingFileName:title], @"checked": @(checked)};
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = [self.dataSource[indexPath.row] lastPathComponent];
    BOOL checked = [self.ringName isEqualToString:title];
    
    if (!checked) {
        self.ringName = title;
        [self refreshView];
    }
    
    [[VoicePlayer sharedInstance] stop];
    if (![title isEqualToString:DontRingName]) {
        [[VoicePlayer sharedInstance] playUrl:self.dataSource[indexPath.row] loops:0];
    }
}

@end

@implementation SelectRingCell {
    UILabel *_titleLbl;
    UIImageView *_checkIcon;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textColor = HexRGBA(0x373737, 255);
        _titleLbl.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_titleLbl];
        
        _checkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_choice_nor"]];
        [self.contentView addSubview:_checkIcon];
        
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.equalTo(_checkIcon.mas_left).mas_offset(-20);
            make.top.height.equalTo(self);
        }];
        [_checkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(18, 18));
            make.centerY.equalTo(self);
            make.left.equalTo(_titleLbl.mas_right).mas_offset(20);
            make.right.equalTo(self).mas_offset(-10);
        }];
    }
    return self;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    
    _titleLbl.text = dataDict[@"title"];
    BOOL checked = [dataDict[@"checked"] boolValue];
    _checkIcon.image = [UIImage imageNamed:checked ? @"icon_choice_sel" : @"icon_choice_nor"];
}

@end
