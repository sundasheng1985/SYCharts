//
//  MChartResponse.h
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MResponse.h"

@interface MChartResponse ()
/// server返回的指数交易撮合时间, 用在MTrendChartView涨跌停股票补线
@property (nonatomic, copy) NSString *systemDatetime;
@end
