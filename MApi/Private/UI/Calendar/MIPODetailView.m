//
//  MXNewStockDetailView.m
//  NewStock
//
//  Created by IOS_HMX on 16/7/4.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import "MIPODetailView.h"
#import "MXDetailCell.h"
#import "MXDefine.h"
#import "UIView+Additions.h"
#import "MIPODetailView.h"
#import "MApi.h"
#define kDetailInfos @[@{@"type":@"申购状态",@"list":@[@{@"name":@"股票名称",@"valueKey":@"SECUABBR"},\
                                                    @{@"name":@"股票代码",@"valueKey":@"TRADINGCODE"},\
                                                    @{@"name":@"申购代码",@"valueKey":@"APPLYCODE"},\
                                                    @{@"name":@"申购日期",@"valueKey":@"BOOKSTARTDATEON"},\
                                                    @{@"name":@"中签公布日",@"valueKey":@"SUCCRESULTNOTICEDATE"},\
                                                    @{@"name":@"中签率",@"valueKey":@"ALLOTRATEON"},\
                                                    @{@"name":@"上市日期",@"valueKey":@"LISTINGDATE"},\
                                                    @{@"name":@"中签号",@"valueKey":@"ISSUEALLOTNOON"},\
                                                    @{@"name":@"资金解冻日",@"valueKey":@"REFUNDDATEON"}]},\
                        @{@"type":@"发行资料",@"list":@[@{@"name":@"发行价格",@"valueKey":@"ISSUEPRICE"},\
                                                    @{@"name":@"市盈率",@"valueKey":@"PEAISSUE"},\
                                                    @{@"name":@"发行总量",@"valueKey":@"ISSUESHARE"},\
                                                    @{@"name":@"网上发行量",@"valueKey":@"ISSUESHAREON"},\
                                                    @{@"name":@"申购数量上限",@"valueKey":@"CAPPLYSHARE"},\
                                                    @{@"name":@"申购资金上限",@"valueKey":@"CAPPLYPRICE"},\
                                                    @{@"name":@"所属板块",@"valueKey":@"BOARDNAME"},\
                                                    @{@"name":@"主承销商",@"valueKey":@"LEADUNDERWRITER"},\
                                                    @{@"name":@"公司简介",@"valueKey":@"COMPROFILE"},\
                                                    @{@"name":@"经营范围",@"valueKey":@"BUSINESSSCOPE"}]}]


@interface MIPODetailView()<UITableViewDataSource,UITableViewDelegate,MXDetailCellDelegate>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSDictionary *info;
@end

@implementation MIPODetailView
- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _sectionHeaderSeparatorColor     = [UIColor lightGrayColor];
        _sectionHeaderHeight       = 35.;
        _sectionHeaderBackgroundColor    = [UIColor grayColor];
        _sectionHeaderFontSize     = FONT_SIZE_3;
        _sectionHeaderTextColor    = [UIColor whiteColor];
        
        
        _cellNameTextColor = [UIColor blackColor];
        _cellNameTextFontSize = FONT_SIZE_3;
        _cellValueTextColor = [UIColor grayColor];
        _cellValueTextFontSize = FONT_SIZE_3;
        _clickedTextColor = [UIColor blueColor];
        _cellBackColor = [UIColor whiteColor];
        
        [self addSubview:self.tableView];
        
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}
-(void)loadDataWithCode:(NSString *)code
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(IPODetailViewWillGetData:)]) {
        [self.delegate IPODetailViewWillGetData:self];
    }
    MIPOShareDetailRequest *request = [MIPOShareDetailRequest new];
    request.code = code;
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess)
        {
            self.info = ((MIPOShareDetailResponse *)resp).info;
            if (self.delegate && [self.delegate respondsToSelector:@selector(IPODetailViewDidEndGetData:)]) {
                [self.delegate IPODetailViewDidEndGetData:self];
            }
            [self.tableView reloadData];
        }
    }];
}
#pragma mark UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kDetailInfos.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _sectionHeaderHeight;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *headerId = @"headerId";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerId];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerId];
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.tag = 1;
        [headerView.contentView addSubview:label];
        
    }
    headerView.backgroundView.backgroundColor =
    headerView.contentView.backgroundColor    = _sectionHeaderBackgroundColor;
    headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), _sectionHeaderHeight);
    [headerView.contentView setBorderWidth:1 withColor:_sectionHeaderSeparatorColor direction:UIViewCustomBorderDirectionBottom];
    
    UILabel *titleLabel     = (UILabel *)[headerView viewWithTag:1];
    titleLabel.textColor    = _sectionHeaderTextColor;
    titleLabel.font         = [UIFont systemFontOfSize:_sectionHeaderFontSize];
    titleLabel.frame        = CGRectMake(LEFT_PADDING, 0, 200, _sectionHeaderHeight);
    titleLabel.text         = kDetailInfos[section][@"type"];
    return headerView;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [kDetailInfos[section][@"list"] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *value = self.info[kDetailInfos[indexPath.section][@"list"][indexPath.row][@"valueKey"]];
    return [MXDetailCell heightWithValueString:value withFont:[UIFont systemFontOfSize:_cellValueTextFontSize] inWidth:CGRectGetWidth(self.frame)];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *detailCellId = @"detailCellId";
    MXDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellId];
    if (!cell) {
        cell = [[MXDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0);
        cell.delegate = self;
    }
    cell.nameTextColor      = _cellNameTextColor;
    cell.valueTextColor     = _cellValueTextColor;
    cell.nameTextFontSize   = _cellNameTextFontSize;
    cell.valueTextFontSize  = _cellValueTextFontSize;
    cell.clickedTextColor   = _clickedTextColor;
    cell.backgroundColor = cell.contentView.backgroundColor = _cellBackColor;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.clickEnable = YES;
    }
    else {
        cell.clickEnable = NO;
    }
    NSString *value = self.info[kDetailInfos[indexPath.section][@"list"][indexPath.row][@"valueKey"]];
    NSString *name = kDetailInfos[indexPath.section][@"list"][indexPath.row][@"name"];
    if ([name isEqualToString:@"股票代码"]) {
        NSArray *array = [value componentsSeparatedByString:@"."];
        if (array&&array.count == 2) {
            value = array[0];
        }
    }
    [cell setName:name andValue:value];
    return cell;
    
}
-(void)didClickedCell:(MXDetailCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(IPODetailView:didSelectStockWithCode:)]) {
        [self.delegate IPODetailView:self didSelectStockWithCode:self.info[@"TRADINGCODE"]];
    }
}
#pragma mark getter and setter
-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}
@end
