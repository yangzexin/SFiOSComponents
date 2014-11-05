//
//  SFMonthGroupView.h
//  SFDatePicker
//
//  Created by yangzexin on 12/4/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIBCompatibleView.h"
#import "SFCalendarMonth.h"

@class SFMonthGroupView;

@protocol SFMonthGroupViewDelegate <NSObject>

@optional
- (BOOL)monthGroupView:(SFMonthGroupView *)monthGroupView shouldSelectDay:(SFCalendarMonthDay *)day;
- (void)monthGroupView:(SFMonthGroupView *)monthGroupView didSelectDate:(NSDate *)date;
- (void)monthGroupView:(SFMonthGroupView *)monthGroupView decorateDayLabel:(UILabel *)label day:(SFCalendarMonthDay *)day selected:(BOOL)selected;

@end

@interface SFMonthGroupView : SFIBCompatibleView

@property (nonatomic, weak) id<SFMonthGroupViewDelegate> delegate;
@property (nonatomic, strong) NSDate *selectedDate;

- (void)setBeginMonthDate:(NSDate *)beginMonthDate numberOfMonths:(NSInteger)numberOfMonths;
- (CGFloat)yPositionForMonthDate:(NSDate *)monthDate;
- (void)fitToSuitableHeight;

@end
