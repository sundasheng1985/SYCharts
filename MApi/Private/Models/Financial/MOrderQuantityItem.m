//
//  MOrderQuantityItem.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/7/1.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MOrderQuantityItem.h"

@implementation MOrderQuantityItem

- (instancetype)initWithRowString:(NSString *)rowString market:(NSString *)market subtype:(NSString *)subtype {
    if (self = [super initWithData:nil]) {
        NSArray *comp = [rowString componentsSeparatedByString:@"="];
        if (comp.count > 0) {
            self.volume = [MApiHelper formatVolume:comp[1] market:market subtype:subtype];
        }
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    NSString *string = [data convertToUTF8String];
    return [self initWithRowString:string market:market subtype:subtype];
    
}

@end
