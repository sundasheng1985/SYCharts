//
//  MTOptionScrollView.h
//  MAPI
//
//  Created by IOS_HMX on 16/8/5.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTOptionListView.h"
@class MTOptionScrollView;
@protocol MTOptionScrollViewDataSource <NSObject>
@required
- (NSInteger)optionScrollView:(MTOptionScrollView *)optionScrollView numberOfRowsInTableView:(UITableView *)tableViewStPrice;

- (NSInteger)optionScrollView:(MTOptionScrollView *)optionScrollView numberOfRowsInOptionListView:(MTOptionListView *)optionsListView;

- (NSInteger)optionScrollView:(MTOptionScrollView *)optionScrollView numberOfColumnsInOptionListView:(MTOptionListView *)optionsListView;

- (id)optionScrollView:(MTOptionScrollView *)optionScrollView reuseView:(id)reuseView inRow:(NSInteger)inRow inColumn:(NSInteger)inColumn andOptionListViewType:(MTOptionListViewType)optionsListViewType;

- (id)optionScrollView:(MTOptionScrollView *)optionScrollView reuseCenterView:(id)reuseCenterView inRow:(NSInteger)inRow;

@end

@protocol MTOptionScrollViewDelegate <NSObject>
- (CGFloat)optionScrollView:(MTOptionScrollView *)optionScrollView widthInColumn:(NSInteger)inColumn;
- (CGFloat)optionScrollView:(MTOptionScrollView *)optionScrollView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)optionScrollView:(MTOptionScrollView *)optionScrollView didSelectRow:(NSInteger)row inOptionListViewType:(MTOptionListViewType)optionsListViewType;
@required
- (id)optionScrollView:(MTOptionScrollView *)optionScrollView reuseViewForHeader:(id)reuseViewForHeader inColumn:(NSInteger)inColumn andOptionListViewType:(MTOptionListViewType)optionsListViewType;
@end

@interface MTOptionScrollView : UIScrollView<MTOptionListViewDataSource,MTOptionListViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) id<MTOptionScrollViewDataSource>dataSource;
@property (nonatomic, assign) id<MTOptionScrollViewDelegate>mdelegate;
@property (nonatomic, strong) MTOptionListView *optionsListViewCall;
@property (nonatomic, strong) MTOptionListView *optionsListViewPut;
@property (nonatomic, strong) UITableView *optionsCenterView;

/**
 *  认沽、认购列表header标题文字颜色
 */
@property (nonatomic , strong) UIColor *callPutCellHeaderTitleColor;
/**
 *  认沽、认购列表header标题文字大小
 */
@property (nonatomic , assign) CGFloat callPutCellHeaderTitleFontSize;
/**
 *  认沽、认购列表header标题背景颜色
 */
@property (nonatomic , strong) UIColor *callPutCellHeaderBackgroundColor;
@property (nonatomic , assign) CGFloat callPutCellHeaderHeght;

-(void)reloadData;
@end
