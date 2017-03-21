/////////////////////////////////////////////////////////
//                                                     //
// Copyright (c) 2016年 上证云平台. All rights reserved. //
//                                                     //
/////////////////////////////////////////////////////////

@class MStockItem;

@interface MTopPriceDetailView : UIView
/* 股号 */
@property (nonatomic, copy) NSString *code;
/* segment边框颜色 */
@property (nonatomic, strong) UIColor *segmentBorderColor;
/* segment字体 */
@property (nonatomic, strong) UIFont *segmentFont;
/* segment背景色 */
@property (nonatomic, strong) UIColor *segmentBackgroundColor;
/* segment选择时背景色 */
@property (nonatomic, strong) UIColor *segmentSelectedBackgroundColor;
/* segment文字颜色 */
@property (nonatomic, strong) UIColor *segmentTextColor;
/* segment选择时文字颜色 */
@property (nonatomic, strong) UIColor *segmentSelectedTextColor;
/* segment高度 */
@property (nonatomic, assign) CGFloat segmentHeight;
/* segment当前索引 */
@property (nonatomic, readwrite) NSUInteger selectedSegmentIndex;

/* 涨文字色 */
@property (nonatomic, strong) UIColor *riseTextColor;
/* 跌文字色 */
@property (nonatomic, strong) UIColor *dropTextColor;
/* 平盘文字色 */
@property (nonatomic, strong) UIColor *flatTextColor;
/* 量文字色 */
@property (nonatomic, strong) UIColor *volumeTextColor;
/* 通用文字色 */
@property (nonatomic, strong) UIColor *textColor;
/* 通用字体 */
@property (nonatomic, strong) UIFont *textFont;

- (void)reloadData;
- (void)reloadDataWithStockItem:(MStockItem *)stockItem;
@end
