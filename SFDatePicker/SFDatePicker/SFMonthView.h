//
//  SFMonthView.h
//  SFDatePicker
//
//  Created by yangzexin on 12/2/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIBCompatibleView.h"
#import "SFCalendarMonth.h"

@class SFMonthView;
@class SFCalendarMonthDay;

@protocol SFMonthViewDelegate <NSObject>

@optional
- (UIView *)monthView:(SFMonthView *)monthView viewForHeaderWithMonthString:(NSString *)monthString;
- (void)monthView:(SFMonthView *)monthView decorateWeekIndexLabel:(UILabel *)label weekIndexString:(NSString *)weekIndexString;
- (void)monthView:(SFMonthView *)monthView decorateDayTileView:(UIView *)view day:(SFCalendarMonthDay *)day;
- (NSString *)monthView:(SFMonthView *)monthView labelForDay:(SFCalendarMonthDay *)day;
- (void)monthView:(SFMonthView *)monthView decorateDayLabel:(UILabel *)label day:(SFCalendarMonthDay *)day selected:(BOOL)selected;
- (BOOL)monthView:(SFMonthView *)monthView shouldSelectDay:(SFCalendarMonthDay *)day;
- (void)monthView:(SFMonthView *)monthView didSelectDate:(NSDate *)date;

@end

@interface SFMonthView : SFIBCompatibleView

@property (nonatomic, weak) id<SFMonthViewDelegate> delegate;

@property (nonatomic, strong) SFCalendarMonth *calendarMonth;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) UIColor *selectedTileColor;

@property (nonatomic, readonly) CGFloat suitableHeight;

- (void)fitHeightToSuitableHeight;

@end
