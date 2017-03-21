//
//  MStaticDataItem.m
//  MAPI
//
//  Created by IOS_HMX on 16/12/14.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MStaticDataItem.h"
#import "MBoardInfoItem.h"
@implementation MStaticDataItem
- (instancetype)initWithData:(NSData *)data requestInfo:(NSString *)param
{
    self = [super initWithData:data];
    if (self) {
        NSArray *requestParam = [param componentsSeparatedByString:@","];
        NSArray *itemData = [data componentsSeparatedByByte:0x02];
        [itemData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *value = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
            if (idx > requestParam.count-1) *stop = YES;
            NSString *key = requestParam[idx];
            if ([key isEqualToString:@"hki"]) {
                [[value componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx == 0) {
                        self.HFlag = [obj boolValue];
                    }else if(idx == 1) {
                        self.SFlag = [obj boolValue];
                    }
                }];
            }else if([key isEqualToString:@"bk"]) {
                self.boardInfoItems = [self boardInfoItemWithString:value];
            }else if ([key isEqualToString:@"su"]) {
                self.financeFlag = [value boolValue];
            }else if ([key isEqualToString:@"bu"]) {
                self.securityFlag = [value boolValue];
            }
        }];

    }
    return self;
}
- (NSArray *)boardInfoItemWithString:(NSString *)string
{
    NSMutableArray *array = [NSMutableArray array];
    if (string && string.length > 0) {
        NSArray *items = [string componentsSeparatedByString:@","];
        if (items && items.count > 0) {
            [items enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && obj.length > 0) {
                    MBoardInfoItem *item = [[MBoardInfoItem alloc] initWithString:obj];
                    [array addObject:item];
                }
            }];
        }
    }
    return array;
}
@end
