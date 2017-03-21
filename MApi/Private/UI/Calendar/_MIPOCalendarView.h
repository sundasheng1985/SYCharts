//
//  MXNewStockView.h
//  NewStock
//
//  Created by IOS_HMX on 16/7/1.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MApi.h"
#import "MXCalendarView.h"

@interface MIPOCalendarView ()<UITableViewDataSource,UITableViewDelegate,MXCalendarViewDelegate>
{
    @package
    __block int _requestCount;
    NSArray *_holidayArray;
    NSArray *_calendarInfoArray;
    NSMutableArray *_newsList;
    UILabel *_noDataMessage;
    MIPOCalendarRequest *_request;
}
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) MXCalendarView *calendarView;

@end
