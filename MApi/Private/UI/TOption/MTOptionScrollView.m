//
//  MTOptionScrollView.m
//  MAPI
//
//  Created by IOS_HMX on 16/8/5.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MTOptionScrollView.h"

static const CGFloat kOptionsCenterViewCellWidth =50;
static const NSInteger kBodySubviewTags = 1000;

static const CGFloat kOptionsCenterViewCellHeight = 44;

@interface MTOptionCenterTableViewCell : UITableViewCell
@property (nonatomic, copy) NSIndexPath *indexPath;
@end
@implementation MTOptionCenterTableViewCell
@end

@implementation MTOptionScrollView
- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.optionsCenterView];
        [self addSubview:self.optionsListViewCall];
        [self addSubview:self.optionsListViewPut];
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat optionViewWidth = (CGRectGetWidth(self.frame)-kOptionsCenterViewCellWidth)/2.;
    CGFloat height = CGRectGetHeight(self.frame);
    _optionsListViewCall.frame = CGRectMake(
                                            0,
                                            0,
                                            optionViewWidth,
                                            height
                                            );
    _optionsCenterView.frame = CGRectMake(
                                          optionViewWidth,
                                          0,
                                          kOptionsCenterViewCellWidth,
                                          height
                                          );
    
    _optionsListViewPut.frame = CGRectMake(
                                           optionViewWidth + kOptionsCenterViewCellWidth,
                                           0,
                                           optionViewWidth,
                                           height
                                           );
}
- (UITableView *)optionsCenterView {
    if (!_optionsCenterView) {
        _optionsCenterView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _optionsCenterView.delegate = self;
        _optionsCenterView.dataSource = self;
        _optionsCenterView.scrollEnabled = YES;
        _optionsCenterView.showsVerticalScrollIndicator = NO;
        _optionsCenterView.clipsToBounds = YES;
        _optionsCenterView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if ([_optionsCenterView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_optionsCenterView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([_optionsCenterView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_optionsCenterView setLayoutMargins:UIEdgeInsetsZero];
        }
        _optionsCenterView.backgroundColor = [UIColor clearColor];
    }
    return _optionsCenterView;
}

- (MTOptionListView *)optionsListViewCall {
    if (!_optionsListViewCall) {
        _optionsListViewCall =[[MTOptionListView alloc]initWithFrame:CGRectZero];
        _optionsListViewCall.optionsListViewType =MTOptionListViewTypeCall;
        _optionsListViewCall.delegate =self;
        _optionsListViewCall.dataSource =self;
        _optionsListViewCall.tableViewBase.separatorStyle = UITableViewCellSeparatorStyleNone;
        _optionsListViewCall.tableViewBase.backgroundColor = [UIColor clearColor];
        _optionsListViewCall.tableViewBase.showsVerticalScrollIndicator = NO;
        _optionsListViewCall.headerHeight = _callPutCellHeaderHeght;
    }
    return _optionsListViewCall;
}

- (MTOptionListView *)optionsListViewPut {
    if (!_optionsListViewPut) {
        _optionsListViewPut =[[MTOptionListView alloc]initWithFrame:CGRectZero];
        _optionsListViewPut.optionsListViewType = MTOptionListViewTypePut;
        _optionsListViewPut.delegate =self;
        _optionsListViewPut.dataSource =self;
        _optionsListViewPut.tableViewBase.separatorStyle = UITableViewCellSeparatorStyleNone;
        _optionsListViewPut.tableViewBase.backgroundColor = [UIColor clearColor];

    }
    return _optionsListViewPut;
}
-(void)setCallPutCellHeaderHeght:(CGFloat)callPutCellHeaderHeght
{
    _callPutCellHeaderHeght = callPutCellHeaderHeght;
    self.optionsListViewPut.headerHeight = _callPutCellHeaderHeght;
    self.optionsListViewCall.headerHeight = _callPutCellHeaderHeght;
}
#pragma mark method

- (void)reloadData {
    [self.optionsCenterView reloadData];
    [self.optionsListViewCall reloadData];
    [self.optionsListViewPut reloadData];
    
}
-(CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.mdelegate respondsToSelector:@selector(optionScrollView:heightForRowAtIndexPath:)]) {
        return [self.mdelegate optionScrollView:self heightForRowAtIndexPath:indexPath];
    }
    return kOptionsCenterViewCellHeight;
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource optionScrollView:self numberOfRowsInTableView:tableView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cellIdentifier = @"CellIdentifier";
    
    MTOptionCenterTableViewCell *cell = (MTOptionCenterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[MTOptionCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        cell.backgroundColor = cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.indexPath = indexPath;
    
    id view = [cell viewWithTag:kBodySubviewTags];
    view = [self.dataSource optionScrollView:self reuseCenterView:view inRow:indexPath.row];
    ((UIView *)view).frame = CGRectMake(0,
                                        0,
                                        kOptionsCenterViewCellWidth,
                                        [self heightForRowAtIndexPath:indexPath]);
    ((UIView *)view).tag = kBodySubviewTags;
    if (!cell.superview) {
        [cell addSubview:view];
    }
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, kOptionsCenterViewCellWidth, _callPutCellHeaderHeght)];
    label.text =@"行权价";
    label.textAlignment =NSTextAlignmentCenter;
    label.textColor = _callPutCellHeaderTitleColor;
    label.backgroundColor = _callPutCellHeaderBackgroundColor;
    label.font = [UIFont systemFontOfSize:_callPutCellHeaderTitleFontSize];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return _callPutCellHeaderHeght;
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

#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 拉动中间 左右跟著动
    if (scrollView == _optionsCenterView) {
        _optionsListViewCall.tableViewBase.contentOffset = CGPointMake(_optionsListViewCall.tableViewBase.contentOffset.x, scrollView.contentOffset.y);
        _optionsListViewPut.tableViewBase.contentOffset = CGPointMake(_optionsListViewPut.tableViewBase.contentOffset.x, scrollView.contentOffset.y);
    }
}

#pragma mark - OptionsListViewDataSource

- (CGFloat)optionsListView:(MTOptionListView *)optionsListView widthInColumn:(NSInteger)inColumn {
    if ([self.mdelegate respondsToSelector:@selector(optionScrollView:widthInColumn:)]) {
        return [self.mdelegate optionScrollView:self widthInColumn:inColumn];
    }
    return 80;
}
-(CGFloat)optionsListView:(MTOptionListView *)optionsListView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForRowAtIndexPath:indexPath];
}
- (NSInteger)numberOfRowsInOptionsListView:(MTOptionListView *)optionsListView {
    return [self.dataSource optionScrollView:self numberOfRowsInOptionListView:optionsListView];
}

- (NSInteger)numberOfColumnsInOptionsListView:(MTOptionListView *)optionsListView {
    return [self.dataSource optionScrollView:self numberOfColumnsInOptionListView:optionsListView];
}

- (id)optionsListView:(MTOptionListView *)optionsListView reuseView:(id)reuseView inRow:(NSInteger)inRow inColumn:(NSInteger)inColumn {
    UIView *view =[self.dataSource optionScrollView:self reuseView:reuseView inRow:inRow inColumn:inColumn andOptionListViewType:optionsListView.optionsListViewType];
    return view;
}

#pragma mark OptionsListViewDelegate

- (id)optionsListView:(MTOptionListView *)optionsListView reuseViewForHeader:(id)reuseViewForHeader inColumn:(NSInteger)inColumn {
    UIView *view = reuseViewForHeader;
    if (!view) {
        view = [self.mdelegate optionScrollView:self reuseViewForHeader:view inColumn:inColumn andOptionListViewType:optionsListView.optionsListViewType];
    }
    return view;
}

- (void)optionsListView:(MTOptionListView *)optionsListView didSelectRow:(NSInteger)row {
    if ([self.mdelegate respondsToSelector:@selector(optionScrollView:didSelectRow:inOptionListViewType:)]) {
        [self.mdelegate optionScrollView:self didSelectRow:row inOptionListViewType:optionsListView.optionsListViewType];
    }
}

- (void)optionsListView:(MTOptionListView *)optionsListView scrollViewDidScroll:(UIScrollView *)scrollView {
    //上下連動
    
    // 拉動左邊，右邊要跟著動
    if (optionsListView.optionsListViewType == MTOptionListViewTypeCall) {
        _optionsCenterView.contentOffset = scrollView.contentOffset;
        _optionsListViewPut.tableViewBase.contentOffset = CGPointMake(_optionsListViewPut.tableViewBase.contentOffset.x, scrollView.contentOffset.y);
    }
    
    // 拉動右邊，左邊要跟著動
    if (optionsListView.optionsListViewType == MTOptionListViewTypePut) {
        _optionsCenterView.contentOffset = scrollView.contentOffset;
        _optionsListViewCall.tableViewBase.contentOffset = CGPointMake(_optionsListViewCall.tableViewBase.contentOffset.x, scrollView.contentOffset.y);
    }
    
    
}

- (void)optionsListViewDidScroll:(MTOptionListView *)optionsListView withScrollView:(UIScrollView *)scrollView {
    // 拉動左邊，右邊要跟著動
    if (optionsListView == _optionsListViewCall) {
        _optionsListViewPut.scrollViewBase.contentOffset = CGPointMake(scrollView.contentSize.width - (scrollView.contentOffset.x + CGRectGetWidth(scrollView.frame)) , scrollView.contentOffset.y);
    }
    // 拉動右邊，左邊要跟著動
    else if (optionsListView == _optionsListViewPut) {
        _optionsListViewCall.scrollViewBase.contentOffset = CGPointMake(scrollView.contentSize.width - (scrollView.contentOffset.x + CGRectGetWidth(scrollView.frame)) , scrollView.contentOffset.y);
    }
    
}
@end
