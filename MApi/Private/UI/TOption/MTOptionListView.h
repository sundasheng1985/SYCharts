//
//  MTOptionListView.h
//  MAPI
//
//  Created by IOS_HMX on 16/8/5.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, MTOptionListViewType){
    MTOptionListViewTypePut,  //任沽
    MTOptionListViewTypeCall //认购
};

@class MTOptionListView ;

@protocol MTOptionListViewDelegate <NSObject,UITableViewDelegate>

@optional
- (CGFloat)optionsListView:(MTOptionListView *)optionsListView widthInColumn:(NSInteger)inColumn;
- (CGFloat)optionsListView:(MTOptionListView *)optionsListView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)optionsListView:(MTOptionListView *)optionsListView scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)optionsListViewDidScroll:(MTOptionListView *)optionsListView withScrollView:(UIScrollView *)scrollView;
- (void)optionsListView:(MTOptionListView *)optionsListView didSelectRow:(NSInteger)row;
- (id)optionsListView:(MTOptionListView *)optionsListView reuseViewForHeader:(id)reuseViewForHeader inColumn:(NSInteger)inColumn;
@end


@protocol MTOptionListViewDataSource <NSObject>
@required
- (NSInteger)numberOfRowsInOptionsListView:(MTOptionListView *)optionsListView;
- (NSInteger)numberOfColumnsInOptionsListView:(MTOptionListView *)optionsListView;

- (id)optionsListView:(MTOptionListView *)optionsListView reuseView:(id)reuseView inRow:(NSInteger)inRow inColumn:(NSInteger)inColumn;

@end

@interface MTOptionListView : UIView<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, assign) id<MTOptionListViewDelegate> delegate;
@property (nonatomic, assign) id<MTOptionListViewDataSource> dataSource;
@property (nonatomic, strong) UIScrollView *scrollViewBase;
@property (nonatomic, strong) UITableView *tableViewBase;
@property (nonatomic, assign) MTOptionListViewType optionsListViewType;
@property (nonatomic, assign) CGFloat headerHeight;

- (void)reloadData;

@end
