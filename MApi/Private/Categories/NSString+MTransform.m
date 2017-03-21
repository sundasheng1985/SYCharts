//
//  NSString+MTransform.m
//  MApiTransform
//
//  Created by 金融研發一部-蕭裕翰 on 7/28/15.
//  Copyright (c) 2015 Mitake. All rights reserved.
//

#import "NSString+MTransform.h"
#import "MTransform.h"

@implementation NSString (MTransform)

- (NSString *)transform_encodeString {
    if (self && self.length) {
        return [MTransform transformBaseEncodeStringByCacheString:self];
    }
    return self;
}

- (NSString *)transform_decodeString {
    if (self && self.length) {
        NSString *string = [MTransform transformBaseDecodeStringByCacheString:self];
        return string;
    }
    return self;
//    return [self isEqualToString:@""] ? @"" : ;
}

@end
