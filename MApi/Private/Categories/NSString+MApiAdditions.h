//
//  NSString+MApiAdditions.h
//  TSApi
//
//  Created by Mitake on 2015/4/9.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MApiAdditions)
+ (NSString *)mapi_stringWithValue:(double)value decimal:(NSInteger)decimal;
- (NSString *)datetimeStringWithoutSecond;
- (NSString *)date8;
@end


@interface NSString (MRequestValidation)
- (BOOL)validateCode;
@end