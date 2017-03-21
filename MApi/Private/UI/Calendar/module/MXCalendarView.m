//
//  MXCalendarView.m
//  NewStock
//
//  Created by IOS_HMX on 16/7/6.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import "MXCalendarView.h"
#import "MXDefine.h"

#define kVisibleCount 5
#define kItemWidth      CGRectGetWidth(self.frame)/kVisibleCount
#define kItemHeight   CGRectGetHeight(self.frame)
#define kDateKey @"NORMALDAY"


//static inline NSString *getNextDateFormDateString(NSString *string)
//{
//    int year    = [[string substringWithRange:NSMakeRange(0, 4)]intValue];
//    int month   = [[string substringWithRange:NSMakeRange(5, 2)]intValue];
//    int day     = [[string substringWithRange:NSMakeRange(8, 2)]intValue];
//    day++;
//    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
//        if (day == 32) {
//            day = 1;
//            month ++;
//            if (month == 13) {
//                month = 1;
//                year ++;
//            }
//        }
//    }else if (month == 2)
//    {
//        if (day == 30) {
//            day = 1;
//            month ++;
//            if (month == 13) {
//                month = 1;
//                year ++;
//            }
//        }
//    }else
//    {
//        if (day == 31) {
//            day = 1;
//            month ++;
//            if (month == 13) {
//                month = 1;
//                year ++;
//            }
//        }
//    }
//    return [NSString stringWithFormat:@"%d-%02d-%02d",year,month,day];
//};
//static inline NSString * getPreviousDateFormDateString(NSString *string)
//{
//    int year    = [[string substringWithRange:NSMakeRange(0, 4)]intValue];
//    int month   = [[string substringWithRange:NSMakeRange(5, 2)]intValue];
//    int day     = [[string substringWithRange:NSMakeRange(8, 2)]intValue];
//    day--;
//    if (day  == 0) {
//        month --;
//        if (month == 0) {
//            month = 12;
//            year --;
//        }
//        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
//            day = 31;
//            
//        }else if (month == 2)
//        {
//            day = 29;
//        }else
//        {
//            day = 30;
//        }
//    }
//    
//    return [NSString stringWithFormat:@"%d-%02d-%02d",year,month,day];
//};
@class MXItemView;


@protocol MXItemViewDelegate <NSObject>

@optional
-(void)didSelectedItemView:(MXItemView *)itemView;

@end

@interface MXItemView : UIView
{
    UILabel *_dateLabel;
    NSMutableArray *_valueLabels;
    UIView *_lineView;
    UIView *_arcView;
}
@property (nonatomic , assign , getter = isSelected) BOOL selected;
@property (nonatomic , copy)    NSString *dateString;
@property (nonatomic , assign)  NSInteger index;


@property (nonatomic , strong) UIColor *axisColor;
@property (nonatomic , strong) UIColor *axisSelectColor;
@property (nonatomic , assign) CGFloat axisLineWidth;
@property (nonatomic , assign) CGFloat axisArcRadius;
@property (nonatomic , strong) UIColor *dateTextColor;
@property (nonatomic , assign) CGFloat dateTextFontSize;
@property (nonatomic , strong) UIColor *promptTextColor;
@property (nonatomic , assign) CGFloat promptTextFontSize;

@property (nonatomic , weak)    id<MXItemViewDelegate>delegate;

@property (nonatomic , strong) NSArray *promptInfos;

@end
@implementation MXItemView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _lineView = [[UIView alloc]init];
        _arcView = [[UIView alloc]init];
        
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_lineView];
        [self addSubview:_arcView];
        [self addSubview:_dateLabel];
        
        _valueLabels = [[NSMutableArray alloc]init];
        for (int i=0; i<3; i++) {
            UILabel *label = [[UILabel alloc]init];
            label.textAlignment = NSTextAlignmentCenter;
            label.hidden = YES;
            [self addSubview:label];
            [_valueLabels addObject:label];
        }
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.frame);
    _lineView.frame = CGRectMake(0, 0, width, _axisLineWidth);
    _arcView.frame = CGRectMake(0, 0, _axisArcRadius*2, _axisArcRadius*2);
    _arcView.layer.cornerRadius = _axisArcRadius;
    _lineView.center = _arcView.center = CGPointMake(width/2,_axisArcRadius+ INTERVAL);
    _dateLabel.frame = CGRectMake(0, CGRectGetMaxY(_arcView.frame) +INTERVAL, CGRectGetWidth(self.frame), _dateTextFontSize);
    CGFloat y = CGRectGetMaxY(_dateLabel.frame)+INTERVAL;
    for (UILabel *label in _valueLabels) {
        label.frame = CGRectMake(0, y, CGRectGetWidth(self.frame), _promptTextFontSize);
        y = y + _promptTextFontSize+INTERVAL;
    }
}

-(void)setPromptInfos:(NSArray *)promptInfos
{
    _promptInfos = promptInfos;
    for (UILabel *label in _valueLabels) {
        label.hidden = YES;
    }
    for (int i=0; i<promptInfos.count; i++) {
        UILabel *label = _valueLabels[i];
        label.text = promptInfos[i];
        label.hidden = NO;
    }
}
-(void)setDateString:(NSString *)dateString
{
    _dateString = dateString;
    _dateLabel.text = [dateString substringFromIndex:5];
}
-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (_selected) {
        _arcView.backgroundColor = _axisSelectColor;
    }else
    {
        _arcView.backgroundColor = _axisColor;
    }
}
-(void)setAxisColor:(UIColor *)axisColor
{
    _axisColor = axisColor;
    _lineView.backgroundColor = _axisColor;
    if (self.selected) {
        _arcView.backgroundColor = _axisSelectColor;
    }else
    {
        _arcView.backgroundColor = _axisColor;
    }
}
-(void)setDateTextColor:(UIColor *)dateTextColor
{
    _dateTextColor = dateTextColor;
    _dateLabel.textColor = dateTextColor;
}
-(void)setDateTextFontSize:(CGFloat)dateTextFontSize
{
    _dateTextFontSize = dateTextFontSize;
    _dateLabel.font = [UIFont systemFontOfSize:dateTextFontSize];
}
-(void)setPromptTextColor:(UIColor *)promptTextColor
{
    _promptTextColor = promptTextColor;
    for (UILabel *label in _valueLabels) {
        label.textColor = promptTextColor;
    }
}
-(void)setPromptTextFontSize:(CGFloat)promptTextFontSize
{
    _promptTextFontSize = promptTextFontSize;
    for (UILabel *label in _valueLabels) {
        label.font = [UIFont systemFontOfSize:promptTextFontSize];
    }
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedItemView:)]) {
        [self.delegate didSelectedItemView:self];
    }
}
@end


@interface MXCalendarView()<UIScrollViewDelegate,MXItemViewDelegate>
{
    NSInteger _totalDayCount;
}
@property (nonatomic , strong) NSMutableArray *visibleValue;
@property (nonatomic , assign) NSInteger currentIndex;
@end;
@implementation MXCalendarView
- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        _currentIndex = -1;
    }
    return self;
}
-(void)loadView
{
    
    //默认一排显示5个，最多同时显示6个
    for (NSInteger i=0; i<kVisibleCount+1; i++) {
        MXItemView *item = [[MXItemView alloc]init];
        item.delegate = self;
        item.axisSelectColor = _axisSelectColor;
        item.dateTextColor   = _dateTextColor;
        item.dateTextFontSize= _dateTextFontSize;
        item.promptTextColor = _promptTextColor;
        item.promptTextFontSize = _promptTextFontSize;
        item.axisLineWidth   = _axisLineWidth;
        item.axisArcRadius   = _axisArcRadius;
        [self addSubview:item];
        [self.visibleValue addObject:item];
    }
    
    _totalDayCount = self.infos.count;
    self.contentSize = CGSizeMake(_totalDayCount*kItemWidth, CGRectGetHeight(self.bounds));
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *current = [formatter stringFromDate:[NSDate date]];
    [self.infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"NORMALDAY"] isEqualToString:current]) {
            _currentIndex = idx;//今天的位置
            *stop = YES;
        }
    }];
    if (_currentIndex == -1) {
        return;
    }
    if (self.viewDelegate && [self.viewDelegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.viewDelegate calendarView:self didSelectDate:current];
    }
    [self layoutItemViewsInBeginIndex:_currentIndex+[self scrollDirection]];
    [self scrollToCurrentPageIfNeed:NO];
}
-(void)layoutItemViewsInBeginIndex:(NSInteger)visibleBeginIndex
{
    visibleBeginIndex = MAX(visibleBeginIndex, 0);
    visibleBeginIndex = MIN(visibleBeginIndex, _totalDayCount-kVisibleCount-1);
    for (NSInteger i=visibleBeginIndex; i<kVisibleCount+1+visibleBeginIndex; i++) {
        MXItemView *item = self.visibleValue[i-visibleBeginIndex];
        item.frame = CGRectMake(i*kItemWidth, 0, kItemWidth, kItemHeight);
        item.index = i;
        item.dateString = self.infos[i][kDateKey];
        int sg = [self.infos[i][@"sg"]intValue];
        int zq = [self.infos[i][@"zq"]intValue];
        int ss = [self.infos[i][@"ss"]intValue];
        NSMutableArray *arr = [[NSMutableArray alloc]initWithCapacity:3];
        if (sg) {
            [arr addObject:[NSString stringWithFormat:@"%d申购",sg]];
        }
        if (zq) {
            [arr addObject:[NSString stringWithFormat:@"%d中签",zq]];
        }
        if (ss) {
            [arr addObject:[NSString stringWithFormat:@"%d上市",ss]];
        }
        item.promptInfos = arr;
        [self resetItemViewInfo:item];
    }
}
-(void)scrollToCurrentPageIfNeed:(BOOL)animated
{
    NSInteger visibleBeginIndex =  _currentIndex+[self directionOffset];
    visibleBeginIndex = MAX(visibleBeginIndex, 0);
    visibleBeginIndex = MIN(visibleBeginIndex, _totalDayCount-kVisibleCount);
    CGFloat pageSize = CGRectGetWidth(self.frame)/kVisibleCount;
    NSInteger currentBeginIndex = roundf(self.contentOffset.x / pageSize);
    if (visibleBeginIndex != currentBeginIndex) {
        //滚动之后 回走 scrollViewDidScroll 放法
        [self setContentOffset:CGPointMake(visibleBeginIndex*kItemWidth, 0) animated:animated];
    }else
    {
        for (MXItemView *item in self.visibleValue) {
            [self resetItemViewInfo:item];
        }
    }
}
-(void)resetItemViewInfo:(MXItemView *)item
{
    if (item.index == _currentIndex) {
        item.selected = YES;
    }else
    {
        item.selected = NO;
    }
    if ([self.holiday containsObject:item.dateString]) {
        item.axisColor = _axisHolidayColor;
    }else{
        item.axisColor = _axisWorkdayColor;
    }
}
-(NSInteger)directionOffset
{
    switch (_scrollDirection) {
        case 0:
            return 0;
            break;
        case 1:
            return -2;
            break;
        case 2:
            return -4;
            break;
        default:
            return -2;
            break;
    }
}
#pragma mark - getter
-(NSMutableArray *)visibleValue
{
    if (!_visibleValue) {
        _visibleValue = [[NSMutableArray alloc]init];
    }
    return _visibleValue;
}
#pragma mark - MXItemViewDelegate
-(void)didSelectedItemView:(MXItemView *)itemView
{
    self.currentIndex = itemView.index;
    [self scrollToCurrentPageIfNeed:YES];
    if (self.viewDelegate && [self.viewDelegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.viewDelegate calendarView:self didSelectDate:self.infos[_currentIndex][kDateKey]];
    }
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = self.contentOffset;
    if (offset.x<=0) {
        return;
    }
    CGFloat pageSize = CGRectGetWidth(self.frame)/kVisibleCount;
    NSInteger page = floor(scrollView.contentOffset.x / pageSize);
    page = MAX(page, 0);
    page = MIN(page, _totalDayCount - kVisibleCount-1);
//    if (_currentIndex != page + 2) {
//        _currentIndex = page + 2;
        [self layoutItemViewsInBeginIndex:page];
//    }
}
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if (self.viewDelegate && [self.viewDelegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
//        [self.viewDelegate calendarView:self didSelectDate:self.infos[_currentIndex][kDateKey]];
//    }
//}
- (CGPoint)nearestTargetOffsetForOffset:(CGPoint)offset
{
    CGFloat pageSize = CGRectGetWidth(self.frame)/kVisibleCount;
    NSInteger page = roundf(offset.x / pageSize);
    CGFloat targetX = pageSize * page;
    return CGPointMake(targetX, offset.y);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint targetOffset = [self nearestTargetOffsetForOffset:*targetContentOffset];
    targetContentOffset->x = targetOffset.x;
    targetContentOffset->y = targetOffset.y;
}

@end
