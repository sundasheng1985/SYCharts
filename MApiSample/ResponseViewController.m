//
//  ResponseViewController.m
//  MAPI
//
//  Created by Mitake on 2015/5/29.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "ResponseViewController.h"
#import "MApi.h"

@interface ResponseViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation ResponseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.text = self.responseText;
}

- (void)viewWillAppear:(BOOL)animated {
    NSDictionary *parmInfo = self.info[@"param"];
    Class class = NSClassFromString(self.info[@"request"]);
    MRequest *request = [[class alloc]init];
    for (NSDictionary *dict in parmInfo) {
        NSString *type = dict[@"type"];
        id value = dict [@"value"];
        if ([type isEqualToString:@"MChartType"]) {
            value = [NSNumber numberWithInt:[self formateChartTypeString:value]];
        }
        else if ([type isEqualToString:@"MOHLCPeriod"]) {
            value = [NSNumber numberWithInt:[self formateMOHLCPeriodString:value]];
        } else if ([type isEqualToString:@"MOptionType"]) {
            value = [NSNumber numberWithInt:[self formateOptionTypeString:value]];
        }
        
        [request setValue:value forKey:dict[@"key"]];
    }
    
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        if(resp.status == MResponseStatusSuccess) {
            self.textView.text = [resp description];
        } else {
            //应答错误，显示错误信息
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:resp.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"%@",resp.message);
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - formate method

- (int)formateChartTypeString:(id)chartTypeString {
    NSDictionary *chartTypeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInteger:MChartTypeOneDay],@"MChartTypeOneDay",
                                   [NSNumber numberWithInteger:MChartTypeFiveDays],@"MChartTypeFiveDays",nil];
    
    return [[chartTypeDict objectForKey:chartTypeString] intValue];
}

- (int)formateMOHLCPeriodString:(id)ohlcPeriodString {
    NSDictionary *ohlcDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInteger:MOHLCPeriodDay],@"MOHLCPeriodDay",
                              [NSNumber numberWithInteger:MOHLCPeriodWeek],@"MOHLCPeriodWeek",
                              [NSNumber numberWithInteger:MOHLCPeriodMonth],@"MOHLCPeriodMonth",nil];
    
    return [[ohlcDict objectForKey:ohlcPeriodString] intValue];
}

- (int)formateOptionTypeString:(id)optionTypeString {
    NSDictionary *optionDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInteger:MOptionTypeUnknown],@"MOptionTypeUnknown",
                                [NSNumber numberWithInteger:MOptionTypePut],@"MOptionTypePut",
                                [NSNumber numberWithInteger:MOptionTypeCall],@"MOptionTypeCall",nil];
    
    return [[optionDict objectForKey:optionTypeString] intValue];
}

@end
