//
//  MTOptionListView.m
//  MAPI
//
//  Created by IOS_HMX on 16/8/5.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MTOptionListView.h"

#pragma mark - MTOptionListTableViewCell
@interface MTOptionListTableViewCell : UITableViewCell
@property (nonatomic, copy) NSIndexPath *indexPath;
@end

@implementation MTOptionListTableViewCell
@end

#pragma mark - OptionsListView
#define kOptionHeaderCellWidth 60
static const NSInteger kHeaderSubviewTags = 1000;
static const NSInteger kBodySubviewTags = 2000;
static const CGFloat kOptionsListViewHeaderCellHeight = 15;
static const CGFloat kOptionsListViewBodyCellHeight = 44;

@implementation MTOptionListView
- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}
-(instancetype)initWithFrame:(CGRect)frame {
    if (self =[super initWithFrame:frame]) {
        self.headerHeight = kOptionsListViewHeaderCellHeight;
        if (!self.tableViewBase.superview) {
            [self.scrollViewBase addSubview:self.tableViewBase];
        }
        
        if (!self.scrollViewBase.superview) {
            [self addSubview:self.scrollViewBase];
        }
    }
    return self;
}


- (void)layoutSubviews {
    NSInteger numberOfColumns = [self.dataSource numberOfColumnsInOptionsListView:self];
    CGFloat width = 0;
    for (NSInteger col = 0; col < numberOfColumns; col++) {
        width += [self viewWidthInColumn:col];
    }
    _scrollViewBase.contentSize = CGSizeMake(width, CGRectGetHeight(self.frame));
    _tableViewBase.frame = CGRectMake(0, 0, _scrollViewBase.contentSize.width, _scrollViewBase.contentSize.height);
    [self scrollToRightSide];
    [self setNeedsDisplay];
}


#pragma mark property

- (UIScrollView *)scrollViewBase {
    if (!_scrollViewBase) {
        _scrollViewBase = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _scrollViewBase.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollViewBase.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _scrollViewBase.bounces = NO;
        _scrollViewBase.delegate = self;
    }
    return _scrollViewBase;
}

- (UITableView *)tableViewBase {
    if (!_tableViewBase) {
        _tableViewBase = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableViewBase.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        //        _tableViewBase.backgroundColor = [UIColor clearColor];
        _tableViewBase.delegate = self;
        _tableViewBase.dataSource = self;
        //        _tableViewBase.separatorColor = [UIColor grayColor];
        
        if ([_tableViewBase respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableViewBase setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([_tableViewBase respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableViewBase setLayoutMargins:UIEdgeInsetsZero];
        }
        
    }
    return _tableViewBase;
}

#pragma mark private
- (CGFloat)viewWidthInColumn:(NSInteger)column {
    CGFloat viewWidth = kOptionHeaderCellWidth;
    if ([self.delegate respondsToSelector:@selector(optionsListView:widthInColumn:)]) {
        viewWidth = [self.delegate optionsListView:self widthInColumn:column];
    }
    return viewWidth;
}
#pragma mark method

- (void)reloadData {
    [self.tableViewBase reloadData];
    //    if(self.optionsListViewType == OptionsListViewTypeCall) {
    //        [self scrollToRightSide];
    //    }
}

// 將Call的ScrollView捲到最右邊去
- (void)scrollToRightSide {
    CGFloat contentWidth = self.scrollViewBase.contentSize.width;
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat fWidth = contentWidth - viewWidth;
    [self.scrollViewBase setContentOffset:CGPointMake(fWidth , 0) animated:NO];
}
-(CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(optionsListView:heightForRowAtIndexPath:)]) {
        return [self.delegate optionsListView:self heightForRowAtIndexPath:indexPath];
    }
    return kOptionsListViewBodyCellHeight;
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfRowsInOptionsListView:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CellIdentifier";
    
    MTOptionListTableViewCell *cell = (MTOptionListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[MTOptionListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.indexPath=indexPath;
    NSInteger numberOfColumns = [self.dataSource numberOfColumnsInOptionsListView:self];
    if (numberOfColumns > 0) {
        CGFloat x = 0;
        for (NSInteger col = 0; col < numberOfColumns; col++) {
            id view = [cell viewWithTag:(kBodySubviewTags + col)];
            view = [self.dataSource optionsListView:self reuseView:view inRow:indexPath.row inColumn:col];
            NSAssert([view isKindOfClass:[UIView class]], @"- (id)optionsListView:(OptionsListView *)optionsListView reuseView:(id)reuseView inRow:(NSInteger)inRow inColumn:(NSInteger)inColumn MUST RETURN UIView class.");
            CGFloat viewWidth = [self viewWidthInColumn:col];
            ((UIView *)view).frame = CGRectMake(x,
                                                0,
                                                viewWidth,
                                                [self heightForRowAtIndexPath:indexPath]);
            ((UIView *)view).tag = (kBodySubviewTags + col);
            [cell addSubview:view];
            x += viewWidth;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return  cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = nil;
    if ([tableView respondsToSelector:@selector(dequeueReusableHeaderFooterViewWithIdentifier:)]) {
        static NSString * const cellIdentifierCall = @"cellIdentifier";
        headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifierCall];
    }
    
    
    if (!headerView) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              0,
                                                              CGRectGetWidth(tableView.frame),
                                                              self.headerHeight)];
    }
    if ([self.delegate respondsToSelector:@selector(optionsListView:reuseViewForHeader:inColumn:)]) {
        NSInteger numberOfColumns = [self.dataSource numberOfColumnsInOptionsListView:self];
        if (numberOfColumns > 0) {
            CGFloat x = 0;
            for (NSInteger col = 0; col < numberOfColumns; col++) {
                id view = [headerView viewWithTag:(kHeaderSubviewTags + col)];
                view = [self.delegate optionsListView:self reuseViewForHeader:view inColumn:col];
                NSAssert([view isKindOfClass:[UIView class]], @"- (id)optionsListView:(OptionsListView *)optionsListView reuseView:(id)reuseView inRow:(NSInteger)inRow inColumn:(NSInteger)inColumn MUST RETURN UIView class.");
                CGFloat headerViewWidth = [self viewWidthInColumn:col];
                ((UIView *)view).frame = CGRectMake(x,
                                                    0,
                                                    headerViewWidth,
                                                    self.headerHeight);
                ((UIView *)view).tag = (kHeaderSubviewTags + col);
                [headerView addSubview:view];
                x += headerViewWidth;
            }
        }
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(optionsListView:didSelectRow:)]) {
        [self.delegate optionsListView:self didSelectRow:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //处理UITableViewCell 分割线没满版的问题
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
        
    }
}

#pragma mark UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(scrollView == _scrollViewBase) {
        if ([_delegate respondsToSelector:@selector(optionsListViewDidScroll:withScrollView:)]) {
            [_delegate optionsListViewDidScroll:self withScrollView:scrollView];
        }
    }
    //_tableViewBase
    if(scrollView == _tableViewBase) {
        if ([_delegate respondsToSelector:@selector(optionsListView:scrollViewDidScroll:)]) {
            [_delegate optionsListView:self scrollViewDidScroll:scrollView];
        }
    }
}
@end

