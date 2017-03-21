//
//  MStockListView.h
//
//  Created by FanChiangShihWei on 2016/5/16.
//  Copyright © 2016年 Mitake Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, MStockListViewLayout)  {
    MStockListViewLayoutBasic = 1 << 0, //Default
    MStockListViewLayoutSimplify = 1 << 1, // 简易报价
    MStockListViewLayoutBigWord1 = 1 << 2, // 1 column
    MStockListViewLayoutBigWord2 = 1 << 3, // 2 column
    MStockListViewLayoutBangkuai = 1 << 4, // 版块, 左边可单点, 右边一行
    MStockListViewLayoutQuoteOverview = 1 << 5,  // 行情首页, 上2 section固定, 下1 basic layout

};

typedef NS_ENUM(NSInteger, MStockListViewCellSeparatorStyle) {
    MStockListViewCellSeparatorStyleNone,
    MStockListViewCellSeparatorStyleSingleLine
};

@class MStockListView;
@class MStockListCell, MStockListHeaderView;
@class MStockListItemPath;


@protocol MStockListViewDelegate <NSObject, UIScrollViewDelegate>
@optional
- (void)stockListView:(MStockListView *)stockListView didSelectItemAtItemPath:(MStockListItemPath *)itemPath;
@end

@protocol MStockListViewDataSource <NSObject>
- (NSUInteger)stockListView:(MStockListView *)stockListView numberOfItemsInSection:(NSInteger)section forLayoutType:(MStockListViewLayout)layoutType;
- (__kindof MStockListCell *)stockListView:(MStockListView *)stockListView cellForLayoutType:(MStockListViewLayout)layoutType atItemPath:(MStockListItemPath *)itemPath;
- (__kindof MStockListHeaderView *)stockListView:(MStockListView *)stockListView headerForLayoutType:(MStockListViewLayout)layoutType atItemPath:(MStockListItemPath *)itemPath;

@optional
- (CGFloat)stockListView:(MStockListView *)stockListView rowHeightInSection:(NSUInteger)section forLayoutType:(MStockListViewLayout)layoutType;
- (NSUInteger)stockListView:(MStockListView *)stockListView numberOfSectionsForLayoutType:(MStockListViewLayout)layoutType;
@end

/// UNIQUE for MStockListViewLayoutBasic requirement
@protocol MStockListBasicLayoutDataSource <NSObject>
@optional
- (NSUInteger)numberOfColumnsForBasicStockListView:(MStockListView *)basicStockListView;
- (CGFloat)basicStockListView:(MStockListView *)basicStockListView columnWidthAtColumnIndex:(NSUInteger)columnIndex;
@end


@protocol  MStockListViewDataSource, MStockListBasicLayoutDataSource;
@interface MStockListView : UIScrollView
@property (nonatomic, weak, nullable) id<MStockListViewDelegate>delegate;
@property (nonatomic, weak, nullable) id<MStockListViewDataSource>dataSource;
@property (nonatomic, weak, nullable) id <MStockListBasicLayoutDataSource> basicLayoutDataSource;
@property (nonatomic, assign) CGFloat headerHeight;
//@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, readwrite) MStockListViewLayout layoutType;

@property (nonatomic, assign) MStockListViewCellSeparatorStyle separatorStyle;
@property (nonatomic, strong, nullable) UIColor *separatorColor;

- (instancetype)initWithFrame:(CGRect)frame layoutType:(MStockListViewLayout)layout NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(nullable Class)headerClass forHeaderWithReuseIdentifier:(NSString *)identifier;

- (__kindof MStockListCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forItemPath:(MStockListItemPath *)itemPath;
- (__kindof MStockListHeaderView *)dequeueReusableHeaderWithReuseIdentifier:(NSString *)identifier forItemPath:(MStockListItemPath *)itemPath;

- (NSUInteger)numberOfSections;
- (void)reloadData;
@end


@interface MStockListReusableView : UIView
@property (nonatomic, strong) UIColor *highlightBackgroundColor;
- (void)prepareForReuse;
@end


@interface MStockListCell : MStockListReusableView

@end


@interface MStockListFixedCell : MStockListCell

@end


@interface MStockListHeaderView : MStockListReusableView

@end


@interface MStockListItemPath : NSObject
@property (nonatomic, readonly) NSInteger section;
@property (nonatomic, readonly) NSInteger row;
@property (nonatomic, readonly) NSInteger column;
@property (nonatomic, readonly) NSInteger item;
@end

NS_ASSUME_NONNULL_END