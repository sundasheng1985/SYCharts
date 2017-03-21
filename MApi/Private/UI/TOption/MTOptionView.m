//
//  MTOptionView.m
//  MAPI
//
//  Created by IOS_HMX on 16/8/5.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MTOptionView.h"
#import "MTOptionScrollView.h"
#import "MApi.h"
#import "MApiFormatter.h"
static const CGFloat KOptionExpireDateWidth = 44.;
static const CGFloat kOptionsListsViewLabelCallAndPutHeight = 15.;
static const CGFloat KOptionDayTitleLabelWidth = 80.;
static const CGFloat KOptionExpireMonthLabelWidth = 110.;
static const CGFloat KOptionRemainingDayLabelWidth = 100.;


static NSString *const kOptionsListsViewLabelCallText  = @"认购";
static NSString *const kOptionsListsViewLabelPutText  = @"认沽";


static NSString * const MAPI_CTUIFactoryNilValueDescription = @"一";

NS_INLINE NSString *MAPI_CTUIFactoryStringForValue(NSString *value) {
    return value.length > 0 ? value : MAPI_CTUIFactoryNilValueDescription;
}

@interface MTOptionView ()<MTOptionScrollViewDataSource,MTOptionScrollViewDelegate>
@property (nonatomic , strong) MTOptionScrollView *optionsScrollView;
@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, copy) NSMutableArray *quoteListFieldInfos;
@property (nonatomic, copy) NSArray *expireMonths;
@property (nonatomic, assign) NSUInteger expMonthIndex;
@property (nonatomic , copy) NSString *stockId;
@property (nonatomic, copy) NSMutableArray *callItems;
@property (nonatomic, copy) NSMutableArray *putItems;
@property (nonatomic, copy) NSArray *optionItems;
@property (nonatomic , strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *titleDayLabel;
@property (nonatomic, strong) UILabel *expireMonthLabel;
//到期天数
@property (nonatomic, strong) UILabel *remainingDayLabel;
@property (nonatomic, strong) UIView *toptionHeaderView;
@property (nonatomic, strong) UIActionSheet *actionSheet;

@end
@implementation MTOptionView
- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:20.0/255.0 blue:25.0/255.0 alpha:1];
        _expiryDateColor = [UIColor grayColor];
        _expiryDateFontSize = 16;
        _expiryDateMonthColor = [UIColor whiteColor];
        _expiryDateBackgroundColor = [UIColor colorWithRed:16.0/255.0 green:20.0/255.0 blue:25.0/255.0 alpha:1];
        _callPutTitleColor = [UIColor whiteColor];
        _callPutTitleFontSize = 14;
        _callPutBackgroundColor = [UIColor colorWithRed:26.0/2255.0 green:31.0/255.0 blue:36.0/255.0 alpha:1];
        
        _callPutCellHeaderTitleColor = [UIColor colorWithRed:65.0/255.0 green:120.0/255.0 blue:184.0/255.0 alpha:1];
        _callPutCellHeaderTitleFontSize = 14;
        _callPutCellHeaderBackgroundColor = [UIColor colorWithRed:26.0/2255.0 green:31.0/255.0 blue:36.0/255.0 alpha:1];
        _callPutCellHeaderHeight = 15;
        
        _exPriceColor = [UIColor whiteColor];
        _exPriceFontSize = 14;
        _exPriceBackgroundColor = [UIColor clearColor];
        _callPutCellHeight = 44;
        _callPutCellFontSize = 14;
        _callCellBackgroundColor = [UIColor clearColor];
        _putCellBackgroundColor = [UIColor clearColor];
        _upColor = [UIColor redColor];
        _downColor = [UIColor greenColor];
        _aveColor = [UIColor grayColor];
        _nullColor = [UIColor grayColor];
        _volumeAmountColor = [UIColor yellowColor];
        _columnWidth = 80;
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        [self stopTimer];
    }
}
-(void)refreshView
{
    [self getData];
}
-(UIScrollView *)scrollView
{
    return _optionsScrollView;
}
- (void)loadViewWithStockId:(NSString *)stockId {
    _stockId = stockId;
    [self addSubview:self.toptionHeaderView];
    // Call Label
    [self createLabelCall];
    // Put Label
    [self createLabelPut];
    [self addSubview:self.optionsScrollView];
    
    [self loadFields];
    self.expMonthIndex = 0;
    [self getMonthData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.toptionHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), KOptionExpireDateWidth);
    self.titleDayLabel.frame = CGRectMake(5, 0, KOptionDayTitleLabelWidth, CGRectGetHeight(self.toptionHeaderView.frame));
    self.expireMonthLabel.frame = CGRectMake(5 + CGRectGetWidth(self.titleDayLabel.frame), 0, KOptionExpireMonthLabelWidth, CGRectGetHeight(self.toptionHeaderView.frame));
    self.remainingDayLabel.frame = CGRectMake(5 + CGRectGetWidth(self.titleDayLabel.frame) + CGRectGetWidth(self.expireMonthLabel.frame),
                                              0, KOptionRemainingDayLabelWidth, CGRectGetHeight(self.toptionHeaderView.frame));
    self.optionsScrollView.frame = CGRectMake(0, KOptionExpireDateWidth+MAX(kOptionsListsViewLabelCallAndPutHeight, _callPutTitleFontSize), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-MAX(kOptionsListsViewLabelCallAndPutHeight, _callPutTitleFontSize)-KOptionExpireDateWidth);
}
#pragma mark - Private Methods

- (void)loadFields {
    NSMutableArray *fields = [NSMutableArray array];
    for (NSDictionary *info in self.quoteListFieldInfos) {
        NSString *title = info[@"name"];
        [fields addObject:title];
    }
    self.fields = fields;
}
//行情字段
- (NSMutableArray *)quoteListFieldInfos {
    if (!_quoteListFieldInfos) {
        _quoteListFieldInfos =  [@[
                                  @{
                                      @"name": @"最新",
                                      @"key": @"lastPrice"
                                  },
                                  @{
                                      @"name": @"涨幅",
                                      @"key": @"changeRate"
                                  },
                                  @{
                                      @"name": @"涨跌",
                                      @"key": @"change"
                                  },
                                  @{
                                      @"name": @"买价",
                                      @"key": @"buyPrice"
                                  },
                                  @{
                                      @"name": @"卖价",
                                      @"key": @"sellPrice"
                                  },
                                  @{
                                      @"name": @"总量",
                                      @"key": @"volume"
                                  },
                                  @{
                                      @"name": @"金额",
                                      @"key": @"amount"
                                  },
                                  @{
                                      @"name": @"持仓量",
                                      @"key": @"openInterest"
                                  }
                                  ]mutableCopy];
    }
    return _quoteListFieldInfos;
}
- (void)getMonthData {
    MExpireMonthRequest *request = [[MExpireMonthRequest alloc] init];
    request.stockID = self.stockId;
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        //[self setRefreshing:NO];
        if(resp.status == MResponseStatusSuccess) {
            //应答无误，处理数据更新画面
            MExpireMonthResponse *response = (MExpireMonthResponse *)resp;
            self.expireMonths = response.expireMonths;
            if (self.expireMonths) {
                //[self setRefreshing:YES];
                [self getData];
            }
        } else {
            //应答错误，显示错误信息
            //[QuoteStatusBar notifyWithText:resp.message image:nil andDuration:.6];
        }
    }  timeoutHandler:^(MRequest *request, BOOL *reload) {
        if (request.sendCount > 3) {
            *reload = NO;
        }
        else {
            *reload = YES;
        }
    }];
}
- (void)getData{
    MOptionTRequest *request = [[MOptionTRequest alloc] init];
    request.stockID = self.stockId;
    request.expireMonth = self.expireMonths[_expMonthIndex];
    //关闭计时器
    [self stopTimer];
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        [self startTimerWithTime:5 selector:@selector(getData)];
        //[self setRefreshing:NO];
        if(resp.status == MResponseStatusSuccess) {\
            //清空数据
            [self.putItems removeAllObjects];
            [self.callItems removeAllObjects];
            //应答无误，处理数据更新画面
            MOptionResponse *response = (MOptionResponse *)resp;
            self.optionItems = response.optionItems;
            self.optionItems = [self array:self.optionItems sortOptionByKey:@"exePriceNumber"];
            for(MOptionItem *item in _optionItems) {
                if (item.optionType == MOptionTypePut) {
                    [self.putItems addObject:item];
                } else {
                    [self.callItems addObject:item];
                }
            }
            [self.optionsScrollView reloadData];
            [self reloadHeaderData];
        } else {
            //应答错误，显示错误信息
            //[QuoteStatusBar notifyWithText:resp.message image:nil andDuration:.6];
        }
    }  timeoutHandler:^(MRequest *request, BOOL *reload) {
        if (request.sendCount > 3) {
            *reload = NO;
        }
        else {
            *reload = YES;
        }
    }];
}
- (void)reloadHeaderData {
    self.expireMonthLabel.text = [self formateDateStirng:self.expireMonths[_expMonthIndex]];
    
    if (self.optionItems.count > 0) {
        MOptionItem *optionItem = self.optionItems[0];
        if ([optionItem.remainDate intValue] < 0) {
            self.remainingDayLabel.text = @"已到期";
        } else {
            self.remainingDayLabel.text = [NSString stringWithFormat:@"剩余%@天", optionItem.remainDate];
        }
    }
}
- (NSArray *)array:(NSArray *)array sortOptionByKey:(NSString *)key  {
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
    return [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
}
- (void)startTimerWithTime:(NSTimeInterval)time selector:(SEL)sel {
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:sel userInfo:nil repeats:NO];
}
- (NSString *)formateDateStirng:(NSString *)DateString {
    NSString *year = [DateString substringWithRange:NSMakeRange(0, 2)];
    NSString *month = [DateString substringWithRange:NSMakeRange(2, 2)];
    return [NSString stringWithFormat:@"20%@年%@月",year,month];
}
- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (NSMutableArray*)reverse:(NSMutableArray *) array {
    NSMutableArray *reversedArray = [NSMutableArray arrayWithCapacity:[array count]];
    NSEnumerator *enumerator = [array reverseObjectEnumerator];
    for (id element in enumerator) {
        [reversedArray addObject:element];
    }
    return reversedArray;
}
- (UIColor *)renderColorWithStockItem:(MStockItem *)stockItem forFieldKey:(NSString *)key {
    if ([key isEqualToString:@"lastPrice"] ||
        [key isEqualToString:@"changeRate"] ||
        [key isEqualToString:@"change"]){
        if (stockItem.changeState == MChangeStateRise) {
            return _upColor;
        }else if (stockItem.changeState == MChangeStateDrop)
        {
            return _downColor;
        }else
        {
            return _aveColor;
        }
    }else if ([key isEqualToString:@"buyPrice"] ||
              [key isEqualToString:@"sellPrice"])
    {
        double value = [[stockItem valueForKey:key] doubleValue];
        double preClose = [stockItem.preClosePrice doubleValue];
        if (value != 0 && preClose != 0) {
            if (value > preClose) {
                return _upColor;
            }
            else if (value < preClose) {
                return _downColor;
            }
        }
        else {
            return _aveColor;
        }
    }else if ([key isEqualToString:@"volume"] ||
              [key isEqualToString:@"amount"]||
              [key isEqualToString:@"openInterest"])
    {
        return _volumeAmountColor;
    }
    return _aveColor;
}
#pragma mark MTOptionScrollViewDataSource
-(CGFloat)optionScrollView:(MTOptionScrollView *)optionScrollView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _callPutCellHeight;
}
//number of options
- (NSInteger)optionScrollView:(MTOptionScrollView *)optionScrollView numberOfRowsInOptionListView:(MTOptionScrollView *)optionsListView {
    return [_optionItems count]/2;
}

//number of strikes price
- (NSInteger)optionScrollView:(MTOptionScrollView *)optionScrollView numberOfRowsInTableView:(UITableView *)tableViewStPrice {
    return [_optionItems count]/2;
}

//number of columns
- (NSInteger)optionScrollView:(MTOptionScrollView *)optionScrollView numberOfColumnsInOptionListView:(MTOptionScrollView *)optionsListView {
    return _fields.count;
}

//put call data
- (id)optionScrollView:(MTOptionScrollView *)optionScrollView reuseView:(id)reuseView inRow:(NSInteger)inRow inColumn:(NSInteger)inColumn andOptionListViewType:(MTOptionListViewType)optionsListViewType {
    MOptionItem *optionItem = (optionsListViewType == MTOptionListViewTypeCall) ? self.callItems[inRow] : self.putItems[inRow];
    
    if (optionItem.optionType == MOptionTypeCall) {
        inColumn = [self.fields count] - 1 - inColumn;
    }
    NSDictionary *fieldInfo = self.quoteListFieldInfos[inColumn];
   // NSString *fieldClass = fieldInfo[@"class"];
    
    UILabel *label = (UILabel *)reuseView;
    if (!label) {
        label = [[UILabel alloc] init];
    }
    NSString *columnKey = fieldInfo[@"key"];
    NSString *text = [optionItem valueForKeyPath:columnKey];
    if ([columnKey isEqualToString:@"changeRate"]) {
        text = [text stringByAppendingString:@"%"];
    }else if ([columnKey isEqualToString:@"amount"])
    {
        text = [MApiFormatter mapi_formatChineseAmountWithValue:text.doubleValue];
    }
//    else if ([columnKey isEqualToString:@"volume"])
//    {
//        text = [MApiFormatter formatChineseUnitWithValue:text.doubleValue];
//    }else if ([columnKey isEqualToString:@"openInterest"])
//    {
//        text = [MApiFormatter formatChineseUnitWithValue:text.doubleValue];
//    }
//    if ([label isKindOfClass:[CTPriceLabel class]]) {
//        [(CTPriceLabel *)label renderColorWithStockItem:optionItem forFieldKey:columnKey];
//    }
    label.text = MAPI_CTUIFactoryStringForValue(text);
    label.backgroundColor =optionsListViewType == MTOptionListViewTypeCall?_callCellBackgroundColor:_putCellBackgroundColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [label.text isEqualToString:@"一"]?_nullColor: [self renderColorWithStockItem:optionItem forFieldKey:columnKey];
    label.font = [UIFont  systemFontOfSize:_callPutCellFontSize];
    
    return label;
}

//Strike Price
- (id)optionScrollView:(MTOptionScrollView *)optionScrollView reuseCenterView:(id)reuseCenterView inRow:(NSInteger)inRow {
    UILabel *label = reuseCenterView;
    if (!label) {
        label =[[UILabel alloc] init];
    }
    MOptionItem *callOption = self.callItems[inRow];
    label.backgroundColor = _exPriceBackgroundColor;
    label.textAlignment =NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:_exPriceFontSize];
    double value = [callOption.exePrice doubleValue];
    label.text = [NSString stringWithFormat:@"%.2f",value] ;
    label.textColor = _exPriceColor;
    label.adjustsFontSizeToFitWidth = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
    label.minimumScaleFactor = 0.5;
#else
    label.minimumFontSize = 6.0;
#endif
    return label;
}

#pragma mark MTOptionScrollViewDelegate

- (CGFloat)optionScrollView:(MTOptionScrollView *)optionScrollView widthInColumn:(NSInteger)inColumn {
    return self.columnWidth;
}

- (id)optionScrollView:(MTOptionScrollView *)optionScrollView reuseViewForHeader:(id)reuseViewForHeader inColumn:(NSInteger)inColumn andOptionListViewType:(MTOptionListViewType)optionsListViewType {
    
    UILabel *label =[[UILabel alloc]init];
    if (optionsListViewType == MTOptionListViewTypePut) {
        label.text = _fields[inColumn];
    }else{
        label.text = [self reverse:_fields][inColumn];
    }
    
    label.textColor = _callPutCellHeaderTitleColor;
    label.backgroundColor = _callPutCellHeaderBackgroundColor;
    label.textAlignment =NSTextAlignmentCenter;
    label.font =[UIFont systemFontOfSize:_callPutCellHeaderTitleFontSize];
    return label;
}

- (void)optionScrollView:(MTOptionScrollView *)optionScrollView didSelectRow:(NSInteger)row inOptionListViewType:(MTOptionListViewType)optionsListViewType {
    
    NSArray *items = nil;
    if (optionsListViewType == MTOptionListViewTypeCall) {
        items = self.callItems;
    }
    else {
        items = self.putItems;
    }
    //[self pushToSynthesizeQuoteWithStockItem:items[row] stockItems:items];
    if (self.delegate && [self.delegate respondsToSelector:@selector(optionView:didSelectStockItem:stockItems:)]) {
        [self.delegate optionView:self didSelectStockItem:items[row] stockItems:items];
    }
}

#pragma mark creat Method
- (void)createLabelCall {
    UILabel *labelCall = [[UILabel alloc] initWithFrame:CGRectMake(0, KOptionExpireDateWidth, CGRectGetWidth(self.frame)/2, MAX(kOptionsListsViewLabelCallAndPutHeight, _callPutTitleFontSize))];
    labelCall.text = kOptionsListsViewLabelCallText;
    labelCall.backgroundColor = _callPutBackgroundColor;
    labelCall.textColor = _callPutTitleColor;
    labelCall.textAlignment = NSTextAlignmentCenter;
    labelCall.font = [UIFont systemFontOfSize:_callPutTitleFontSize];
    labelCall.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:labelCall];
}

- (void)createLabelPut {
    UILabel *labelPut = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2, KOptionExpireDateWidth, CGRectGetWidth(self.frame)/2, MAX(kOptionsListsViewLabelCallAndPutHeight, _callPutTitleFontSize))];
    labelPut.text =kOptionsListsViewLabelPutText;
    labelPut.backgroundColor = _callPutBackgroundColor;
    labelPut.textColor = _callPutTitleColor;
    labelPut.textAlignment = NSTextAlignmentCenter;
    labelPut.font = [UIFont systemFontOfSize:_callPutTitleFontSize];
    labelPut.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:labelPut];
}


#pragma mark property
- (UIView *)toptionHeaderView {
    if (!_toptionHeaderView) {
        _toptionHeaderView = [[UIView alloc] init];
        _toptionHeaderView.backgroundColor = _expiryDateBackgroundColor;
        [_toptionHeaderView addSubview:self.titleDayLabel];
        [_toptionHeaderView addSubview:self.expireMonthLabel];
        [_toptionHeaderView addSubview:self.remainingDayLabel];
        
        self.titleDayLabel.backgroundColor = [UIColor clearColor];
        self.expireMonthLabel.backgroundColor = [UIColor clearColor];
        self.remainingDayLabel.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer* tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChanged:)];
        [_toptionHeaderView addGestureRecognizer:tapGest];
    }
    return _toptionHeaderView;
}

- (UILabel *)titleDayLabel {
    if (!_titleDayLabel) {
        _titleDayLabel = [[UILabel alloc]init];
        _titleDayLabel.text = @"到期日期:";
        _titleDayLabel.textColor = _expiryDateColor;
        _titleDayLabel.font = [UIFont systemFontOfSize:_expiryDateFontSize];
    }
    return _titleDayLabel;
}

- (UILabel *)expireMonthLabel {
    if (!_expireMonthLabel) {
        _expireMonthLabel = [[UILabel alloc]init];
        _expireMonthLabel.font = [UIFont systemFontOfSize:_expiryDateFontSize];
        _expireMonthLabel.textColor = _expiryDateMonthColor;
    }
    return _expireMonthLabel;
}

- (UILabel *)remainingDayLabel {
    if (!_remainingDayLabel) {
        _remainingDayLabel = [[UILabel alloc]init];
        _remainingDayLabel.textColor = _expiryDateColor;
        _remainingDayLabel.font = [UIFont systemFontOfSize:_expiryDateFontSize];
    }
    return _remainingDayLabel;
}

- (UIActionSheet *)actionSheet {
    if (!_actionSheet) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择到期月份" delegate:(id)self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:[self formateDateStirng:self.expireMonths[0]],
                        [self formateDateStirng:self.expireMonths[1]],
                        [self formateDateStirng:self.expireMonths[2]],
                        [self formateDateStirng:self.expireMonths[3]],nil];
    }
    return _actionSheet;
}
-(MTOptionScrollView *)optionsScrollView {
    if (!_optionsScrollView) {
        _optionsScrollView = [[MTOptionScrollView alloc] init];
        _optionsScrollView.clipsToBounds = YES;
        _optionsScrollView.dataSource = self;
        _optionsScrollView.mdelegate = self;
        _optionsScrollView.callPutCellHeaderBackgroundColor = _callPutCellHeaderBackgroundColor;
        _optionsScrollView.callPutCellHeaderTitleColor = _callPutCellHeaderTitleColor;
        _optionsScrollView.callPutCellHeaderTitleFontSize = _callPutCellHeaderTitleFontSize;
        _optionsScrollView.callPutCellHeaderHeght = _callPutCellHeaderHeight;
    }
    return _optionsScrollView;
}
- (NSArray *)putItems {
    if (!_putItems) {
        _putItems = [[NSMutableArray alloc]init];
    }
    return _putItems;
}

- (NSArray *)callItems {
    if (!_callItems) {
        _callItems = [[NSMutableArray alloc]init];
    }
    return _callItems;
}
#pragma mark - Action

- (void)tapChanged:(id)sender {
    [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    _expMonthIndex = buttonIndex;
    [self getData];
    [self reloadHeaderData];
}
@end