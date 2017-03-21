//
//  MTopPriceDetailView.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/8/8.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MTopPriceDetailView.h"
#import "MApi.h"
#import "MApiFormatter.h"

#import "MApi_BestBuySellTableViewCell.h"
#import "MApi_TickTableViewCell.h"
#import "MApi_BestHeaderView.h"

static const NSInteger kChartViewBestPriceVolumeCount = 5 ;
@interface MStockItem (MTopPriceDetailView)

@end

@implementation MStockItem (MTopPriceDetailView)

- (NSArray *)mapi_formattedBuyVolumes {
    NSMutableArray *volumes = [NSMutableArray array];
    for (NSString *volume in self.buyVolumes) {
        [volumes addObject:[MApiFormatter mapi_formatTickItemsUnitWithValue:[volume doubleValue]]];
    }
    return volumes;
}

- (NSArray *)mapi_formattedSellVolumes {
    NSMutableArray *volumes = [NSMutableArray array];
    for (NSString *volume in self.sellVolumes) {
        [volumes addObject:[MApiFormatter mapi_formatTickItemsUnitWithValue:[volume doubleValue]]];
    }
    return volumes;
}
@end

@interface MTickItem (MTopPriceDetailView)

@end
@implementation MTickItem (MTopPriceDetailView)

- (NSString *)mapi_formattedTradeVolume {
    return [MApiFormatter mapi_formatTickItemsUnitWithValue:[self.tradeVolume doubleValue]];
}

@end

@interface MTopPriceDetailView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MStockItem *stockItem;
@property (nonatomic, strong) MSnapQuoteRequest *request;
@end

@implementation MTopPriceDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [self addSubview:_tableView];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"五档", @"明细"]];
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        
        _segmentBorderColor = [UIColor whiteColor];
        _segmentFont = [UIFont systemFontOfSize:12.0];
        
        _segmentBackgroundColor = [UIColor whiteColor];
        _segmentSelectedBackgroundColor = [UIColor blackColor];
        
        _segmentTextColor = [UIColor blackColor];
        _segmentSelectedTextColor = [UIColor whiteColor];
        _segmentHeight = 30.0;
        
        _riseTextColor = [UIColor redColor];
        _dropTextColor = [UIColor greenColor];
        _flatTextColor = [UIColor whiteColor];
        _volumeTextColor = [UIColor whiteColor];
        _textColor = [UIColor whiteColor];
        _textFont = [UIFont systemFontOfSize:12.0];
        
        [self addSubview:_segmentedControl];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self _updateSegmentStyle];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _segmentedControl.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), self.segmentHeight);
    _tableView.frame = CGRectMake(0, CGRectGetMaxY(_segmentedControl.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_segmentedControl.frame));
    
}


#pragma mark - public methods

- (void)reloadData {
    [self.request cancel];
    self.request = [[MSnapQuoteRequest alloc] init];
    self.request.code = self.code;
    [MApi sendRequest:self.request completionHandler:^(MResponse *resp) {
        if (resp.status == MResponseStatusSuccess) {
            MStockItem *stockItem = ((MSnapQuoteResponse *)resp).stockItem;
            if (stockItem && stockItem.subtype) {
                [self reloadDataWithStockItem:stockItem];
            }
        }
    }];
}

- (void)reloadDataWithStockItem:(MStockItem *)stockItem {
    self.stockItem = stockItem;
    [self.tableView reloadData];
}


#pragma mark - property

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex {
    self.segmentedControl.selectedSegmentIndex = selectedSegmentIndex;
    if (self.window) {
        [self reloadData];
    }
}

- (NSUInteger)selectedSegmentIndex {
    return self.segmentedControl.selectedSegmentIndex;
}

- (void)setSegmentBorderColor:(UIColor *)segmentBorderColor {
    _segmentBorderColor = segmentBorderColor;
    if (self.window) {
        [self _updateSegmentStyle];
    }
}

- (void)setSegmentFont:(UIFont *)segmentFont {
    _segmentFont = segmentFont;
    if (self.window) {
        [self _updateSegmentStyle];
    }
}

- (void)setSegmentBackgroundColor:(UIColor *)segmentBackgroundColor {
    _segmentBackgroundColor = segmentBackgroundColor;
    if (self.window) {
        [self _updateSegmentStyle];
    }
}

- (void)setSegmentSelectedBackgroundColor:(UIColor *)segmentSelectedBackgroundColor {
    _segmentSelectedBackgroundColor = segmentSelectedBackgroundColor;
    if (self.window) {
        [self _updateSegmentStyle];
    }
}

- (void)setSegmentTextColor:(UIColor *)segmentTextColor {
    _segmentTextColor = segmentTextColor;
    if (self.window) {
        [self _updateSegmentStyle];
    }
}

- (void)setSegmentSelectedTextColor:(UIColor *)segmentSelectedTextColor {
    _segmentSelectedTextColor = segmentSelectedTextColor;
    if (self.window) {
        [self _updateSegmentStyle];
    }
}

- (void)setRiseTextColor:(UIColor *)riseTextColor {
    _riseTextColor = riseTextColor;
    if (self.window) {
        [self.tableView reloadData];
    }
}

- (void)setDropTextColor:(UIColor *)dropTextColor {
    _dropTextColor = dropTextColor;
    if (self.window) {
        [self.tableView reloadData];
    }
}

- (void)setFlatTextColor:(UIColor *)flatTextColor {
    _flatTextColor = flatTextColor;
    if (self.window) {
        [self.tableView reloadData];
    }
}

- (void)setVolumeTextColor:(UIColor *)volumeTextColor {
    _volumeTextColor = volumeTextColor;
    if (self.window) {
        [self.tableView reloadData];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (self.window) {
        [self.tableView reloadData];
    }
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    if (self.window) {
        [self.tableView reloadData];
    }
}

#pragma mark - private

- (UIImage *)_imageWithBorderColor:(UIColor *)borderColor backgroundColor:(UIColor *)backgroundColor {
    CGSize segmentSize = CGSizeMake(20, self.segmentHeight);
    UIGraphicsBeginImageContextWithOptions(segmentSize, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, segmentSize.width, segmentSize.height);
    //backgoundColor
    CGContextSetFillColorWithColor(ctx, backgroundColor.CGColor);
    CGContextFillRect(ctx, rect);
    
    //borderColor
    CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);
    CGContextSetLineWidth(ctx, 1.*[UIScreen mainScreen].scale);
    CGContextStrokeRect(ctx, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)_deviderImage:(UIColor *)color {
    CGSize segmentSize = CGSizeMake(20, self.segmentHeight);
    CGSize size = CGSizeMake(1, segmentSize.height);
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //dividerColor
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, 1*[UIScreen mainScreen].scale);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, 0, segmentSize.height);
    CGContextStrokePath(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

- (void)_updateSegmentStyle {
    UIImage *imageNormal = [self _imageWithBorderColor:self.segmentBorderColor
                                       backgroundColor:self.segmentBackgroundColor];
    UIImage *imageSelected = [self _imageWithBorderColor:self.segmentBorderColor
                                         backgroundColor:self.segmentSelectedBackgroundColor];
    [_segmentedControl setBackgroundImage:imageNormal forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:imageSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segmentedControl setDividerImage:[self _deviderImage:self.segmentBorderColor] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [_segmentedControl setTitleTextAttributes:@{
                                                UITextAttributeTextColor: self.segmentSelectedTextColor,
                                                UITextAttributeFont: self.segmentFont,
                                                NSForegroundColorAttributeName:self.segmentSelectedTextColor,
                                                NSFontAttributeName: self.segmentFont
                                                }
                                     forState:UIControlStateSelected];
    [_segmentedControl setTitleTextAttributes:@{
                                                UITextAttributeTextColor: self.segmentTextColor,
                                                UITextAttributeFont: self.segmentFont,
                                                NSForegroundColorAttributeName:self.segmentTextColor,
                                                NSFontAttributeName: self.segmentFont
                                                }
                                     forState:UIControlStateNormal];

}

- (void)_renderLabelTextColor:(UILabel *)label stockItem:(MStockItem *)stockItem {
    long long value = label.text.doubleValue * 100000;
    long long preClose = stockItem.preClosePrice.doubleValue * 100000;
    if (value > preClose) {
        label.textColor = self.riseTextColor;
    } else if (value < preClose) {
        label.textColor = self.dropTextColor;
    } else {
        label.textColor = self.flatTextColor;
    }
}

- (void)segmentChanged:(UISegmentedControl *)segmentedControl {
    [self.tableView reloadData]; // reload UI first
    [self reloadData];
}


#pragma mark - Table view data surce

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        //最佳五档有分上下两个section
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: //五档
        {
            return kChartViewBestPriceVolumeCount;
        }
        case 1: //明细
        {
            NSArray *tickItems = self.stockItem.tickItems;
            return tickItems.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        MApi_BestBuySellTableViewCell *cell = (MApi_BestBuySellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"BestBuySellTableViewCell"];
        
        if (!cell) {
            cell = [[MApi_BestBuySellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BestBuySellTableViewCell"];
            cell.backgroundColor = cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell setTextFont:self.textFont];
        
        NSString *price = nil;
        NSString *volume = nil;
        if (indexPath.section == 0) {
            NSInteger index = kChartViewBestPriceVolumeCount - (long)indexPath.row;
            cell.buysellLabel.text = [NSString stringWithFormat:@"卖%ld", (long)index];
            
            index = index - 1;
            if (index < self.stockItem.sellPrices.count) {
                price = self.stockItem.sellPrices[index];
            }
            if (index < self.stockItem.sellVolumes.count) {
                volume = self.stockItem.mapi_formattedSellVolumes[index];
            }
        }
        else {
            NSInteger index = (long)indexPath.row + 1;
            cell.buysellLabel.text = [NSString stringWithFormat:@"买%ld", (long)index];
            
            if ((index = self.stockItem.buyPrices.count - indexPath.row - 1) >= 0) {
                price = self.stockItem.buyPrices[index];
            }
            if ((index = self.stockItem.buyVolumes.count - indexPath.row - 1) >= 0) {
                volume = self.stockItem.mapi_formattedBuyVolumes[index];
            }
        }
        cell.buysellLabel.textColor = self.textColor;
        
        cell.priceLabel.text = MApiFormatterStringForValue(price);
        [self _renderLabelTextColor:cell.priceLabel stockItem:self.stockItem];
        
        cell.volumeLabel.text = MApiFormatterStringForValue(volume);
        cell.volumeLabel.textColor = self.volumeTextColor;
        
        return cell;
    } else {
        MApi_TickTableViewCell *cell = (MApi_TickTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TickTableViewCell"];
        
        if (!cell) {
            cell = [[MApi_TickTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TickTableViewCell"];
            cell.backgroundColor = cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        [cell setTextFont:self.textFont];
        
        MTickItem *tickItem = self.stockItem.tickItems[indexPath.row];
        cell.timeLabel.text = tickItem.time4;
        cell.timeLabel.textColor = self.textColor;
        
        cell.priceLabel.text = tickItem.tradePrice;
        [self _renderLabelTextColor:cell.priceLabel stockItem:self.stockItem];
        
        cell.volumeLabel.text = tickItem.mapi_formattedTradeVolume;
        cell.volumeLabel.textColor = self.volumeTextColor;
        
        return cell;
    }
}



#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        if (section == 1) {
            MApi_BestHeaderView * headerView =[[MApi_BestHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 5)];
            return headerView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        if (section == 1) {
            return 5;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat viewHeight = CGRectGetHeight(tableView.frame);
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        CGFloat cellHeight = (viewHeight - 10) / 10.;
        return MAX(15., cellHeight);
    }
    else {
        CGFloat cellHeight = viewHeight / 10.;
        return MAX(15., cellHeight);
    }
}

@end
