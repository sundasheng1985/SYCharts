/////////////////////////////////////////////////////////
//                                                     //
// Copyright (c) 2016年 上证云平台. All rights reserved. //
//                                                     //
/////////////////////////////////////////////////////////

@class MIPOCalendarView;

/**
 *  点击日期后的滚动方向
 */
typedef NS_ENUM(NSInteger, MIPOCalendarViewScrollDirection) {
    /**
     *  选中日期滚动到左边
     */
    MIPOCalendarViewScrollDirectionLeft = 0,
    /**
     *  选中日期滚动到中间
     */
    MIPOCalendarViewScrollDirectionMiddle,
    /**
     *  选中日期滚动到右边
     */
    MIPOCalendarViewScrollDirectionRight
};
/**
 *  代理
 */
@protocol MIPOCalendarViewDelegate <NSObject>
@optional
/**
 *   点击事件代理
 *
 *  @param calendarView 日历view
 *  @param code         选中的股票代码
 *  @param name         选中的股票名称
 */
- (void)IPOCalendarView:(MIPOCalendarView *)calendarView didSelectStockWithCode:(NSString *)code andName:(NSString *)name;
/**
 *  该方法在将要获取数据时调用，可以在此方法里里加入 网络加载提示框 等
 *
 *  @param calendarView 日历view
 */
- (void)IPOCalendarViewWillGetData:(MIPOCalendarView *)calendarView;
/**
 *  该方法在获取数据完成后调用，可以在此方法里 取消 网络加载提示框 。
 *
 *  @param calendarView 日历view
 */
- (void)IPOCalendarViewDidEndGetData:(MIPOCalendarView *)calendarView;
@end
/**
 *  新股日历页面
 */
@interface MIPOCalendarView : UIView
/**
 *  代理
 */
@property (nonatomic , weak) id<MIPOCalendarViewDelegate> delegate;

/*************************** section header ****************************/
/**
 *  section标题文字颜色
 */
@property (nonatomic , strong) UIColor *headerTitleColor;
/**
 *  section副标题文字颜色
 */
@property (nonatomic , strong) UIColor *headerPromptColor;
/**
 *  section标题文字大小
 */
@property (nonatomic , assign) CGFloat headerTitleFontSize;
/**
 *  section副标题文字大小
 */
@property (nonatomic , assign) CGFloat headerPromptFontSize;
/**
 *  section背景色
 */
@property (nonatomic , strong) UIColor *headerBackColor;
/**
 *  section标题分割线颜色
 */
@property (nonatomic , strong) UIColor *separatorClolor;
/**
 *  section副标题分割线颜色
 */
@property (nonatomic , strong) UIColor *promptSeparatorColor;

/*************************** cell ****************************/

/**
 *  cell文字颜色
 */
@property (nonatomic , strong) UIColor *cellTextColor;
/**
 *  cell文字大小
 */
@property (nonatomic , assign) CGFloat cellFontSize;
/**
 *  股票代码字体颜色
 */
@property (nonatomic , strong) UIColor *codeIdColor;
/**
 *  股票代码字体大小
 */
@property (nonatomic , assign) CGFloat codeIdFontSize;
/**
 *  cell背景颜色
 */
@property (nonatomic , strong) UIColor *cellBackColor;


/*************************** 滚动日历相关 ****************************/

/**
 *  休息日轴线颜色
 */
@property (nonatomic , strong) UIColor *axisHolidayColor;
/**
 *  工作日轴线颜色
 */
@property (nonatomic , strong) UIColor *axisWorkdayColor;
/**
 *  当前选择日期轴线颜色
 */
@property (nonatomic , strong) UIColor *axisSelectColor;
/**
 *  轴线宽度
 */
@property (nonatomic , assign) CGFloat axisLineWidth;
/**
 *  圆的半径
 */
@property (nonatomic , assign) CGFloat axisArcRadius;
/**
 *  背景色
 */
@property (nonatomic , strong) UIColor *axisBackColor;
/**
 *  日期颜色
 */
@property (nonatomic , strong) UIColor *dateTextColor;
/**
 *  日期字体大小
 */
@property (nonatomic , assign) CGFloat dateTextFontSize;
/**
 *  提示信息字体颜色
 */
@property (nonatomic , strong) UIColor *promptTextColor;
/**
 *  提示信息字体大小
 */
@property (nonatomic , assign) CGFloat promptTextFontSize;
/**
 *  没有获取到数据时 “暂无数据” 提示文字字体颜色
 */
@property (nonatomic , strong) UIColor *noDataMessageColor;
/**
 *  点击日期后的滚动方向
 */
@property (nonatomic , assign) MIPOCalendarViewScrollDirection scrollDirection;
/**
 *  加载数据方法
 */
-(void)loadData;
@end

