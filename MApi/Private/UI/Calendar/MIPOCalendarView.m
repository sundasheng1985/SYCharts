//
//  MXNewStockView.m
//  NewStock
//
//  Created by IOS_HMX on 16/7/1.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import "MIPOCalendarView.h"
#import "_MIPOCalendarView.h"
#import "MXDefine.h"
#import "MXListCell.h"
#import "UIView+Additions.h"
#import "MXHeaderCell.h"
#define kStockInfos @[@{@"type":@"今日申购",@"key":@"sglist",@"titles":@[@"股票",@"发行价",@"市盈率",@"中签公布"],@"titlesKey":@[@"SECUABBR",@"ISSUEPRICE",@"PEAISSUE",@"SUCCRESULTNOTICEDATE",@"TRADINGCODE"]},\
                    @{@"type":@"今日中签",@"key":@"zqlist",@"titles":@[@"股票",@"发行价",@"中签率",@"上市日期"],@"titlesKey":@[@"SECUABBR",@"ISSUEPRICE",@"ALLOTRATEON",@"LISTINGDATE",@"TRADINGCODE"]},\
                    @{@"type":@"今日上市",@"key":@"sslist",@"titles":@[@"股票",@"发行价",@"市盈率",@"中签率"],@"titlesKey":@[@"SECUABBR",@"ISSUEPRICE",@"PEAISSUE",@"ALLOTRATEON",@"TRADINGCODE"]},\
                    @{@"type":@"未上市",@"key":@"wsslist",@"titles":@[@"股票",@"发行价",@"中签率",@"上市日期"],@"titlesKey":@[@"SECUABBR",@"ISSUEPRICE",@"ALLOTRATEON",@"LISTINGDATE",@"TRADINGCODE"]},\
                    @{@"type":@"即将发行",@"key":@"jjfxlist",@"titles":@[@"股票",@"发行价",@"市盈率",@"申购日期"],@"titlesKey":@[@"SECUABBR",@"ISSUEPRICE",@"PEAISSUE",@"BOOKSTARTDATEON",@"TRADINGCODE"]},\
                    ]


@implementation MIPOCalendarView
- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _separatorClolor = [UIColor lightGrayColor];
        
        _headerBackColor = [UIColor grayColor];
        _headerTitleFontSize = FONT_SIZE_3;
        _headerTitleColor = [UIColor whiteColor];
        
        
        _headerPromptFontSize = FONT_SIZE_4;
        _headerPromptColor = [UIColor lightGrayColor];
        
        _cellBackColor = [UIColor whiteColor];
        _cellFontSize = FONT_SIZE_3;
        _cellTextColor = [UIColor blackColor];
        _codeIdColor = [UIColor lightGrayColor];
        _codeIdFontSize = FONT_SIZE_5;
        
        
        _axisHolidayColor = [UIColor lightGrayColor];
        _axisWorkdayColor = [UIColor grayColor];
        _axisSelectColor = [UIColor blackColor];
        _axisLineWidth = 4;
        _axisArcRadius = 8;
        _dateTextColor = [UIColor blackColor];
        _promptTextColor = [UIColor grayColor];
        _promptTextFontSize = FONT_SIZE_5;
        _dateTextFontSize = FONT_SIZE_4;
        _axisBackColor = [UIColor whiteColor];
        _noDataMessageColor = [UIColor grayColor];
        
        _newsList = [[NSMutableArray alloc]init];
    }
    return self;
}
-(void)loadData
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(IPOCalendarViewWillGetData:)]) {
        [self.delegate IPOCalendarViewWillGetData:self];
    }
    _requestCount = 2;
    [self holiday];
    [self tradingDay];
}
-(void)loadView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(IPOCalendarViewDidEndGetData:)]) {
        [self.delegate IPOCalendarViewDidEndGetData:self];
    }
    [self addSubview:self.calendarView];
    [self addSubview:self.tableView];
    self.calendarView.holiday = _holidayArray;
    self.calendarView.infos = _calendarInfoArray;
    [self.calendarView loadView];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.calendarView.frame), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-CGRectGetMaxY(self.calendarView.frame));
    _noDataMessage.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 40);
}
-(void)holiday
{
    [MApi sendRequest:[MMarketHolidayRequest new] completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess)
        {
            NSMutableArray *dateArray = [@[] mutableCopy];
            NSDictionary *JSONObject = ((MMarketHolidayResponse *)resp).JSONObject;
            NSArray *item = JSONObject[@"sh"];
            for (NSDictionary *dic in item) {
                NSString *str = dic[@"date"];
                if (str.length ==8) {
                    [dateArray addObject:[NSString stringWithFormat:@"%@-%@-%@",[str substringWithRange:NSMakeRange(0, 4)],[str substringWithRange:NSMakeRange(4, 2)],[str substringWithRange:NSMakeRange(6, 2)]]];
                }
            }
            _holidayArray = dateArray;
            _requestCount--;
            if (_requestCount==0) {
                [self loadView];
            }
        }
    }];
}
-(void)tradingDay
{
    [MApi sendRequest:[MIPODateRequest new] completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess)
        {
            _calendarInfoArray = ((MIPODateResponse *)resp).infos;
            _requestCount--;
            if (_requestCount==0) {
                [self loadView];
            }
        }
    }];
}

-(void)newsharescalInDate:(NSString *)date
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(IPOCalendarViewWillGetData:)]) {
        [self.delegate IPOCalendarViewWillGetData:self];
    }
    [MApi cancelRequest:_request];
    _request = [MIPOCalendarRequest new];
    _request.date = date;
    [MApi sendRequest:_request completionHandler:^(MResponse *resp) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(IPOCalendarViewDidEndGetData:)]) {
            [self.delegate IPOCalendarViewDidEndGetData:self];
        }
        if(resp.status == MResponseStatusSuccess)
        {
            [_newsList removeAllObjects];
            NSDictionary *jsonValue = ((MIPOCalendarResponse *)resp).info;
            for (int i=0; i<kStockInfos.count; i++) {
                NSString *key = kStockInfos[i][@"key"];
                if ([jsonValue[key] count] !=0) {
                    NSDictionary *dic = @{@"type":kStockInfos[i][@"type"],@"titles":kStockInfos[i][@"titles"],@"list":jsonValue[key],@"titlesKey":kStockInfos[i][@"titlesKey"]};
                    [_newsList addObject:dic];
                }
            }
            if (_newsList.count==0) {
                _noDataMessage.hidden = NO;
            }else
            {
                _noDataMessage.hidden = YES;
            }
            [self.tableView reloadData];
        }
    }];
}
#pragma mark private

#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _newsList.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return TITLE_HEIGHT ;
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
    headerView.contentView.backgroundColor    = _headerBackColor;
    headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), TITLE_HEIGHT);
    [headerView.contentView setBorderWidth:1 withColor:_separatorClolor direction:UIViewCustomBorderDirectionBottom];
    
    UILabel *titleLabel     = (UILabel *)[headerView viewWithTag:1];
    titleLabel.textColor    = _headerTitleColor;
    titleLabel.font         = [UIFont systemFontOfSize:_headerTitleFontSize];
    titleLabel.frame        = CGRectMake(LEFT_PADDING, 0, 200, TITLE_HEIGHT);
    titleLabel.text         = _newsList[section][@"type"];
    return headerView;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_newsList[section][@"list"] count]+1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return PROMPT_HEIGHT;
    }
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"stockCell";
    static NSString *cellHeader = @"celHeader";
    if (indexPath.row == 0) {
        MXHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellHeader];
        if(!cell)
        {
            cell = [[MXHeaderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellHeader];
            cell.userInteractionEnabled = NO;
            cell.promptBackColor = _cellBackColor;
            cell.headerPromptColor = _headerPromptColor;
            cell.headerPromptFontSize = _headerPromptFontSize;
            cell.backgroundColor = cell.contentView.backgroundColor = _cellBackColor;
            
        }
        cell.separatorClolor = _promptSeparatorColor;
        cell.titles = _newsList[indexPath.section][@"titles"];
        return cell;
    }else
    {
        MXListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MXListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.cellFontSize = _cellFontSize;
            cell.cellTextColor = _cellTextColor;
            cell.codeIdColor = _codeIdColor;
            cell.codeIdFontSize = _codeIdFontSize;
            cell.backgroundColor = cell.contentView.backgroundColor = _cellBackColor;
        }
        NSDictionary *info = _newsList[indexPath.section][@"list"][indexPath.row-1];
        NSArray *valuesKey = _newsList[indexPath.section][@"titlesKey"];
        NSString *code = info[valuesKey[4]];
        NSArray *array = [code componentsSeparatedByString:@"."];
        if (array&&array.count == 2) {
            code = array[0];
        }
        cell.values = @[info[valuesKey[0]],info[valuesKey[1]],info[valuesKey[2]],info[valuesKey[3]],code];
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.delegate && [self.delegate respondsToSelector:@selector(IPOCalendarView:didSelectStockWithCode:andName:)])
    {
        NSDictionary *info = _newsList[indexPath.section][@"list"][indexPath.row-1];
        NSArray *valuesKey = _newsList[indexPath.section][@"titlesKey"];
        [self.delegate IPOCalendarView:self didSelectStockWithCode:info[valuesKey[4]] andName:info[valuesKey[0]]];
    }
}
-(void)calendarView:(MXCalendarView *)calendarView didSelectDate:(NSString *)date
{
    [self newsharescalInDate:date];
}
#pragma mark getter and setter
-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _noDataMessage = [[UILabel alloc]init];
        _noDataMessage.backgroundColor = [UIColor clearColor];
        _noDataMessage.textAlignment = NSTextAlignmentCenter;
        _noDataMessage.text = @"暂无数据";
        _noDataMessage.textColor = _noDataMessageColor;
        _noDataMessage.hidden = YES;
        [_tableView  addSubview:_noDataMessage];
    }
    return _tableView;
}
-(MXCalendarView *)calendarView
{
    if (!_calendarView) {
        CGFloat h = INTERVAL + 2*_axisArcRadius + INTERVAL + _dateTextFontSize+INTERVAL +(INTERVAL +_promptTextFontSize)*3;
        _calendarView = [[MXCalendarView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), h)];
        _calendarView.backgroundColor = _axisBackColor;
        _calendarView.viewDelegate = self;
        _calendarView.axisHolidayColor = _axisHolidayColor;
        _calendarView.axisWorkdayColor = _axisWorkdayColor;
        _calendarView.axisSelectColor  = _axisSelectColor;
        _calendarView.axisLineWidth    = _axisLineWidth;
        _calendarView.axisArcRadius    = _axisArcRadius;
        _calendarView.dateTextColor    = _dateTextColor;
        _calendarView.dateTextFontSize = _dateTextFontSize;
        _calendarView.promptTextColor  = _promptTextColor;
        _calendarView.promptTextFontSize=_promptTextFontSize;
        _calendarView.scrollDirection = _scrollDirection;
    }
    return _calendarView;
}
@end
