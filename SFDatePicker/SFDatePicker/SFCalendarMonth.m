//
//  SFCalendarMonth.m
//  SFDatePicker
//
//  Created by yangzexin on 12/4/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFCalendarMonth.h"
#import "NSDate+SFAddition.h"

static NSString *SFCalendarMonthCacheNumberOfMonthsKey = @"SFCalendarMonthCacheNumberOfMonthsKey";
static NSString *SFCalendarMonthCacheCalendarMonthsKey = @"SFCalendarMonthCacheCalendarMonthsKey";

@interface SFCalendarMonthCache ()

@property (nonatomic, strong) NSMutableDictionary *keyYyyyMMddValueCalendarMonthCacheInfoDictionary;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SFCalendarMonthCache

+ (instancetype)sharedCache
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    
    self.keyYyyyMMddValueCalendarMonthCacheInfoDictionary = [NSMutableDictionary dictionary];
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:@"yyyyMMdd"];
    
    return self;
}

- (NSArray *)calendarMonthsWithDate:(NSDate *)date numberOfMonths:(NSInteger)numberOfMonths
{
    NSArray *calendarMonths = nil;
    @synchronized(self){
        NSString *yyyyMMddOfDate = [self.dateFormatter stringFromDate:date];
        NSDictionary *calendarMonthCacheInfoDictionary = [self.keyYyyyMMddValueCalendarMonthCacheInfoDictionary objectForKey:yyyyMMddOfDate];
        if (calendarMonthCacheInfoDictionary) {
            NSNumber *numberOfMonthsNumber = [calendarMonthCacheInfoDictionary objectForKey:SFCalendarMonthCacheNumberOfMonthsKey];
            if ([numberOfMonthsNumber integerValue] == numberOfMonths) {
                calendarMonths = [calendarMonthCacheInfoDictionary objectForKey:SFCalendarMonthCacheCalendarMonthsKey];
            } else {
                [self.keyYyyyMMddValueCalendarMonthCacheInfoDictionary removeObjectForKey:yyyyMMddOfDate];
            }
        }
        if (calendarMonths == nil) {
            NSMutableArray *tmpCalendarMonths = [NSMutableArray array];
            NSDateComponents *dateComponents = [NSDateComponents new];
            for (NSInteger i = 0; i < numberOfMonths; ++i) {
                [dateComponents setMonth:i];
                NSDate *nextMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
                SFCalendarMonth *calendarMonth = [SFCalendarMonth new];
                [calendarMonth buildWithDate:nextMonthDate];
                [tmpCalendarMonths addObject:calendarMonth];
            }
            calendarMonths = tmpCalendarMonths;
            
            [self.keyYyyyMMddValueCalendarMonthCacheInfoDictionary removeAllObjects];
            NSDictionary *infoDictionary = @{
                                             SFCalendarMonthCacheCalendarMonthsKey : tmpCalendarMonths,
                                             SFCalendarMonthCacheNumberOfMonthsKey : [NSNumber numberWithInteger:numberOfMonths]
                                             };
            [self.keyYyyyMMddValueCalendarMonthCacheInfoDictionary setObject:infoDictionary forKey:yyyyMMddOfDate];
        }
    }
    return calendarMonths;
}

- (void)prepareCacheWithDate:(NSDate *)date numberOfMonths:(NSInteger)numberOfMonths
{
    [self calendarMonthsWithDate:date numberOfMonths:numberOfMonths];
}

- (void)clearCache
{
    [self.keyYyyyMMddValueCalendarMonthCacheInfoDictionary removeAllObjects];
}

@end

@interface SFCalendarMonthDay ()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *day;
@property (nonatomic, assign) NSInteger numberOfDayIntervalSinceToday;
@property (nonatomic, getter = isAdditionalDay) BOOL additionalDay;

@end

@implementation SFCalendarMonthDay

@end

@interface SFCalendarMonth ()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *weekIndexStrings;
@property (nonatomic, strong) NSArray *monthDays;
@property (nonatomic, assign) NSInteger numberOfAdditionalSuffixDays;
@property (nonatomic, assign) NSInteger numberOfAdditionalPrefixDays;
@property (nonatomic, assign) NSInteger numberOfMonthDays;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SFCalendarMonth

- (id)init
{
    self = [super init];
    
    _dateFormatter = [NSDateFormatter new];
    
    return self;
}

NSDate *SFCalendarMonthGetBeginDate(NSDate *date, NSInteger *outNumberOfAdditionalDays)
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSDate *beginDate = nil;
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDate *monthBeginDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:date]];
    [dateFormatter setDateFormat:@"c"];
    NSString *weekIndex = [dateFormatter stringFromDate:monthBeginDate];
    NSInteger numberOfAdditionalDays = [weekIndex integerValue] - 1;
    beginDate = [monthBeginDate dateByAddingNumberOfDays:-numberOfAdditionalDays];
    if (outNumberOfAdditionalDays) {
        *outNumberOfAdditionalDays = numberOfAdditionalDays;
    }
    return beginDate;
}

NSDate *SFCalendarMonthGetEndDate(NSDate *date, NSInteger *outNumberOfAdditionalDays)
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSDate *endDate = nil;
    NSDateComponents *dateComponents = [NSDateComponents new];
    [dateComponents setMonth:1];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDate *nextMonthBeginDate =
    [dateFormatter dateFromString:[dateFormatter stringFromDate:[[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0]]];
    NSDate *currentMonthLastDay = [nextMonthBeginDate dateByAddingNumberOfDays:-1];
    [dateFormatter setDateFormat:@"c"];
    NSString *weekIndex = [dateFormatter stringFromDate:currentMonthLastDay];
    NSInteger numberOfAdditionalDays = 7 - [weekIndex integerValue];
    if (outNumberOfAdditionalDays) {
        *outNumberOfAdditionalDays = numberOfAdditionalDays;
    }
    endDate = [currentMonthLastDay dateByAddingNumberOfDays:numberOfAdditionalDays];
    return endDate;
}

NSArray *SFCalendarMonthGetWeekIndexStrings(NSDate *beginDate)
{
    NSArray *weekIndexStrings = nil;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSMutableArray *tmpWeekIndexStrings = [NSMutableArray array];
    NSDateComponents *dateComponents = [NSDateComponents new];
    [dateFormatter setDateFormat:@"ccc"];
    for (NSInteger i = 0; i < 7; ++i) {
        [dateComponents setDay:i];
        NSDate *nextDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:beginDate options:0];
        NSString *weekIndexString = [[dateFormatter stringFromDate:nextDate] stringByReplacingOccurrencesOfString:@"周" withString:@""];
        [tmpWeekIndexStrings addObject:weekIndexString];
    }
    weekIndexStrings = tmpWeekIndexStrings;
    
    return weekIndexStrings;
}

NSArray *SFCalendarMonthGetMonthDays(NSDate *beginDate, NSInteger numberOfMonthDays, NSInteger numberOfAdditionalPrefixDays, NSInteger numberOfAdditionalSuffixDays)
{
    NSMutableArray *tmpMonthDays = [NSMutableArray array];
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:nowDate];
    nowDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    dateComponents = [NSDateComponents new];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd"];
    for (NSInteger dayIndex = 0; dayIndex < numberOfMonthDays; ++dayIndex) {
        [dateComponents setDay:dayIndex];
        NSDate *dayDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:beginDate options:0];
        NSInteger numberOfDayIntervalSinceNow = ([dayDate timeIntervalSince1970] - [nowDate timeIntervalSince1970]) / 86400;
        NSString *dayString = [dateFormatter stringFromDate:dayDate];
        SFCalendarMonthDay *monthDay = [SFCalendarMonthDay new];
        monthDay.date = dayDate;
        monthDay.numberOfDayIntervalSinceToday = numberOfDayIntervalSinceNow;
        monthDay.day = dayString;
        monthDay.additionalDay = (dayIndex < numberOfAdditionalPrefixDays) || (numberOfMonthDays - dayIndex <= numberOfAdditionalSuffixDays);
        [tmpMonthDays addObject:monthDay];
    }
    
    return tmpMonthDays;
}

NSInteger SFCalendarMonthGetNumberOfDays(NSDate *date)
{
    NSInteger numberOfCalendarMonthDays = 0;
    NSDate *tmpBeginDate = SFCalendarMonthGetBeginDate(date, NULL);
    NSDate *tmpEndDate = SFCalendarMonthGetEndDate(date, NULL);
    numberOfCalendarMonthDays = [tmpEndDate numberOfDayIntervalsWithDate:tmpBeginDate] + 1;
    return numberOfCalendarMonthDays;
}

- (NSString *)_monthStringWithDate:(NSDate *)date
{
    self.dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"LLLL yyyy" options:0 locale:[NSLocale currentLocale]];
    NSString *monthString = [self.dateFormatter stringFromDate:date];
    return monthString;
}

- (void)buildWithDate:(NSDate *)date
{
    @synchronized(self){
        self.date = date;
        
        self.title = [self _monthStringWithDate:self.date];
        
        NSInteger numberOfPrefixDays = 0;
        self.beginDate = SFCalendarMonthGetBeginDate(self.date, &numberOfPrefixDays);
        self.numberOfAdditionalPrefixDays = numberOfPrefixDays;
        
        NSInteger numberOfSuffixDays = 0;
        self.endDate = SFCalendarMonthGetEndDate(self.date, &numberOfSuffixDays);
        self.numberOfAdditionalSuffixDays = numberOfSuffixDays;
        
        self.numberOfMonthDays = [self.endDate numberOfDayIntervalsWithDate:self.beginDate] + 1;
        
        if (self.weekIndexStrings.count == 0) {
            self.weekIndexStrings = SFCalendarMonthGetWeekIndexStrings(self.beginDate);
        }
        
        self.monthDays = SFCalendarMonthGetMonthDays(self.beginDate, self.numberOfMonthDays, self.numberOfAdditionalPrefixDays, self.numberOfAdditionalSuffixDays);
    }
}

- (NSInteger)numberOfCalendarMonthDaysWithDate:(NSDate *)date
{
    NSInteger numberOfCalendarMonthDays = 0;
    NSDate *tmpBeginDate = SFCalendarMonthGetBeginDate(date, NULL);
    NSDate *tmpEndDate = SFCalendarMonthGetEndDate(date, NULL);
    numberOfCalendarMonthDays = [tmpEndDate numberOfDayIntervalsWithDate:tmpBeginDate] + 1;
    return numberOfCalendarMonthDays;
}

- (NSArray *)weekIndexStringsWithDate:(NSDate *)date
{
    return SFCalendarMonthGetWeekIndexStrings(SFCalendarMonthGetBeginDate(date, NULL));
}

- (void)buildAsyncWithDate:(NSDate *)date completion:(void(^)())completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self buildWithDate:date];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    });
}

@end
