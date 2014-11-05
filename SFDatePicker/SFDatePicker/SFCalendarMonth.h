//
//  SFCalendarMonth.h
//  SFDatePicker
//
//  Created by yangzexin on 12/4/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFCalendarMonth;

extern NSDate *SFCalendarMonthGetBeginDate(NSDate *date, NSInteger *outNumberOfAdditionalDays);
extern NSDate *SFCalendarMonthGetEndDate(NSDate *date, NSInteger *outNumberOfAdditionalDays);
extern NSArray *SFCalendarMonthGetWeekIndexStrings(NSDate *beginDate);
extern NSArray *SFCalendarMonthGetMonthDays(NSDate *beginDate, NSInteger numberOfMonthDays, NSInteger numberOfAdditionalPrefixDays, NSInteger numberOfAdditionalSuffixDays);
extern NSInteger SFCalendarMonthGetNumberOfDays(NSDate *date);

@interface SFCalendarMonthCache : NSObject

+ (instancetype)sharedCache;

- (void)prepareCacheWithDate:(NSDate *)date numberOfMonths:(NSInteger)numberOfMonths;
- (NSArray *)calendarMonthsWithDate:(NSDate *)date numberOfMonths:(NSInteger)numberOfMonths;
- (void)clearCache;

@end

@interface SFCalendarMonthDay : NSObject

@property (nonatomic, readonly, strong) NSDate *date;
@property (nonatomic, readonly, strong) NSString *day;
@property (nonatomic, readonly, assign) NSInteger numberOfDayIntervalSinceToday;
@property (nonatomic, readonly, getter = isAdditionalDay) BOOL additionalDay;

@end

@interface SFCalendarMonth : NSObject

@property (nonatomic, readonly, strong) NSDate *date;
@property (nonatomic, readonly, strong) NSDate *beginDate;
@property (nonatomic, readonly, strong) NSDate *endDate;
@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly, strong) NSArray *weekIndexStrings;
@property (nonatomic, readonly, strong) NSArray *monthDays;
@property (nonatomic, readonly, assign) NSInteger numberOfAdditionalSuffixDays;
@property (nonatomic, readonly, assign) NSInteger numberOfAdditionalPrefixDays;

- (NSInteger)numberOfCalendarMonthDaysWithDate:(NSDate *)date;

- (void)buildWithDate:(NSDate *)date;
- (void)buildAsyncWithDate:(NSDate *)date completion:(void(^)())completion;

@end
