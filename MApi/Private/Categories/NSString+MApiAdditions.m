//
//  NSString+MApiAdditions.m
//  TSApi
//
//  Created by Mitake on 2015/4/9.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "NSString+MApiAdditions.h"

@implementation NSString (MApiAdditions)

+ (NSString *)mapi_stringWithValue:(double)value decimal:(NSInteger)decimal {
    NSString *format = [NSString stringWithFormat:@"%%.%zdf", decimal];
    return [NSString stringWithFormat:format, value + 0.00000001];
}

- (NSString *)datetimeStringWithoutSecond {
//    NSString *datetime = self;
//    NSRange r = [self rangeOfString:@":" options:NSBackwardsSearch];
//    if (r.location != NSNotFound) {
//        datetime = [self substringToIndex:r.location];
//    }
    return self;
}

- (NSString *)date8 {
    if (self.length >= 8) {
        return [self substringToIndex:8];
    }
    return nil;
}

@end


@implementation NSString (MRequestValidation)

- (BOOL)validateCode {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\w+\\.\\w+$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];

    NSUInteger matches = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)];
    return (matches == 1);
}

@end