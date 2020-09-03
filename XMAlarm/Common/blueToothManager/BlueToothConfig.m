//
//  BlueToothConfig.m
//  BlueToothCon
//
//  Created by 姜波 on 2018/4/21.
//  Copyright © 2018年 姜波. All rights reserved.
//

#import "BlueToothConfig.h"
#import "LYFHudView.h"
#import "AlarmLog.h"
#import "ZZXBluetoothManager.h"

static BOOL isHex = NO;

@implementation BlueToothConfig

#pragma mark --- 基础时间
+ (NSTimeInterval)userPhoneDateInterval {
    return [[self userPhoneDate] timeIntervalSince1970];
}

+ (NSDate *)userPhoneDate {
    return [NSDate date];
}
//获取当前手机的时间 -- 年
+ (NSInteger)getYearDegree:(NSInteger)degree {
    
    if (degree <= 0 || degree > 4) {
        [LYFHudView showText:@"年-参数异常"];
        return 0;
    }
    NSDate *date    = [self userPhoneDate];
    NSDateFormatter *matter = [self getFormater:@"yyyy"];
    
    NSString *yearStr = [matter stringFromDate:date];
    NSInteger yearInt = [yearStr integerValue];
    
    NSInteger yu = [self getYuNumber:degree];
    
    return yearInt%yu;
}

+ (NSInteger)getYuNumber:(NSInteger)degree {
    NSInteger yu = 10;
    if (degree == 1) {
        yu = 10;
    } else if (degree == 2) {
        yu = 100;
    } else if (degree == 3) {
        yu = 1000;
    }
    return yu;
}
//获取当前手机的时间 -- 月
+ (NSInteger)getMonth {
    
    NSDate *date    = [self userPhoneDate];
    NSDateFormatter *matter = [self getFormater:@"MM"];
    
    NSString *monthStr = [matter stringFromDate:date];
    NSInteger monthInt = [monthStr integerValue];
    
    return monthInt;
}
//获取当前手机的时间 -- 周
+ (NSInteger)getWeek {
    NSDate *date    = [self userPhoneDate];
    return [self calcuteWeek:date];
}
//获取指定date的当前星期 -- 周
+ (NSInteger)getWeekWithDate:(NSDate *)date {
    return [self calcuteWeek:date];
}

+ (NSInteger)calcuteWeek:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    comps = [calendar components:unitFlags fromDate:date];
    
    /**
     comps.weekday
     星期日是数字1，星期一时数字2
     */
    
    NSInteger week = comps.weekday - 1;
    
    if (week == 0) {
        week = 7;
    }
    return week;
}
//获取当前手机的时间 -- 日
+ (NSInteger)getDay {
    NSDate *date    = [self userPhoneDate];
    NSDateFormatter *matter = [self getFormater:@"dd"];
    
    NSString *dayStr = [matter stringFromDate:date];
    NSInteger dayInt = [dayStr integerValue];
    
    return dayInt;
}
//获取当前手机的时间 -- 小时
+ (NSInteger)getHour {
    NSDate *date = [self userPhoneDate];
    NSDateFormatter *matter = [self getFormater:@"HH"];
    NSString *hourStr = [matter stringFromDate:date];
    NSInteger hour = [hourStr integerValue];
    return hour;
}
//获取当前手机的时间 -- 分钟
+ (NSInteger)getminite {
    NSDate *date = [self userPhoneDate];
    NSDateFormatter *matter = [self getFormater:@"mm"];
    NSString *hourStr = [matter stringFromDate:date];
    NSInteger hour = [hourStr integerValue];
    return hour;
}
//获取当前手机的时间 -- 秒
+ (NSInteger)getSeconds {
    NSDate *date = [self userPhoneDate];
    NSDateFormatter *matter = [self getFormater:@"ss"];
    NSString *hourStr = [matter stringFromDate:date];
    NSInteger hour = [hourStr integerValue];
    return hour;
}

+ (NSDateFormatter *)getFormater:(NSString *)dateFormat {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:dateFormat];
    return formatter;
}

#pragma mark -----协议2---

//针对模式1 、轮换日1
/**
 @return 年月日都是10进制的数字
 */
+ (struct XMDate)nextWeekLimitDateWithModel:(TrafficLimitAlarm *)model {
    
    NSDate *cityChangeDate = [model shiftEndDate];
    struct XMDate xmDate = {0, 0, 0, 0};
    xmDate = [self getXMDateWith:cityChangeDate];
    return xmDate;
}
//判断第一个限行日  是不是就是当天
+ (BOOL)isToday:(struct XMDate)xmDate {
    NSDate *date = [NSDate date];
    struct XMDate xmDateCur = [self getXMDateWith:date];
    if (xmDate.year != xmDateCur.year) {
        return NO;
    }
    if (xmDate.month != xmDateCur.month) {
        return NO;
    }
    if (xmDate.day != xmDateCur.day) {
        return NO;
    }
    return YES;
}

/**
 @return 年月日都是10进制的数字
 */
+ (struct XMDate)nextLimitDate:(NSTimeInterval)limitInterval cycle:(NSInteger)cycle {
    
    NSTimeInterval onDayInterval =  24 * 60 * 60 ;
    NSTimeInterval nextInterval = limitInterval + 7 * onDayInterval * cycle;
    
    NSDate *nextDate = [NSDate dateWithTimeIntervalSince1970:nextInterval];
    
    struct XMDate xmDate = [self getXMDateWith:nextDate];
    
    return xmDate;
}

/**
 @return 年月日都是10进制的数字、 年 -> 保留最后一位
 */
+ (struct XMDate)getXMDateWith:(NSDate *)nextLimitDate {
    
    NSString *year = [[self getFormater:@"yyyy"] stringFromDate:nextLimitDate];
    NSString *month = [[self getFormater:@"MM"] stringFromDate:nextLimitDate];
    NSString *day = [[self getFormater:@"dd"] stringFromDate:nextLimitDate];
    
    int tempYear = [year intValue] % 10;
    int tempMonth = [month intValue];
    int tempDay = [day intValue];
    
    struct XMDate xmDate = {0, 0, 0, 0};
    xmDate.year = tempYear;
    xmDate.month = tempMonth;
    xmDate.day = tempDay;
    xmDate.interval = [nextLimitDate timeIntervalSince1970];
    xmDate.week = (int)[self getWeekWithDate:nextLimitDate];
    
    return xmDate;
}

+ (NSInteger)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
}
/**
 构建 年检日期的结构体
 @return 年月日都是10进制的数字
 */
+ (struct XMYearCheckDate)getYearCheckDateWithModel:(TrafficLimitAlarm *)model {
    
    int year = [[[self getFormater:@"yyyy"] stringFromDate:model.yearCheckDate] intValue] % 100;
    int month = [[[self getFormater:@"MM"] stringFromDate:model.yearCheckDate] intValue];
    int day = [[[self getFormater:@"dd"] stringFromDate:model.yearCheckDate] intValue];
    
    struct XMYearCheckDate yearCheckInfo = {0, 0, 0};
    yearCheckInfo.year = year;
    yearCheckInfo.month = month;
    yearCheckInfo.day = day;
    
    return yearCheckInfo;
}

#pragma mark -- 同步时间
+ (NSData *)getSyncTime {
    //下发时间：
    NSInteger year = [self getYearDegree:2];
    NSInteger month = [self getMonth];
    NSInteger day = [self getDay];
    NSInteger week = [self getWeek];
    NSInteger hour = [self getHour];
    NSInteger minte = [self getminite];
    NSInteger secon = [self getSeconds];
    if (isHex) {
        year = [self getLimitDay:(int)year];
        month = [self getLimitDay:(int)month];
        day = [self getLimitDay:(int)day];
        hour = [self getLimitDay:(int)hour];
        minte = [self getLimitDay:(int)minte];
        secon = [self getLimitDay:(int)secon];
    }
    Byte byte[20] = {0xaa,0x01,year,month,day,hour,minte,secon,week,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0} ;
    NSData *data = [NSData dataWithBytes:byte length:20];
    
    return data;
}

+ (NSString *)monthString:(int)month {
    if (month == 10) {
        return @"A";
    } else if (month == 11) {
        return @"B";
    } else if (month == 12) {
        return @"C";
    }
    
    return [NSString stringWithFormat:@"%d",month];
}
/**
 @return 年月日都是16进制的数字
 */
+ (struct XMHoliday)xmHolidayWithRange:(NSRange)range {
    struct XMHoliday holidays = {0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,YES};
    
    NSArray *listArr = [ZZXBluetoothManager shared].holidayArray;
    NSLog(@"listArr = %@",listArr);
//    if (listArr == nil || listArr.count == 0) {
//        [LYFHudView showText:@"还没有配置假期信息"];
//        holidays.success = NO;
//        return holidays;
//    }
    
    NSInteger leaveCount = listArr.count - range.location;
    
    if (leaveCount <= 0) {
        
        return holidays;
    }
    
    if (range.length > leaveCount) {
        
        if (leaveCount > 0) {
            
            range.length = leaveCount;
        } else {
            
            return holidays;
        }
    }
    
    NSArray *currentArray = [listArr subarrayWithRange:range];
    
    int i = 0;
    
    for (id interval in currentArray) {
        
        NSString *str = [NSString stringWithFormat:@"%@",interval];
        NSDate *tempDate = [NSDate dateWithTimeIntervalSince1970:str.doubleValue/1000.0];
        
        struct XMDate tempXmDate = [self getXMDateWith:tempDate];
        
        int yearMon = (int)[self getLimitYearMonth:tempXmDate.year mon:tempXmDate.month];
        int day = (int)[self getLimitDay:tempXmDate.day];
        
        if (i == 0) {
            holidays.oneYearMonth = yearMon;
            holidays.oneDay = day;
        } else if (i == 1) {
            holidays.twoYearMonth = yearMon;
            holidays.twoDay = day;
        } else if (i == 2) {
            holidays.thirdYearMonth = yearMon;
            holidays.thirdDay = day;
        } else if (i == 3) {
            holidays.fourYearMonth = yearMon;
            holidays.fourDay = day;
        } else if (i == 4) {
            holidays.fiveYearMonth = yearMon;
            holidays.fiveDay = day;
        } else if (i == 5) {
            holidays.sixYearMonth = yearMon;
            holidays.sixDay = day;
        } else if (i == 6) {
            holidays.sevenYearMonth = yearMon;
            holidays.sevenDay = day;
        } else if (i == 7) {
            holidays.eightYearMonth = yearMon;
            holidays.eightDay = day;
        } else if (i == 8) {
            holidays.nineYearMonth = yearMon;
            holidays.nineDay = day;
        }
        
        i ++;
    }
    
    return holidays;
}

#pragma mark -- 同步年检日期和限行轮换日
+ (NSData *)getYearCheckTimeAndRestrictionTimeWithModel:(TrafficLimitAlarm *)model {
    
    //所有模式固定的格式
    struct XMYearCheckDate yearCheckDate = [self getYearCheckDateWithModel:model];
    int year = yearCheckDate.year; // 年检的年
    int month = yearCheckDate.month;
    int day = yearCheckDate.day;
    NSDate *date    = [self userPhoneDate];
    NSDateFormatter *matter = [self getFormater:@"yyyy"];
    NSDateFormatter *matterM = [self getFormater:@"MM"];
    NSDateFormatter *matterD = [self getFormater:@"dd"];
    NSString *yearStr = [matter stringFromDate:date];
    NSInteger yearInt = [yearStr integerValue]; // 当前的年
    NSString *monStr = [matterM stringFromDate:date];
    NSInteger monInt = [monStr integerValue];
    NSString *dayStr = [matterD stringFromDate:date];
    NSInteger dayInt = [dayStr integerValue];
    int cha = yearInt - (2000 + year);//当前的年 - 年检年 = cha(差)
    int nextMon = month;
    int nextYear = year + 2000;
    
    if (cha < 6) {
        // 每2年年检一次
        while (nextYear < yearInt) {
            nextYear = nextYear + 2;
        }
        if (nextYear == yearInt) {
            if (monInt > month) {
                nextYear = nextYear + 2;
            } else if (monInt == month) {
                if (dayInt >= day) {
                    nextYear = nextYear + 2;
                }
            }
        }
    } else if (cha >= 6 && cha < 15) {
        // 每年检
        nextYear = nextYear + 6;
        
        while (nextYear < yearInt) {
            nextYear = nextYear + 1;
        }
        
        if (nextYear == yearInt) {
            if (monInt > month) {
                nextYear = nextYear + 1;
            } else if (monInt == month) {
                if (dayInt >= day) {
                    nextYear = nextYear + 1;
                }
            }
        }
        
    } else if (cha < 0) {
        // 异常
        NSLog(@"-------11111");
        NSLog(@"年检日期异常");
    } else {
        //  每半年检
        nextYear = nextYear + 15;
        while (nextYear < yearInt) {
            nextYear = nextYear + 1;
        }
        if (monInt > month) {
            nextMon = nextMon + 6;
        } else if (monInt == month) {
            if (dayInt >= day) {
                nextMon = nextMon + 6;
            }
        }
        if (nextMon > 12) {
            nextYear = nextYear + 1;
            nextMon = nextMon - 12;
        }
    }
    nextYear = nextYear%100;
    year = (int)[self getLimitDay:nextYear];
    month = (int)[self getLimitDay:nextMon];
    day = (int)[self getLimitDay:day];
    NSInteger limitMode = [model.limitRule.limitMode integerValue];
    
    if (model.showState.intValue == 12 || model.showState.intValue == 13) {
        limitMode = 0;
    }
    
    NSLog(@"limitMode = %ld",(long)limitMode);
    //按星期轮换的才有限行周( 1 2 )
    NSInteger limitWeek = [model.limitRule.weekday integerValue] - 1;
    
    //按日期轮换的就是 限行日( 3 4 )（全部列出来）
    NSLog(@"daysStr = %@",model.limitRule.daysStr);
    
    if (limitMode == 0) {
        Byte byte[20] = {
            0xaa,0x02,
            year,month,day,0,
            0,
            0,0,
            0,0,
            0,0,
            0,0,
            0,0,0,0,0};
        NSData *data = [NSData dataWithBytes:byte length:20];
        return data;
    }
    
    if (limitMode == 1) {
        //date1的年月日都是10进制
        //轮换1
        struct XMDate date1 = [self nextWeekLimitDateWithModel:model];
        BOOL today = [self isToday:date1];
        if (today) {
            date1 = [self nextLimitDate:date1.interval cycle:[model.limitRule.shiftWeeks integerValue]];
            limitWeek = limitWeek + 1;
            if (limitWeek > 5) {
                limitWeek = 1;
            }
        }
        NSInteger limitYearMonth1 = [self getLimitYearMonth:date1.year mon:date1.month];
        NSInteger limitDay1 = date1.day;
        if (isHex) {
            limitDay1 = [self getLimitDay:date1.day];
        }
        
        //轮换2
        struct XMDate date2 = [self nextLimitDate:date1.interval cycle:[model.limitRule.shiftWeeks integerValue]];
        NSInteger limitYearMonth2 = [self getLimitYearMonth:date2.year mon:date2.month];
        NSInteger limitDay2 = date2.day;
        if (isHex) {
            limitDay2 = [self getLimitDay:date2.day];
        }
        //轮换3
        struct XMDate date3 = [self nextLimitDate:date2.interval cycle:[model.limitRule.shiftWeeks integerValue]];
        NSInteger limitYearMonth3 = [self getLimitYearMonth:date3.year mon:date3.month];
        NSInteger limitDay3 = date3.day;
        if (isHex) {
            limitDay3 = [self getLimitDay:date3.day];
        }
        //轮换4
        struct XMDate date4 = [self nextLimitDate:date3.interval cycle:[model.limitRule.shiftWeeks integerValue]];
        NSInteger limitYearMonth4 = [self getLimitYearMonth:date4.year mon:date4.month];
        NSInteger limitDay4 = date4.day;
        if (isHex) {
            limitDay4 = [self getLimitDay:date4.day];
        }
        // 上传的 年检时间数据 是对的
        
        Byte byte[20] = {
            0xaa,0x02,
            year,month,day,limitMode,
            limitWeek,
            limitYearMonth1,limitDay1,
            limitYearMonth2,limitDay2,
            limitYearMonth3,limitDay3,
            limitYearMonth4,limitDay4,
            0x0,0x0,0x0,0x0,0x0};
        //添加结束时间
        NSDateFormatter *hourMatter = [self getFormater:@"HH"];
        NSDateFormatter *minteMatter = [self getFormater:@"mm"];
        
        if (model.limitRule.limitPeriods.count > 0) {
            LimitPeriod *timeModel = [model.limitRule.limitPeriods firstObject];
            
            NSInteger hou2 = [[hourMatter stringFromDate:timeModel.time2] integerValue];
            NSInteger minte2 = [[minteMatter stringFromDate:timeModel.time2] integerValue];
            if (isHex) {
                hou2 = [self getLimitDay:(int)hou2];
                minte2 = [self getLimitDay:(int)minte2];
            }
            byte[15] = hou2;
            byte[16] = minte2;
        }
        NSLog(@"协议二数据参数 = 0xaa,0x02 %d %d %d %d %d %x %x %x %x %x %x %x %x 0x0,0x0,0x0,0x0,0x0", year, month, day,limitMode, limitWeek,limitYearMonth1, limitDay1,limitYearMonth2, limitDay2,limitYearMonth3, limitDay3,limitYearMonth4, limitDay4);
        NSData *data = [NSData dataWithBytes:byte length:20];
        return data;
    }
    
    if (limitMode == 2) {
        
        Byte byte[20] = {
            0xaa,0x02,
            year,month,day,limitMode,
            limitWeek,
            0,0,
            0,0,
            0,0,
            0,0,
            0x0,0x0,0x0,0x0,0x0};
        //添加结束时间
        NSDateFormatter *hourMatter = [self getFormater:@"HH"];
        NSDateFormatter *minteMatter = [self getFormater:@"mm"];
        
        if (model.limitRule.limitPeriods.count > 0) {
            LimitPeriod *timeModel = [model.limitRule.limitPeriods firstObject];
            
            NSInteger hou2 = [[hourMatter stringFromDate:timeModel.time2] integerValue];
            NSInteger minte2 = [[minteMatter stringFromDate:timeModel.time2] integerValue];
            if (isHex) {
                hou2 = [self getLimitDay:(int)hou2];
                minte2 = [self getLimitDay:(int)minte2];
            }
            byte[7] = hou2;
            byte[8] = minte2;
        }
        
        NSData *data = [NSData dataWithBytes:byte length:20];
        return data;
    }
    
    if (limitMode == 3 || limitMode == 4) {
        
        Byte byte[20] = {
            0xaa,0x02,
            year,month,day,limitMode,
            0,
            0,0,
            0,0,
            0,0,
            0,0,
            0x0,0x0,0x0,0x0,0x0} ;
        
        NSArray *temp = [model.limitRule.daysStr componentsSeparatedByString:@","];
        int i = 0;
        for (NSString *numStr in temp) {
            NSInteger dayNum = [numStr integerValue];
            if (isHex) {
                dayNum = [self getLimitDay:[numStr intValue]];
            }
            byte[6+i] = dayNum;
            i++ ;
        }
        
        //添加结束时间
        NSDateFormatter *hourMatter = [self getFormater:@"HH"];
        NSDateFormatter *minteMatter = [self getFormater:@"mm"];
        
        if (model.limitRule.limitPeriods.count > 0) {
            LimitPeriod *timeModel = [model.limitRule.limitPeriods firstObject];
            NSInteger hou2 = [[hourMatter stringFromDate:timeModel.time2] integerValue];
            NSInteger minte2 = [[minteMatter stringFromDate:timeModel.time2] integerValue];
            if (isHex) {
                hou2 = [self getLimitDay:(int)hou2];
                minte2 = [self getLimitDay:(int)minte2];
            }
            byte[13] = hou2;
            byte[14] = minte2;
        }
        NSData *data = [NSData dataWithBytes:byte length:20];
        NSString *ss = @"";
        NSString *dd = @"";
        for (int j=0; j<20; j++) {
            ss = [NSString stringWithFormat:@"%@ | %d",ss,byte[j]];
            dd = [NSString stringWithFormat:@"%@ | %x",dd,byte[j]];
        }
        NSLog(@"ss = %@",ss);
        NSLog(@"dd = %@",dd);
        return data;
    }
    
    if (limitMode == 5) {
        
        Byte byte[20] = {
            0xaa,0x02,
            year,month,day,limitMode,
            limitWeek,
            0,0,
            0,0,
            0,0,
            0,0,
            0x0,0x0,0x0,0x0,0x0} ;
        NSDateFormatter *hourMatter = [self getFormater:@"HH"];
        NSDateFormatter *minteMatter = [self getFormater:@"mm"];
        for (int i=0; i<model.limitRule.limitPeriods.count; i++) {
            LimitPeriod *timeModel = model.limitRule.limitPeriods[i];
            
            NSInteger hou1 = [[hourMatter stringFromDate:timeModel.time1] integerValue];
            NSInteger minte1 = [[minteMatter stringFromDate:timeModel.time1] integerValue];
            NSInteger hou2 = [[hourMatter stringFromDate:timeModel.time2] integerValue];
            NSInteger minte2 = [[minteMatter stringFromDate:timeModel.time2] integerValue];
            if (isHex) {
                hou1 = [self getLimitDay:(int)hou1];
                minte1 = [self getLimitDay:(int)minte1];
                hou2 = [self getLimitDay:(int)hou2];
                minte2 = [self getLimitDay:(int)minte2];
            }
            if (i == 0) {
                byte[7] = hou1;
                byte[7+1] = minte1;
                byte[7+2] = hou2;
                byte[7+3] = minte2;
            } else if (i == 1) {
                byte[11] = hou1;
                byte[11+1] = minte1;
                byte[11+2] = hou2;
                byte[11+3] = minte2;
            }
        }
        
        NSData *data = [NSData dataWithBytes:byte length:20];
        
        return data;
    }
    
    return nil;
}

+ (NSInteger)getLimitDay:(int)day {
    int ten = day / 10;
    int g = day % 10;
    
    if (isHex) {
        return ten * 16 + g;
    }
    return ten * 10 + g;
}
// 获取年月组合
+ (NSInteger)getLimitYearMonth:(int)year mon:(int)month {
    
    if (month < 10) {
        return year * 16 + month;
//        if (isHex) {
//             return year * 16 + month;
//        }
//        return year * 10 + month;
    }
    if (year == 8) {
        if (month == 10) {
            return 0x8a;
        } else if (month == 11) {
            return 0x8b;
        } else if (month == 12) {
            return 0x8c;
        }
    } else if (year == 9) {
        if (month == 10) {
            return 0x9a;
        } else if (month == 11) {
            return 0x9b;
        } else if (month == 12) {
            return 0x9c;
        }
    } else if (year == 0) {
        if (month == 10) {
            return 0xa;
        } else if (month == 11) {
            return 0xb;
        } else if (month == 12) {
            return 0xc;
        }
    } else if (year == 1) {
        if (month == 10) {
            return 0x1a;
        } else if (month == 11) {
            return 0x1b;
        } else if (month == 12) {
            return 0x1c;
        }
    } else if (year == 2) {
        if (month == 10) {
            return 0x2a;
        } else if (month == 11) {
            return 0x2b;
        } else if (month == 12) {
            return 0x2c;
        }
    } else if (year == 3) {
        if (month == 10) {
            return 0x3a;
        } else if (month == 11) {
            return 0x3b;
        } else if (month == 12) {
            return 0x3c;
        }
    } else if (year == 4) {
        if (month == 10) {
            return 0x4a;
        } else if (month == 11) {
            return 0x4b;
        } else if (month == 12) {
            return 0x4c;
        }
    } else if (year == 5) {
        if (month == 10) {
            return 0x5a;
        } else if (month == 11) {
            return 0x5b;
        } else if (month == 12) {
            return 0x5c;
        }
    } else if (year == 6) {
        if (month == 10) {
            return 0x6a;
        } else if (month == 11) {
            return 0x6b;
        } else if (month == 12) {
            return 0x6c;
        }
    } else if (year == 7) {
        if (month == 10) {
            return 0x7a;
        } else if (month == 11) {
            return 0x7b;
        } else if (month == 12) {
            return 0x7c;
        }
    }
    
    return 0;
}



#pragma mark ---解除年检更新报警
+ (NSData *)getUpdateInfoIsAlarm:(BOOL)alarm {
    int status = 0x0;
    if (alarm) {
        status = 0x01;
    }
    Byte byte[20] = {0xaa,0x03,status,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0} ;
    NSData *data = [NSData dataWithBytes:byte length:20];
    return data;
}

#pragma mark ---获取设备时间和车内温湿度
+ (NSData *)getDeviceTimeAndTemperature {
    Byte byte[20] = {0xaa,0x04,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0} ;
    NSData *data = [NSData dataWithBytes:byte length:20];
    return data;
}

#pragma mark ---下发节假日
+ (NSData *)getHolidayData:(NSInteger)order {
    
    NSInteger len = 9;
    
    NSInteger loc = (order - 1) * len;
    
    NSRange range = NSMakeRange(loc, len);
    
    struct XMHoliday holidays = [self xmHolidayWithRange:range];
//    if (holidays.success == NO) {
//        return nil;
//    }
    int zu = 0x05;
    if (order == 1) {
        zu = 0x05;
    } else if (order == 2) {
        zu = 0x06;
    } else if (order == 3) {
        zu = 0x07;
    } else if (order == 4) {
        zu = 0x08;
    }
    
    Byte byte[20] = {0xaa,zu,
        holidays.oneYearMonth,holidays.oneDay,
        holidays.twoYearMonth,holidays.twoDay,
        holidays.thirdYearMonth,holidays.thirdDay,
        holidays.fourYearMonth,holidays.fourDay,
        holidays.fiveYearMonth,holidays.fiveDay,
        holidays.sixYearMonth,holidays.sixDay,
        holidays.sevenYearMonth,holidays.sevenDay,
        holidays.eightYearMonth,holidays.eightDay,
        holidays.nineYearMonth,holidays.nineDay} ;
    NSData *data = [NSData dataWithBytes:byte length:20];
    
    return data;
}

+ (void)printAllHolidayInfo {
    NSArray *temp = [ZZXBluetoothManager shared].holidayArray;
    
    NSDateFormatter *m = [self getFormater:@"yyyy-MM-dd HH:mm:ss EEEE"];
    
    for (id str in temp) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[str doubleValue]/1000.0];
        NSString *timeStr = [m stringFromDate:date];
        NSLog(@"%@",timeStr);
    }
}

@end
