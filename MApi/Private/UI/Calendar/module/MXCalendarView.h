//
//  MXCalendarView.h
//  NewStock
//
//  Created by IOS_HMX on 16/7/6.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MXCalendarView;

@protocol MXCalendarViewDelegate <NSObject>
@optional
-(void)calendarView:(MXCalendarView *)calendarView didSelectDate:(NSString *)date;
@end


@interface MXCalendarView : UIScrollView
@property (nonatomic , weak) id<MXCalendarViewDelegate>viewDelegate;
@property (nonatomic , strong) NSArray *infos;
@property (nonatomic , strong) NSArray *holiday;

@property (nonatomic , strong) UIColor *axisHolidayColor;
@property (nonatomic , strong) UIColor *axisWorkdayColor;
@property (nonatomic , strong) UIColor *axisSelectColor;
@property (nonatomic , assign) CGFloat axisLineWidth;
@property (nonatomic , assign) CGFloat axisArcRadius;

@property (nonatomic , strong) UIColor *dateTextColor;
@property (nonatomic , assign) CGFloat dateTextFontSize;
@property (nonatomic , strong) UIColor *promptTextColor;
@property (nonatomic , assign) CGFloat promptTextFontSize;

@property (nonatomic , assign) NSInteger scrollDirection;
-(void)loadView;
@end
