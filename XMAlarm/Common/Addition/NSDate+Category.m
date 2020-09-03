/************************************************************
*  * EaseMob CONFIDENTIAL
* __________________
* Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
*
* NOTICE: All information contained herein is, and remains
* the property of EaseMob Technologies.
* Dissemination of this information or reproduction of this material
* is strictly forbidden unless prior written permission is obtained
* from EaseMob Technologies.
*/

#import "NSDate+Category.h"
#import "NSDateFormatter+Category.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
#define DATE_COMPONENTS (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
#else
#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#endif
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@implementation NSDate (Category)

- (NSString *)description {
    NSDateComponents *components = [CURRENT_CALENDAR components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    return [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d:%02d", components.year, components.month, components.day, components.hour, components.minute, components.second];
}

/*距离当前的时间间隔描述*/
- (NSString *)timeIntervalDescription {
    NSTimeInterval timeInterval = -[self timeIntervalSinceNow];
    if (timeInterval < 60) {
        return NSLocalizedString(@"NSDateCategory.text1", @"");
    } else if (timeInterval < 3600) {
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text2", @""), timeInterval / 60];
    } else if (timeInterval < 86400) {
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text3", @""), timeInterval / 3600];
    } else if (timeInterval < 2592000) {//30天内
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text4", @""), timeInterval / 86400];
    } else if (timeInterval < 31536000) {//30天至1年内
        NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text5", @"")];
        return [dateFormatter stringFromDate:self];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text6", @""), timeInterval / 31536000];
    }
}

/*精确到分钟的日期描述*/
- (NSString *)minuteDescription {
    NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];

    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    if ([theDay isEqualToString:currentDay]) {//当天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [dateFormatter stringFromDate:self];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) {//昨天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text7", @'"'), [dateFormatter stringFromDate:self]];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] < 86400 * 7) {//间隔一周内
        [dateFormatter setDateFormat:@"EEEE ah:mm"];
        return [dateFormatter stringFromDate:self];
    } else {//以前
        [dateFormatter setDateFormat:@"yyyy-MM-dd ah:mm"];
        return [dateFormatter stringFromDate:self];
    }
}

/*标准时间日期描述*/
- (NSString *)formattedTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateNow = [formatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(8, 2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(5, 2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0, 4)] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:components]; //今天 0点时间

    NSInteger hour = [self hoursAfterDate:date];
    NSDateFormatter *dateFormatter = nil;
    NSString *ret = @"";

    //hasAMPM==TURE为12小时制，否则为24小时制
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;

    if (!hasAMPM) { //24小时制
        if (hour <= 24 && hour >= 0) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"HH:mm"];
        } else if (hour < 0 && hour >= -24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text8", @"")];
        } else {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd HH:mm"];
        }
    } else {
        if (hour >= 0 && hour <= 6) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text9", @"")];
        } else if (hour > 6 && hour <= 11) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text10", @"")];
        } else if (hour > 11 && hour <= 17) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text11", @"")];
        } else if (hour > 17 && hour <= 24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text12", @"")];
        } else if (hour < 0 && hour >= -24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text13", @"")];
        } else {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd HH:mm"];
        }
    }

    ret = [dateFormatter stringFromDate:self];
    return ret;
}

- (NSString *)dateFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *time = [dateFormatter stringFromDate:self];
    return time;
}

/*格式化日期描述*/
- (NSString *)formattedDateDescription {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日

    NSInteger timeInterval = -[self timeIntervalSinceNow];
    if (timeInterval < 60) {
        return NSLocalizedString(@"NSDateCategory.text1", @"");
    } else if (timeInterval < 3600) {//1小时内
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text2", @""), timeInterval / 60];
    } else if (timeInterval < 21600) {//6小时内
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text3", @""), timeInterval / 3600];
    } else if ([theDay isEqualToString:currentDay]) {//当天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text14", @""), [dateFormatter stringFromDate:self]];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) {//昨天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text7", @""), [dateFormatter stringFromDate:self]];
    } else {//以前
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        return [dateFormatter stringFromDate:self];
    }
}

- (NSString *)formattedUtlTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    NSDate *currentDate = [NSDate date];
    NSInteger seconds = [currentDate timeIntervalSinceDate:self];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[[NSDate alloc] init]];
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0];
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *bbday = [cal dateByAddingComponents:components toDate:yesterday options:0];
    NSString *str = nil;
    if (seconds < 60) {
        str = [NSString stringWithFormat:@"%d秒前", seconds];
    } else if (seconds < 60 * 60) {
        str = [NSString stringWithFormat:@"%d分钟前", seconds / 60];
    } else if (seconds < 3 * 3600) {
        str = [NSString stringWithFormat:@"%d小时前", seconds / 3600];
    } else if ([self compare:today] == NSOrderedDescending) {
        [formatter setDateFormat:@"HH:mm"];
        str = [NSString stringWithFormat:@"今天%@", [formatter stringFromDate:self]];
    } else if ([self compare:yesterday] == NSOrderedDescending) {
        [formatter setDateFormat:@"HH:mm"];
        str = [NSString stringWithFormat:@"昨天%@", [formatter stringFromDate:self]];
    } else if ([self compare:bbday] == NSOrderedDescending) {
        [formatter setDateFormat:@"HH:mm"];
        str = [NSString stringWithFormat:@"前天%@", [formatter stringFromDate:self]];
    } else {
        [formatter setDateFormat:@"MM-dd"];
        str = [NSString stringWithFormat:@"%@", [formatter stringFromDate:self]];
    }
    return str;
}

- (double)timeIntervalSince1970InMilliSecond {
    double ret;
    ret = [self timeIntervalSince1970] * 1000;

    return ret;
}

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond {
    NSDate *ret = nil;
    double timeInterval = timeIntervalInMilliSecond;
    // judge if the argument is in secconds(for former data structure).
    if (timeIntervalInMilliSecond > 140000000000) {
        timeInterval = timeIntervalInMilliSecond / 1000;
    }
    ret = [NSDate dateWithTimeIntervalSince1970:timeInterval];

    return ret;
}

+ (NSString *)formattedTimeFromTimeInterval:(long long)time {
    return [[NSDate dateWithTimeIntervalInMilliSecondSince1970:time] formattedUtlTime];
}

#pragma mark Relative Dates

+ (NSDate *)dateWithDaysFromNow:(NSInteger)days {
    // Thanks, Jim Morrison
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *)dateWithDaysBeforeNow:(NSInteger)days {
    // Thanks, Jim Morrison
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *)dateTomorrow {
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *)dateYesterday {
    return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *)dateWithHoursFromNow:(NSInteger)dHours {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

#pragma mark Comparing Dates

- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (NSComparisonResult)compareIgnoringDate:(NSDate *)aDate {
    if (!aDate) {
        return NSOrderedDescending;
    }
    return [@([self timeIntervalSinceDate:[self dateAtStartOfDay]]) compare:@([aDate timeIntervalSinceDate:[aDate dateAtStartOfDay]])];
}

- (BOOL)isToday {
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL)isTomorrow {
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL)isYesterday {
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL)isSameWeekAsDate:(NSDate *)aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];

    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.weekOfYear != components2.weekOfYear) return NO;

    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL)isThisWeek {
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL)isNextWeek {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

- (BOOL)isLastWeek {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL)isSameMonthAsDate:(NSDate *)aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL)isThisMonth {
    return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL)isSameYearAsDate:(NSDate *)aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:aDate];
    return (components1.year == components2.year);
}

- (BOOL)isThisYear {
    // Thanks, baspellis
    return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL)isNextYear {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];

    return (components1.year == (components2.year + 1));
}

- (BOOL)isLastYear {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];

    return (components1.year == (components2.year - 1));
}

- (BOOL)isEarlierThanDate:(NSDate *)aDate {
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL)isLaterThanDate:(NSDate *)aDate {
    return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL)isInFuture {
    return ([self isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL)isInPast {
    return ([self isEarlierThanDate:[NSDate date]]);
}


#pragma mark Roles

- (BOOL)isTypicallyWeekend {
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitWeekday fromDate:self];
    if ((components.weekday == 1) ||
            (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL)isTypicallyWorkday {
    return ![self isTypicallyWeekend];
}

#pragma mark Adjusting Dates

// Thaks, rsjohnson
- (NSDate *)dateByAddingYears:(NSInteger)dYears {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:dYears];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)dateBySubtractingYears:(NSInteger)dYears {
    return [self dateByAddingYears:-dYears];
}

- (NSDate *)dateByAddingMonths:(NSInteger)dMonths {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:dMonths];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)dateBySubtractingMonths:(NSInteger)dMonths {
    return [self dateByAddingMonths:-dMonths];
}

- (NSDate *)dateByAddingDays:(NSInteger)dDays {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingDays:(NSInteger)dDays {
    return [self dateByAddingDays:(dDays * -1)];
}

- (NSDate *)dateByAddingHours:(NSInteger)dHours {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingHours:(NSInteger)dHours {
    return [self dateByAddingHours:(dHours * -1)];
}

- (NSDate *)dateByAddingMinutes:(NSInteger)dMinutes {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingMinutes:(NSInteger)dMinutes {
    return [self dateByAddingMinutes:(dMinutes * -1)];
}

- (NSDate *)dateByAddingSeconds:(NSInteger)dSeconds {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + dSeconds;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingSeconds:(NSInteger)dSeconds {
    return [self dateByAddingSeconds:(dSeconds * -1)];
}

- (NSDate *)dateAtStartOfDay {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *)dateAtEndOfDay {
    return [[self dateAtStartOfDay] dateByAddingTimeInterval:24 * 60 * 60];
}

- (NSDate *)dateAtStartOfWeekday {
    NSDateComponents *currentComps = [CURRENT_CALENDAR components:NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.weekday = -currentComps.weekday + 1;
    comps.hour = -currentComps.hour;
    comps.minute = -currentComps.minute;
    comps.second = -currentComps.second;
    return [CURRENT_CALENDAR dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate *)dateAtEndOfWeekday {
    return [[self dateAtStartOfWeekday] dateByAddingTimeInterval:7 * 24 * 60 * 60];
}

- (NSDate *)dateAtStartOfMonth {
    NSDateComponents *currentComps = [CURRENT_CALENDAR components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = -currentComps.day + 1;
    comps.hour = -currentComps.hour;
    comps.minute = -currentComps.minute;
    comps.second = -currentComps.second;
    return [CURRENT_CALENDAR dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate *)dateAtEndOfMonth {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.month = 1;
    comps.day = -1;
    return [CURRENT_CALENDAR dateByAddingComponents:comps toDate:[self dateAtStartOfMonth] options:0];
}

- (NSDate *)dateAtStartOfYear {
    NSDateComponents *currentComps = [CURRENT_CALENDAR components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.month = -currentComps.month+1;
    comps.day = -currentComps.day + 1;
    comps.hour = -currentComps.hour;
    comps.minute = -currentComps.minute;
    comps.second = -currentComps.second;
    return [CURRENT_CALENDAR dateByAddingComponents:comps toDate:self options:0];
}

- (NSDateComponents *)componentsWithOffsetFromDate:(NSDate *)aDate {
    NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
    return dTime;
}

#pragma mark Retrieving Intervals

- (NSInteger)minutesAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger)minutesBeforeDate:(NSDate *)aDate {
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger)hoursAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger)hoursBeforeDate:(NSDate *)aDate {
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger)daysAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}

- (NSInteger)daysBeforeDate:(NSDate *)aDate {
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:anotherDate options:0];
    return components.day;
}

#pragma mark Decomposing Dates

- (NSInteger)nearestHour {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitHour fromDate:newDate];
    return components.hour;
}

- (NSInteger)hour {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.hour;
}

- (NSInteger)minute {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.minute;
}

- (NSInteger)seconds {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.second;
}

- (NSInteger)day {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.day;
}

- (NSInteger)month {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.month;
}

- (NSInteger)week {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekOfYear;
}

- (NSInteger)weekday {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekday;
}

- (NSInteger)nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekdayOrdinal;
}

- (NSInteger)year {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.year;
}

- (NSInteger)maxDay {
    return [self dateAtEndOfMonth].day;
}

- (NSString *)chineseDayStr {
    NSCalendar *lunarCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    lunarCalendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    
    NSInteger day = [lunarCalendar components:NSCalendarUnitDay fromDate:self].day;//日
    NSInteger month = [lunarCalendar components:NSCalendarUnitMonth fromDate:self].month; //月
    
    static NSArray *dayStrings;
    static NSArray *monthStrings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dayStrings = @[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",
                    @"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",
                    @"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十"];
        monthStrings = @[@"正",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"腊"];
    });
    
    NSString *dayStr = dayStrings[day - 1];
    NSString* monthStr = [NSString stringWithFormat:@"%@月", monthStrings[month - 1]];
    if ([dayStr isEqualToString:@"初一"]) {
        dayStr = monthStr;
    }
    //节假日转换
    NSString *holidayStr = [NSDate getHolidays:self];
    if (holidayStr.length > 0) {
        dayStr = holidayStr;
    }
    
    return dayStr;
}

+ (NSString *)howLongStr:(NSInteger)seconds {
    NSMutableArray *comps = [NSMutableArray array];
    if (seconds >= 24*3600) {
        [comps addObject:[NSString stringWithFormat:@"%d天", (int)seconds/24/3600]];
        seconds = seconds % (24*3600);
    }
    if (seconds >= 3600) {
        [comps addObject:[NSString stringWithFormat:@"%d小时", (int)seconds/3600]];
        seconds = seconds % 3600;
    }
    if (seconds >= 60) {
        [comps addObject:[NSString stringWithFormat:@"%d分钟", (int)seconds/60]];
        seconds = seconds % 60;
    }
    if (comps.count == 0) {
//        [comps addObject:[NSString stringWithFormat:@"%d秒", (int)seconds]];
        return @"不到1分钟";
    } else {
        return [NSString stringWithFormat:@"还有%@", [comps componentsJoinedByString:@""]];
    }
}

#pragma - 获取date当天的节日
+ (NSString *)getHolidays:(NSDate *)date {
    
    NSString *todayHoliday;
    //今日阳历
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd"];
    NSString *nowdate = [dateFormatter1 stringFromDate:date];
    NSString *monthAndDay = [nowdate substringWithRange:NSMakeRange(5, 5)];
    
    //农历节日
    NSTimeInterval timeInterval_day = 60*60*24;
    NSDate *nextDay_date = [NSDate dateWithTimeInterval:timeInterval_day sinceDate:date];
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:nextDay_date];
    if ( 1 == localeComp.month && 1 == localeComp.day ) {
        return @"除夕";
    }
    NSDictionary *chineseHoliDay = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"春节", @"1-1",
                                    @"元宵节", @"1-15",
                                    @"端午节", @"5-5",
                                    @"七夕节", @"7-7",
                                    @"中元节", @"7-15",
                                    @"中秋节", @"8-15",
                                    @"重阳节", @"9-9",
                                    @"腊八节", @"12-8",
                                    @"小年", @"12-24",
                                    nil];
    localeComp = [localeCalendar components:unitFlags fromDate:date];
    NSString *key_str = [NSString stringWithFormat:@"%ld-%ld",localeComp.month,localeComp.day];
    todayHoliday = [chineseHoliDay objectForKey:key_str];
    
    //节气节日
    if (todayHoliday.length <= 0) {
        NSArray *dateArr = [nowdate componentsSeparatedByString:@"-"];
        todayHoliday = [self getLunarSpecialDate:[dateArr[0] integerValue] Month:[dateArr[1] integerValue] Day:[dateArr[2] integerValue]];
    }
    
    //阳历节日
    NSDictionary *lunDic = @{
                             @"01-01":@"元旦节",
                             @"02-14":@"情人节",
                             @"03-08":@"妇女节",
                             @"03-12":@"植树节",
                             @"05-01":@"劳动节",
                             @"06-01":@"儿童节",
                             @"08-01":@"建军节",
                             @"09-10":@"教师节",
                             @"10-01":@"国庆节",
                             @"10-24":@"程序员日",
                             @"11-11":@"光棍节",
                             @"12-25":@"圣诞节"
                             };
    if ([lunDic objectForKey:monthAndDay] != nil) {
        todayHoliday = [lunDic objectForKey:monthAndDay];
    }
    
    if (todayHoliday.length > 0) {
        return todayHoliday;
    }
    return @"";
    
}

#pragma mark - 获取节气
//以下是根据公里年月日来获取农历节气的方法：
//记录表：
const int START_YEAR =1901;
const int END_YEAR =2050;
static int32_t gLunarHolDay[]=
{
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1901
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1902
    0X96, 0XA5, 0X87, 0X96, 0X87, 0X87, 0X79, 0X69, 0X69, 0X69, 0X78, 0X78, //1903
    0X86, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X78, 0X87, //1904
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1905
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1906
    0X96, 0XA5, 0X87, 0X96, 0X87, 0X87, 0X79, 0X69, 0X69, 0X69, 0X78, 0X78, //1907
    0X86, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1908
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1909
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1910
    0X96, 0XA5, 0X87, 0X96, 0X87, 0X87, 0X79, 0X69, 0X69, 0X69, 0X78, 0X78, //1911
    0X86, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1912
    0X95, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1913
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1914
    0X96, 0XA5, 0X97, 0X96, 0X97, 0X87, 0X79, 0X79, 0X69, 0X69, 0X78, 0X78, //1915
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //1916
    0X95, 0XB4, 0X96, 0XA6, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X87, //1917
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X77, //1918
    0X96, 0XA5, 0X97, 0X96, 0X97, 0X87, 0X79, 0X79, 0X69, 0X69, 0X78, 0X78, //1919
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //1920
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X87, //1921
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X77, //1922
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X69, 0X69, 0X78, 0X78, //1923
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //1924
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X87, //1925
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1926
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1927
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1928
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //1929
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1930
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1931
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1932
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1933
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1934
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1935
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1936
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1937
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1938
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1939
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1940
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1941
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1942
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1943
    0X96, 0XA5, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1944
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //1945
    0X95, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77, //1946
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1947
    0X96, 0XA5, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //1948
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X79, 0X78, 0X79, 0X77, 0X87, //1949
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77, //1950
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78, //1951
    0X96, 0XA5, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //1952
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //1953
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X68, 0X78, 0X87, //1954
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1955
    0X96, 0XA5, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //1956
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //1957
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1958
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1959
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //1960
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1961
    0X96, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1962
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1963
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //1964
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1965
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1966
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1967
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //1968
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1969
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1970
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77, //1971
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //1972
    0XA5, 0XB5, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1973
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1974
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77, //1975
    0X96, 0XA4, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X89, 0X88, 0X78, 0X87, 0X87, //1976
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //1977
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X78, 0X87, //1978
    0X96, 0XB4, 0X96, 0XA6, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77, //1979
    0X96, 0XA4, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //1980
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X77, 0X87, //1981
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //1982
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77, //1983
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87, //1984
    0XA5, 0XB4, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //1985
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //1986
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X79, 0X78, 0X69, 0X78, 0X87, //1987
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86, //1988
    0XA5, 0XB4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //1989
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //1990
    0X95, 0XB4, 0X96, 0XA5, 0X86, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1991
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86, //1992
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //1993
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1994
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X76, 0X78, 0X69, 0X78, 0X87, //1995
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86, //1996
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //1997
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //1998
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //1999
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86, //2000
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //2001
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //2002
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //2003
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86, //2004
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //2005
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //2006
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87, //2007
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86, //2008
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //2009
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //2010
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X78, 0X87, //2011
    0X96, 0XB4, 0XA5, 0XB5, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86, //2012
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87, //2013
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //2014
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //2015
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86, //2016
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87, //2017
    0XA5, 0XB4, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //2018
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //2019
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X86, //2020
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86, //2021
    0XA5, 0XB4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //2022
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87, //2023
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96, //2024
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86, //2025
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //2026
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //2027
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96, //2028
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86, //2029
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //2030
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87, //2031
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96, //2032
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X86, //2033
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X78, 0X88, 0X78, 0X87, 0X87, //2034
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //2035
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96, //2036
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86, //2037
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //2038
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //2039
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96, //2040
    0XA5, 0XC3, 0XA5, 0XB5, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86, //2041
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87, //2042
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //2043
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X88, 0X87, 0X96, //2044
    0XA5, 0XC3, 0XA5, 0XB4, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86, //2045
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87, //2046
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87, //2047
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA5, 0X97, 0X87, 0X87, 0X88, 0X86, 0X96, //2048
    0XA4, 0XC3, 0XA5, 0XA5, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X86, //2049
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X78, 0X78, 0X87, 0X87 //2050
};

//获取节气函数：
+ (NSString *)getLunarSpecialDate:(int)iYear Month:(int)iMonth Day:(int)iDay {
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"小寒", @"大寒", @"立春", @"雨水", @"惊蛰", @"春分",
                          @"清明", @"谷雨", @"立夏", @"小满", @"芒种", @"夏至",
                          @"小暑", @"大暑", @"立秋", @"处暑", @"白露", @"秋分",
                          @"寒露", @"霜降", @"立冬", @"小雪", @"大雪", @"冬至", nil];
    int array_index = (iYear - START_YEAR)*12+iMonth -1 ;
    int64_t flag = gLunarHolDay[array_index];
    int64_t day;
    if(iDay <15)
        day= 15 - ((flag>>4)&0x0f);
    else
        day = ((flag)&0x0f)+15;
    int index = -1;
    if(iDay == day){
        index = (iMonth-1) *2 + (iDay>15? 1: 0);
    }
    if ( index >= 0 && index < [chineseDays count] ) {
        return [chineseDays objectAtIndex:index];
    } else {
        return nil;
    }
}

@end
