//
//  SFMonthView.m
//  SFDatePicker
//
//  Created by yangzexin on 12/2/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "SFMonthView.h"
#import "SFLineView.h"
#import "UIView+SFAddition.h"
#import "NSDate+SFAddition.h"
#import "UIImage+SFAddition.h"

@interface SFMonthView ()

@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, assign) NSInteger numberOfAdditionalPrefixDays;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) NSInteger numberOfAdditionalSuffixDays;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *weekIndexStrings;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *weekIndexView;
@property (nonatomic, strong) NSArray *weekIndexLabels;
@property (nonatomic, strong) UIView *dayTilesViewContainerView;
@property (nonatomic, strong) UIView *dayTilesView;
@property (nonatomic, strong) NSArray *dayTileViews;
@property (nonatomic, assign) CGFloat dayTileViewWidth;
@property (nonatomic, assign) CGFloat dayTileViewHeight;
@property (nonatomic, strong) UIView *separatorLinesView;
@property (nonatomic, assign) CGFloat suitableHeight;
@property (nonatomic, assign) NSInteger selectedDayIndex;

@property (nonatomic, strong) UIImage *selectionIndicatorImage;
@property (nonatomic, assign) BOOL buildingCalendar;

@end

@implementation SFMonthView

- (void)initialize
{
    [super initialize];
    self.selectedDayIndex = -1;
    
    self.selectedTileColor = [UIColor colorWithRed:22.0f/255.0f green:144.0f/255.0f blue:206.0f/255.0f alpha:1.0f];
    self.calendarMonth = [SFCalendarMonth new];
    self.dateFormatter = [NSDateFormatter new];
    
    self.separatorLinesView = [[UIView alloc] initWithFrame:self.bounds];
    self.separatorLinesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.separatorLinesView.userInteractionEnabled = NO;
    [self addSubview:self.separatorLinesView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 38)];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    
    self.weekIndexView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    self.weekIndexView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.weekIndexView.backgroundColor = [UIColor clearColor];
    self.weekIndexView.userInteractionEnabled = NO;
    [self addSubview:self.weekIndexView];
    
    self.dayTilesViewContainerView = [UIView new];
    self.dayTilesViewContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.dayTilesViewContainerView.backgroundColor = [UIColor clearColor];
    self.dayTilesViewContainerView.clipsToBounds = YES;
    [self addSubview:self.dayTilesViewContainerView];
    
    self.dayTilesView = [[UIView alloc] init];
    self.dayTilesView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.dayTilesView.backgroundColor = [UIColor clearColor];
    self.dayTilesView.userInteractionEnabled = YES;
    [self.dayTilesView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dayTileViewsTapGestureRecognizer:)]];
    [self.dayTilesViewContainerView addSubview:self.dayTilesView];
}

- (UIColor *)_selectionIndicatorColor
{
    return self.selectedTileColor;
}

- (void)_appendSeparatorLineToView:(UIView *)view color:(UIColor *)color
{
    [self _appendSeparatorLineToView:view color:color y:view.frame.size.height - 1];
}

- (void)_appendSeparatorLineToView:(UIView *)view color:(UIColor *)color y:(CGFloat)y
{
    SFLineView *lineView = [[SFLineView alloc] initWithFrame:CGRectMake(0, y, view.frame.size.width, 1)];
    lineView.color = color;
    lineView.alignment = SFLineViewAlignmentBottom;
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [view addSubview:lineView];
}

- (UIColor *)_separatorLineColor
{
    return [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView *subview in [self.separatorLinesView subviews]) {
        [subview removeFromSuperview];
    }
    
    UIView *headerView = nil;
    
    NSString *monthString = self.title;
    if ([self.delegate respondsToSelector:@selector(monthView:viewForHeaderWithMonthString:)]) {
        headerView = [self.delegate monthView:self viewForHeaderWithMonthString:monthString];
    }
    if (headerView == nil) {
        headerView = self.titleLabel;
        self.titleLabel.text = monthString;
    }
    if (headerView.superview) {
        [headerView removeFromSuperview];
    }
    [self addSubview:headerView];
    
    CGRect tmpRect = self.weekIndexView.frame;
    tmpRect.origin.y = [headerView bottom];
    self.weekIndexView.frame = tmpRect;
    CGFloat weekIndexWidth = self.weekIndexView.frame.size.width / 7;
    if (self.weekIndexLabels.count == 0) {
        NSMutableArray *tmpWeekIndexLabels = [NSMutableArray array];
        for (NSInteger i = 0; i < self.weekIndexStrings.count; ++i) {
            UILabel *weekIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * weekIndexWidth, 0, weekIndexWidth, self.weekIndexView.frame.size.height)];
            weekIndexLabel.backgroundColor = [UIColor clearColor];
            weekIndexLabel.textColor = [UIColor darkGrayColor];
            weekIndexLabel.font = [UIFont systemFontOfSize:14.0f];
            weekIndexLabel.textAlignment = UITextAlignmentCenter;
            [self.weekIndexView addSubview:weekIndexLabel];
            [tmpWeekIndexLabels addObject:weekIndexLabel];
        }
        self.weekIndexLabels = tmpWeekIndexLabels;
    }
    for (NSInteger weekIndex = 0; weekIndex < self.weekIndexLabels.count; ++weekIndex) {
        UILabel *weekIndexLabel = [self.weekIndexLabels objectAtIndex:weekIndex];
        NSString *weekIndexString = [self.weekIndexStrings objectAtIndex:weekIndex];
        weekIndexLabel.text = weekIndexString;
        if ([self.delegate respondsToSelector:@selector(monthView:decorateWeekIndexLabel:weekIndexString:)]) {
            [self.delegate monthView:self decorateWeekIndexLabel:weekIndexLabel weekIndexString:weekIndexString];
        }
        weekIndexLabel.frame = CGRectMake(weekIndex * weekIndexWidth, 0, weekIndexWidth, self.weekIndexView.frame.size.height);
    }
    
    [self _appendSeparatorLineToView:self.separatorLinesView color:[self _separatorLineColor] y:[self.weekIndexView bottom] - 1];
    
    NSInteger numberOfDayTiles = [self.endDate numberOfDayIntervalsWithDate:self.beginDate] + 1;
    [self _layoutDayTilesViewWithNumberOfDayTiles:numberOfDayTiles];
    
    for (NSInteger i = 0; i < numberOfDayTiles / 7; ++i) {
        [self _appendSeparatorLineToView:self.separatorLinesView color:[self _separatorLineColor] y:self.dayTilesViewContainerView.frame.origin.y + self.dayTileViewHeight * (i + 1)];
    }
    self.suitableHeight = [self.dayTilesViewContainerView bottom];
}

- (void)_layoutDayTilesViewWithNumberOfDayTiles:(NSInteger)numberOfDayTiles
{
    if (self.dayTileViews.count != numberOfDayTiles) {
        NSMutableArray *tmpDayTileViews = [NSMutableArray arrayWithArray:self.dayTileViews];
        for (NSInteger i = tmpDayTileViews.count; i < numberOfDayTiles; ++i) {
            UIView *view = [[UIView alloc] init];
            [tmpDayTileViews addObject:view];
            [self.dayTilesView addSubview:view];
        }
        self.dayTileViews = tmpDayTileViews;
    }
    self.dayTileViewWidth = self.frame.size.width / 7;
    self.dayTileViewHeight = self.dayTileViewWidth;
    CGFloat dayTileWidth = self.dayTileViewWidth;
    CGFloat dayTileHeight = self.dayTileViewHeight;
    if (self.selectionIndicatorImage == nil
        || self.selectionIndicatorImage.size.width != dayTileWidth
        || self.selectionIndicatorImage.size.height != dayTileHeight) {
        self.selectionIndicatorImage = [UIImage roundImageWithBackgroundColor:[self _selectionIndicatorColor]
                                                                  borderColor:nil
                                                                         size:CGSizeMake(20, 20)
                                                                 cornerRadius:3
                                                                hideTopCorner:NO
                                                             hideBottomCorner:NO];
        self.selectionIndicatorImage = [self.selectionIndicatorImage stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    }
    self.dayTilesViewContainerView.frame = CGRectMake(0, self.weekIndexView.bottom, self.frame.size.width, dayTileHeight * numberOfDayTiles / 7);
    for (NSInteger i = 0; i < self.dayTileViews.count; ++i) {
        UIView *tileView = [self.dayTileViews objectAtIndex:i];
        CGRect tmpRect = CGRectMake((i % 7) * dayTileWidth, i / 7 * dayTileHeight, dayTileWidth, dayTileHeight);
        tileView.frame = tmpRect;
        SFCalendarMonthDay *monthDay = [self.calendarMonth.monthDays objectAtIndex:i];
        BOOL additionalDate = (i < self.numberOfAdditionalPrefixDays) || (numberOfDayTiles - i <= self.numberOfAdditionalSuffixDays);
        [self _decorateDayTileView:tileView day:monthDay additionalDate:additionalDate selected:self.selectedDayIndex == i];
        tileView.frame = tmpRect;
    }
    self.dayTilesView.frame = self.dayTilesViewContainerView.bounds;
}

- (void)_decorateDayTileView:(UIView *)dayTileView day:(SFCalendarMonthDay *)day additionalDate:(BOOL)additionalDate selected:(BOOL)selected
{
    if ([self.delegate respondsToSelector:@selector(monthView:decorateDayTileView:day:)]) {
        [self.delegate monthView:self decorateDayTileView:dayTileView day:day];
    } else {
        UILabel *dayLabel = (id)[dayTileView viewWithTag:1001];
        UIImageView *selectionIndicatorView = (id)[dayTileView viewWithTag:1002];
        if (dayLabel == nil) {
            CGFloat padding = 2;
            selectionIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(padding,
                                                                                   padding + ([UIScreen mainScreen].scale > 1.0f ? 0.5f : 1),
                                                                                   dayTileView.frame.size.width - padding * 2,
                                                                                   dayTileView.frame.size.height - padding * 2)];
            selectionIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
            selectionIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            selectionIndicatorView.image = self.selectionIndicatorImage;
            selectionIndicatorView.tag = 1002;
            selectionIndicatorView.hidden = YES;
            [dayTileView addSubview:selectionIndicatorView];
            
            dayLabel = [[UILabel alloc] initWithFrame:dayTileView.bounds];
            dayLabel.backgroundColor = [UIColor clearColor];
            dayLabel.font = [UIFont systemFontOfSize:18.0f];
            dayLabel.tag = 1001;
            dayLabel.textAlignment = UITextAlignmentCenter;
            dayLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [dayTileView addSubview:dayLabel];
        }
        dayLabel.textColor = additionalDate ? [UIColor lightGrayColor] : [UIColor blackColor];
        if ([self.delegate respondsToSelector:@selector(monthView:decorateDayLabel:day:selected:)]) {
            [self.delegate monthView:self decorateDayLabel:dayLabel day:day selected:selected];
        }
        dayLabel.textColor = selected ? [UIColor whiteColor] : dayLabel.textColor;
        selectionIndicatorView.hidden = !selected;
        NSString *text = nil;
        if ([self.delegate respondsToSelector:@selector(monthView:labelForDay:)]) {
            text = [self.delegate monthView:self labelForDay:day];
        }
        if (text.length == 0) {
            text = day.day;
        }
        dayLabel.text = text;
    }
}

- (void)_dayTileViewsTapGestureRecognizer:(UITapGestureRecognizer *)gr
{
    CGPoint position = [gr locationInView:gr.view];
    NSInteger column = position.x / self.dayTileViewWidth;
    NSInteger row = position.y / self.dayTileViewHeight;
    NSInteger dayIndex = row * 7 + column;
    self.selectedDayIndex = dayIndex;
    SFCalendarMonthDay *day = [self.calendarMonth.monthDays objectAtIndex:dayIndex];
    BOOL shouldSelectDate = YES;
    if ([self.delegate respondsToSelector:@selector(monthView:shouldSelectDay:)]) {
        shouldSelectDate = [self.delegate monthView:self shouldSelectDay:day];
    }
    if (shouldSelectDate) {
        self.selectedDate = day.date;
        if ([self.delegate respondsToSelector:@selector(monthView:didSelectDate:)]) {
            [self.delegate monthView:self didSelectDate:self.selectedDate];
        }
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    if (_selectedDate == nil) {
        self.selectedDayIndex = -1;
    } else if (self.buildingCalendar == NO) {
        [self _calculateSelectDayIndexUsingSelectedDate];
    }
    [self setNeedsLayout];
}

- (void)setCalendarMonth:(SFCalendarMonth *)calendarMonth
{
    _calendarMonth = calendarMonth;
    [self _calendarMonthBuildFinish];
}

- (void)_calculateSelectDayIndexUsingSelectedDate
{
    NSTimeInterval timeInterval = [self.selectedDate timeIntervalSince1970];
    if (timeInterval >= [self.beginDate timeIntervalSince1970] && timeInterval < [self.endDate timeIntervalSince1970]) {
        self.selectedDayIndex = [self.selectedDate numberOfDayIntervalsByComparingWithDate:self.beginDate usingZeroHourDate:YES];
    } else {
        self.selectedDayIndex = -1;
    }
}

- (void)_calendarMonthBuildFinish
{
    self.beginDate = self.calendarMonth.beginDate;
    self.endDate = self.calendarMonth.endDate;
    self.numberOfAdditionalPrefixDays = self.calendarMonth.numberOfAdditionalPrefixDays;
    self.numberOfAdditionalSuffixDays = self.calendarMonth.numberOfAdditionalSuffixDays;
    self.title = self.calendarMonth.title;
    self.weekIndexStrings = self.calendarMonth.weekIndexStrings;
    if (self.selectedDate) {
        [self _calculateSelectDayIndexUsingSelectedDate];
    }
    self.buildingCalendar = NO;
    [self setNeedsLayout];
}

- (void)setSelectedTileColor:(UIColor *)selectedTileColor
{
    _selectedTileColor = selectedTileColor;
    [self setNeedsLayout];
}

- (void)fitHeightToSuitableHeight
{
    if (self.suitableHeight == 0 && self.calendarMonth != nil) {
        CGFloat height = 0;
        if ([self.delegate respondsToSelector:@selector(monthView:viewForHeaderWithMonthString:)]) {
            height = [self.delegate monthView:self viewForHeaderWithMonthString:@""].frame.size.height;
        } else {
            height = self.titleLabel.frame.size.height;
        }
        height += self.weekIndexView.frame.size.height;
        NSInteger numberOfDayTiles = [self.calendarMonth numberOfCalendarMonthDaysWithDate:self.calendarMonth.date];
        height += (self.frame.size.width * numberOfDayTiles / 49);
        self.suitableHeight = height;
    }
    CGRect tmpRect = self.frame;
    tmpRect.size.height = [self suitableHeight];
    self.frame = tmpRect;
}

@end
