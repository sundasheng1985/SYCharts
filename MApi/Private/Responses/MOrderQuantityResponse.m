//
//  MOrderQuantityResponse.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/6/30.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MOrderQuantityResponse.h"
#import "MOrderQuantityItem.h"

@implementation MOrderQuantityResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        MRESPONSE_TRY_PARSE_DATA_START
        
        MOrderQuantityRequest *r = (MOrderQuantityRequest *)request;
        NSString *market = [r.code pathExtension];
        NSString *subtype = r.subtype;
        
        NSArray *buyItems = nil;
        NSArray *sellItems = nil;
        [MOrderQuantityResponse parseData:data market:market subtype:subtype buy:&buyItems sell:&sellItems];
        self.buyItems = buyItems;
        self.sellItems = sellItems;
        
        MRESPONSE_TRY_PARSE_DATA_END
    }
    return self;
}

+ (void)parseData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype buy:(NSArray **)buyItems sell:(NSArray **)sellItems {
    NSArray *sectionDatas = [data componentsSeparatedByByte:0x03];
    
    NSMutableArray *mutableBuyItems = [NSMutableArray array];
    NSMutableArray *mutableSellItems = [NSMutableArray array];
    for (NSData *data in sectionDatas) {
        if (mutableSellItems.count < 10) {
            [mutableSellItems addObject:[self itemsWithData:data market:market subtype:subtype]];
        } else {
            [mutableBuyItems addObject:[self itemsWithData:data market:market subtype:subtype]];
        }
    }
    *buyItems = mutableBuyItems;
    *sellItems = [[mutableSellItems reverseObjectEnumerator] allObjects];
}

+ (NSArray *)itemsWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    NSMutableArray *items = [NSMutableArray array];
    NSArray *rowDatas = [data componentsSeparatedByByte:0x02];
    
    for (NSData *rowData in rowDatas) {
        MOrderQuantityItem *item = [[MOrderQuantityItem alloc] initWithData:rowData market:market subtype:subtype];
        if (item) {
            [items addObject:item];
        }
    }
    return items;
}
// TCPPushString =
// [{1=3510, 2=4700, 3=1000, 4=2000, 5=500, 6=1100, 7=100, 8=1000, 9=4500, 10=500, 11=200, 12=6300, 13=5000, 14=1000, 15=1000, 16=1000, 17=3400, 18=3000, 19=100, 20=3000, 21=51500, 22=55810, 23=13800, 24=30840, 25=400, 26=11800, 27=2000, 28=4700, 29=2000, 30=31900, 31=6400}, {}, {}, {}, {}, {}, {}, {}, {}, {}]

+ (NSArray *)orderQuantitiesWithTCPPushString:(NSString *)TCPPushString market:(NSString *)market subtype:(NSString *)subtype {
    NSError *error = nil;
    NSRegularExpression *testExpression = [NSRegularExpression regularExpressionWithPattern:@"\\{.*?\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSMutableArray *array = [NSMutableArray array];
    if (!error) {
        [testExpression enumerateMatchesInString:TCPPushString options:0 range:NSMakeRange(0, [TCPPushString length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            NSString *itemString = [TCPPushString substringWithRange:NSMakeRange(result.range.location+1, result.range.length-2)];
            if (itemString.length > 0) {
                NSMutableArray *itemArray = [NSMutableArray array];
                [[[itemString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MOrderQuantityItem *item = [[MOrderQuantityItem alloc] initWithRowString:obj market:market subtype:subtype];
                    if (item) {
                        [itemArray addObject:item];
                    }
                }];
                [array addObject:itemArray];
            }
        }];
    }
    return [array copy];
}



@end
