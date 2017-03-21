/////////////////////////////////////////////////////////
//                                                     //
// Copyright (c) 2016年 上证云平台. All rights reserved. //
//                                                     //
/////////////////////////////////////////////////////////

@class MIPODetailView;
/**
 *  新股日历详情页面代理
 */
@protocol MIPODetailViewDelegate <NSObject>
@optional
/**
 *  点击时间代理方法
 *
 *  @param detailView 详情view
 *  @param code       股票代码
 */
- (void)IPODetailView:(MIPODetailView *)detailView didSelectStockWithCode:(NSString *)code;
/**
 *  该方法在将要获取数据时调用，可以在此方法里里加入 网络加载提示框 等
 *
 *  @param MIPODetailView 详情view
 */
- (void)IPODetailViewWillGetData:(MIPODetailView *)detailView;
/**
 *  该方法在获取数据完成后调用，可以在此方法里 取消 网络加载提示框 。
 *
 *  @param MIPODetailView 详情view
 */
- (void)IPODetailViewDidEndGetData:(MIPODetailView *)detailView;
@end
/**
 *  新股日历详情view
 */
@interface MIPODetailView : UIView
/**
 *  代理
 */
@property (nonatomic , weak) id<MIPODetailViewDelegate> delegate;
/**
 *  section header 的分割线颜色
 */
@property (nonatomic , strong) UIColor *sectionHeaderSeparatorColor;
/**
 *  section header 高度
 */
@property (nonatomic , assign) CGFloat sectionHeaderHeight;
/**
 *  section header 背景色
 */
@property (nonatomic , strong) UIColor *sectionHeaderBackgroundColor;
/**
 *  section header 文字大小
 */
@property (nonatomic , assign) CGFloat sectionHeaderFontSize;
/**
 *  section header 文字颜色
 */
@property (nonatomic , strong) UIColor *sectionHeaderTextColor;

/**
 *  cell右边标题文字颜色
 */
@property (nonatomic , strong) UIColor *cellNameTextColor;
/**
 *  cell右边标题文字大小
 */
@property (nonatomic , assign) NSInteger cellNameTextFontSize;
/**
 *  cell左边详情文字颜色
 */
@property (nonatomic , strong) UIColor *cellValueTextColor;
/**
 *  cell左边详情文字大小
 */
@property (nonatomic , assign) NSInteger cellValueTextFontSize;
/**
 *  可点击的股票名称文字颜色
 */
@property (nonatomic , strong) UIColor  *clickedTextColor;
/**
 *  cell的背景色
 */
@property (nonatomic , strong) UIColor *cellBackColor;

/**
 *  加载数据方法
 *
 *  @param code 股票代码
 */
-(void)loadDataWithCode:(NSString *)code;
@end
