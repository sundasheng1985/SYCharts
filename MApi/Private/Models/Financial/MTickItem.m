//
//  MTickItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MTickItem.h"

#pragma mark MTickItem

@implementation MTickItem

- (instancetype)initWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {

    if (self = [super initWithData:data market:market subtype:subtype]) {
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];
        if (dataCols.count < 4) {
            return nil;
        }
        
        if (dataCols.count >= 6) { // MTimeTickResponse
            
            NSString *bstype = [dataCols[0] convertToUTF8String];
            
            if (bstype.length > 0) {
                self.type = [bstype isEqual:@"B"] ? MBSVolumeTypeBuy : MBSVolumeTypeSell;
            }
            
            NSString *datetime = nil;;
            if ([dataCols[1] length] > 0) {
                datetime = [[dataCols[1] convertToUTF8String] transform_decodeString];
            }
            _datetime = [[NSString stringWithFormat:@"%08ld", (long)[datetime integerValue]] copy];
            
            NSString *buyPrice = nil;;
            if ([dataCols[2] length] > 0) {
                buyPrice = [[dataCols[2] convertToUTF8String] transform_decodeString];
            }
            self.buyPrice = [MApiHelper formatPrice:[buyPrice doubleValue] market:market subtype:subtype];
            
            NSString *sellPrice = nil;;
            if ([dataCols[3] length] > 0) {
                sellPrice = [[dataCols[3] convertToUTF8String] transform_decodeString];
            }
            self.sellPrice = [MApiHelper formatPrice:[sellPrice doubleValue] market:market subtype:subtype];
            
            NSString *tradeVolume = nil;
            if ([dataCols[4] length] > 0) {
                tradeVolume = [[dataCols[4] convertToUTF8String] transform_decodeString];
            }
            self.tradeVolume = [MApiHelper formatVolume:tradeVolume market:market subtype:subtype];
            
            NSString *tradePrice = nil;
            if ([dataCols[5] length] > 0) {
                tradePrice = [[dataCols[5] convertToUTF8String] transform_decodeString];
            }
            self.tradePrice = [MApiHelper formatPrice:[tradePrice doubleValue] market:market subtype:subtype];
            
            NSString *AMS = nil;
            if (dataCols.count > 6 && [dataCols[6] length] > 0) {
                AMS = [[dataCols[6] convertToUTF8String] transform_decodeString];
                self.AMSFlag = [AMS integerValue];
            } else {
                self.AMSFlag = MTimeTickAMSFlagUnknown;
            }
        }
        else if (dataCols.count >= 4) { /// snap里面的十档分时明细
            NSString *bstype = [dataCols[0] convertToUTF8String];
            
            if (bstype.length > 0) {
                self.type = [bstype isEqual:@"B"] ? MBSVolumeTypeBuy : MBSVolumeTypeSell;
            }
            
            NSString *dataColsString1;
            if ([dataCols[1] length] > 0) {
                dataColsString1 = [dataCols[1] convertToUTF8String];
                dataColsString1 = [dataColsString1 transform_decodeString];
            } else {
                [dataCols[1] convertToUTF8String];
            }
            _datetime = [[NSString stringWithFormat:@"%08ld", (long)[dataColsString1 integerValue]] copy];
            
            NSString *dataColsString2;
            if ([dataCols[2] length] > 0) {
                dataColsString2 = [dataCols[2] convertToUTF8String];
                dataColsString2 = [dataColsString2 transform_decodeString];
            } else {
                [dataCols[2] convertToUTF8String];
            }
            NSString *volume = dataColsString2;
            
            self.tradeVolume = [MApiHelper formatVolume:volume market:market subtype:subtype];
            
            NSString *dataColsString3;
            if ([dataCols[3] length] > 0) {
                dataColsString3 = [dataCols[3] convertToUTF8String];
                dataColsString3 = [dataColsString3 transform_decodeString];
            } else {
                [dataCols[3] convertToUTF8String];
            }
            NSString *price = dataColsString3;
            
            self.tradePrice = [MApiHelper formatPrice:[price doubleValue] market:market subtype:subtype];
            
            NSString *AMS = nil;
            if (dataCols.count > 4 && [dataCols[4] length] > 0) {
                AMS = [[dataCols[4] convertToUTF8String] transform_decodeString];
                self.AMSFlag = [AMS integerValue];
            } else {
                self.AMSFlag = MTimeTickAMSFlagUnknown;
            }
            
        }
        
    }
    
    return self;
}

- (NSString *)datetime {
    if ([_datetime length] >= 4) {
        return [NSString stringWithFormat:@"%@:%@",
                [_datetime substringWithRange:NSMakeRange(0, 2)],
                [_datetime substringWithRange:NSMakeRange(2, 2)]];
    }
    return nil;
}

- (NSString *)time {
    return _datetime;
}


- (void)setOriginal_Datetime:(NSString *)datetime {
    _datetime = [datetime copy];
}

@end

@implementation MTimeTickItem

- (instancetype)initWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    if ((self = [super init])) {
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];
        if (dataCols.count < 5) {
            return nil;
        }
        
        NSString *bstype = [dataCols[0] convertToUTF8String];
        if (bstype.length > 0) {
            self.type = [bstype isEqual:@"B"] ? MBSVolumeTypeBuy : MBSVolumeTypeSell;
        }
        
        NSString *dataColsString1;
        if ([dataCols[1] length] > 0) {
            dataColsString1 = [dataCols[1] convertToUTF8String];
            dataColsString1 = [dataColsString1 transform_decodeString];
        } else {
            [dataCols[1] convertToUTF8String];
        }
        [super setOriginal_Datetime:[NSString stringWithFormat:@"%08ld", (long)[dataColsString1 integerValue]]];
        
        NSString *dataColsString2;
        if ([dataCols[2] length] > 0) {
            dataColsString2 = [dataCols[2] convertToUTF8String];
            dataColsString2 = [dataColsString2 transform_decodeString];
        } else {
            [dataCols[2] convertToUTF8String];
        }
        NSString *volume = dataColsString2;
        
        self.tradeVolume = [MApiHelper formatVolume:volume market:market subtype:subtype];
        
        NSString *dataColsString3;
        if ([dataCols[3] length] > 0) {
            dataColsString3 = [dataCols[3] convertToUTF8String];
            dataColsString3 = [dataColsString3 transform_decodeString];
        } else {
            [dataCols[3] convertToUTF8String];
        }
        NSString *price = dataColsString3;
        
        self.tradePrice = [MApiHelper formatPrice:[price doubleValue] market:market subtype:subtype];
    
        NSString *sectionRange = nil;
        if (dataCols.count > 5 && [dataCols[5] length] > 0) {
            sectionRange = [dataCols[5] convertToUTF8String];
        }
        self.sectionRange = sectionRange;
    }
    return self;
}

@end

@implementation MTimeTickDetailItem

- (instancetype)initWithData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype {
    if ((self = [super init])) {
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];
        if (dataCols.count < 5) {
            return nil;
        }
        
        NSString *bstype = [dataCols[0] convertToUTF8String];
        if (bstype.length > 0) {
            self.type = [bstype isEqual:@"B"] ? MBSVolumeTypeBuy : MBSVolumeTypeSell;
        }
        
        NSString *dataColsString1;
        if ([dataCols[1] length] > 0) {
            dataColsString1 = [dataCols[1] convertToUTF8String];
            dataColsString1 = [dataColsString1 transform_decodeString];
        } else {
            [dataCols[1] convertToUTF8String];
        }
        [super setOriginal_Datetime:[NSString stringWithFormat:@"%08ld", (long)[dataColsString1 integerValue]]];
        
        NSString *dataColsString2;
        if ([dataCols[2] length] > 0) {
            dataColsString2 = [dataCols[2] convertToUTF8String];
            dataColsString2 = [dataColsString2 transform_decodeString];
        } else {
            [dataCols[2] convertToUTF8String];
        }
        NSString *volume = dataColsString2;
        
        self.tradeVolume = [MApiHelper formatVolume:volume market:market subtype:subtype];
        
        NSString *dataColsString3;
        if ([dataCols[3] length] > 0) {
            dataColsString3 = [dataCols[3] convertToUTF8String];
            dataColsString3 = [dataColsString3 transform_decodeString];
        } else {
            [dataCols[3] convertToUTF8String];
        }
        NSString *price = dataColsString3;
        
        self.tradePrice = [MApiHelper formatPrice:[price doubleValue] market:market subtype:subtype];
        
        NSString *index = nil;
        if (dataCols.count > 5 && [dataCols[5] length] > 0) {
            index = [[dataCols[5] convertToUTF8String] transform_decodeString];
        }
        self.index = index;
    }
    return self;
}

@end

@implementation MTickItem (Convenience)

- (NSString *)time4 {
    if ([_datetime length] >= 4) {
        return [NSString stringWithFormat:@"%@:%@",
                [_datetime substringWithRange:NSMakeRange(0, 2)],
                [_datetime substringWithRange:NSMakeRange(2, 2)]];
    }
    return nil;
}

- (NSString *)time6 {
    if ([_datetime length] >= 6) {
        return [NSString stringWithFormat:@"%@:%@:%@",
                [_datetime substringWithRange:NSMakeRange(0, 2)],
                [_datetime substringWithRange:NSMakeRange(2, 2)],
                [_datetime substringWithRange:NSMakeRange(4, 2)]];
    }
    return nil;
}

- (NSString *)time8 {
    if ([_datetime length] >= 8) {
        return [NSString stringWithFormat:@"%@:%@:%@:%@",
                [_datetime substringWithRange:NSMakeRange(0, 2)],
                [_datetime substringWithRange:NSMakeRange(2, 2)],
                [_datetime substringWithRange:NSMakeRange(4, 2)],
                [_datetime substringWithRange:NSMakeRange(6, 2)]];
    }
    return nil;
}

@end
