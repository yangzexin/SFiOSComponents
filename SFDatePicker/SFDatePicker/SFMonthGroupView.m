//
//  SFMonthGroupView.m
//  SFDatePicker
//
//  Created by yangzexin on 12/4/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFMonthGroupView.h"
#import "SFMonthView.h"

@interface SFMonthGroupView () <SFMonthViewDelegate>

@property (nonatomic, assign) NSInteger numberOfMonths;
@property (nonatomic, strong) NSDate *beginMonthDate;
@property (nonatomic, strong) NSArray *calendarMonths;

@end

@implementation SFMonthGroupView

- (void)setBeginMonthDate:(NSDate *)beginMonthDate numberOfMonths:(NSInteger)numberOfMonths
{
    self.beginMonthDate = beginMonthDate;
    self.numberOfMonths = numberOfMonths;
    
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
    
    self.calendarMonths = [[SFCalendarMonthCache sharedCache] calendarMonthsWithDate:beginMonthDate numberOfMonths:numberOfMonths];
    for (NSInteger i = 0; i < self.numberOfMonths; ++i) {
        SFMonthView *monthView = [[SFMonthView alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width - 10, 0)];
        monthView.selectedTileColor = [UIColor colorWithRed:1.0 green:120.0f/255.0f blue:66.0f/255.0f alpha:1.0f];
        monthView.delegate = self;
        monthView.selectedDate = self.selectedDate;
        monthView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        monthView.calendarMonth = [_calendarMonths objectAtIndex:i];
        [self addSubview:monthView];
    }
}

- (void)fitToSuitableHeight
{
    CGRect tmpRect;
    CGFloat totalHeight = 0.0f;
    CGFloat spacing = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50 : 15;
    NSArray *subviews = [self subviews];
    for (NSInteger i = 0; i < subviews.count; ++i) {
        SFMonthView *monthView = [subviews objectAtIndex:i];
        tmpRect = monthView.frame;
        tmpRect.origin.y = totalHeight;
        monthView.frame = tmpRect;
        [monthView fitHeightToSuitableHeight];
        totalHeight += monthView.frame.size.height + spacing;
    }
    tmpRect = self.frame;
    tmpRect.size.height = totalHeight - spacing;
    self.frame = tmpRect;
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    for (SFMonthView *monthView in [self subviews]) {
        monthView.selectedDate = selectedDate;
    }
}

- (CGFloat)yPositionForMonthDate:(NSDate *)monthDate
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDateComponents *dateComponents = [NSDateComponents new];
    [dateComponents setMonth:1];
    NSArray *subviews = [self subviews];
    NSInteger targetMonthViewIndex = -1;
    CGFloat tmpY = 0;
    NSTimeInterval timeInterval = [monthDate timeIntervalSince1970];
    for (NSInteger monthViewIndex = 0; monthViewIndex < [subviews count]; ++monthViewIndex) {
        SFMonthView *monthView = [subviews objectAtIndex:monthViewIndex];
        NSDate *monthBeginDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:monthView.calendarMonth.date]];
        NSDate *nextMonthBeginDate =
        [dateFormatter dateFromString:[dateFormatter stringFromDate:[[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:monthView.calendarMonth.date options:0]]];
        
        if (timeInterval >= [monthBeginDate timeIntervalSince1970] && timeInterval < [nextMonthBeginDate timeIntervalSince1970]) {
            targetMonthViewIndex = monthViewIndex;
            break;
        } else {
            tmpY += monthView.frame.size.height;
        }
    }
    if (targetMonthViewIndex == -1) {
        tmpY = 0;
    }
    return tmpY;
}

#pragma mark - SFMonthViewDelegate
- (void)monthView:(SFMonthView *)monthView didSelectDate:(NSDate *)date
{
    self.selectedDate = date;
    if ([self.delegate respondsToSelector:@selector(monthGroupView:didSelectDate:)]) {
        [self.delegate monthGroupView:self didSelectDate:self.selectedDate];
    }
    for (SFMonthView *tmpMonthView in [self subviews]) {
        if (tmpMonthView != monthView) {
            tmpMonthView.selectedDate = nil;
        }
    }
}

- (NSString *)monthView:(SFMonthView *)monthView labelForDay:(SFCalendarMonthDay *)day
{
    NSString *dayString = day.day;
    switch (day.numberOfDayIntervalSinceToday) {
        case 0:
            dayString = @"今天";
            break;
        case 1:
            dayString = @"明天";
            break;
        case 2:
            dayString = @"后天";
            break;
            
        default:
            dayString = day.day;
            break;
    }
    return dayString;
}

- (void)monthView:(SFMonthView *)monthView decorateDayLabel:(UILabel *)label day:(SFCalendarMonthDay *)day selected:(BOOL)selected
{
    if (day.isAdditionalDay) {
        label.superview.hidden = YES;
    } else {
        if (day.numberOfDayIntervalSinceToday >= 0 && day.numberOfDayIntervalSinceToday < 3) {
            if (day.numberOfDayIntervalSinceToday == 0) {
                label.textColor = [UIColor colorWithRed:1.0f green:68.0f/255.0f blue:0 alpha:1.0f];
            }
            label.font = [UIFont systemFontOfSize:14.0f];
        } else if (day.numberOfDayIntervalSinceToday < 0) {
//            label.superview.hidden = YES;
            label.textColor = [UIColor lightGrayColor];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(monthGroupView:decorateDayLabel:day:selected:)]) {
        [self.delegate monthGroupView:self decorateDayLabel:label day:day selected:selected];
    }
}

- (BOOL)monthView:(SFMonthView *)monthView shouldSelectDay:(SFCalendarMonthDay *)day
{
    BOOL should = YES;
    if ([self.delegate respondsToSelector:@selector(monthGroupView:shouldSelectDay:)]) {
        should = [self.delegate monthGroupView:self shouldSelectDay:day];
    }
    return should;
}

@end
