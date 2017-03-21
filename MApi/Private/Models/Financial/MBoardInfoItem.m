//
//  MBoardInfoItem.m
//  MAPI
//
//  Created by IOS_HMX on 16/12/14.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MBoardInfoItem.h"

@implementation MBoardInfoItem
- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    if (self) {
        if (string && string.length > 0) {
            NSArray *info = [string componentsSeparatedByString:@"|"];
            if (info && info.count >= 1) {
                self.ID = info[0];
            }
            if (info && info.count >= 2) {
                self.name = info[1];
            }
        }
    }
    return self;
}
@end
