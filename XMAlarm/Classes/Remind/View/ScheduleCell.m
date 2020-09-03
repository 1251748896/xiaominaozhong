//
//  ScheduleCell.m
//  XMAlarm
//
//  Created by bo.chen on 17/9/10.
//  Copyright © 2017年 com.xmm. All rights reserved.
//

#import "ScheduleCell.h"
#import "SAMTextView.h"

@interface ScheduleCell ()
<UITextViewDelegate>
{
    UILabel     *_timeLbl;
    SAMTextView     *_noteView;
}
@end

@implementation ScheduleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.line.hidden = YES;
        
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.textColor = HexGRAY(0x66, 255);
        _timeLbl.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:_timeLbl];
        
        _noteView = [[SAMTextView alloc] init];
        _noteView.delegate = self;
        _noteView.textColor = HexGRAY(0x33, 255);
        _noteView.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_noteView];
        [_noteView becomeFirstResponder];
        
        [_timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.right.equalTo(self).mas_offset(-12);
            make.top.mas_equalTo(6);
            make.height.mas_equalTo(20);
        }];
        [_noteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_timeLbl);
            make.top.equalTo(_timeLbl.mas_bottom).mas_offset(2);
            make.bottom.equalTo(self);
        }];
    }
    return self;
}

- (void)setSchedule:(Schedule *)schedule {
    _schedule = schedule;
    
    _timeLbl.text = [NSDateFormatter stringFromDate:schedule.updateTime formatStr:@"yyyy.MM.dd HH:mm"];
    _noteView.text = schedule.note;
}

- (void)textViewDidChange:(UITextView *)textView {
    _schedule.note = textView.text;
}

@end
