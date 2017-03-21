//
//  MSearchResultItem.m
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MSearchResultItem.h"

#pragma mark MSearchResultItem

@implementation MSearchResultItem
@dynamic stockID;
@dynamic market;
@dynamic name;
@dynamic pinyin;
@dynamic subtype;
@dynamic code;
@dynamic sort;
@dynamic sort1;
@dynamic sort2;

- (instancetype)initWithData:(NSData *)data {
    if (self = [super initWithData:data]) {
        NSArray *dataCols = [data componentsSeparatedByByte:0x02];
        if (dataCols.count < 4) {
            return nil;
        }
        NSString *code = [dataCols[0] convertToUTF8String];
        self.stockID = code;
        self.market = [code pathExtension];
        self.name = [dataCols[1] convertToUTF8String];
        self.pinyin = [dataCols[2] convertToUTF8String];
        self.subtype = [dataCols[3] convertToUTF8String];
        self.code = [code stringByDeletingPathExtension];
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    [description appendFormat:@"MSearchResultItem.stockID: %@\n", self.stockID];
    [description appendFormat:@"MSearchResultItem.market: %@\n", self.market];
    [description appendFormat:@"MSearchResultItem.name: %@\n", self.name];
    [description appendFormat:@"MSearchResultItem.pinyin: %@\n", self.pinyin];
    [description appendFormat:@"MSearchResultItem.subtype: %@\n", self.subtype];
    [description appendFormat:@"MSearchResultItem.code: %@\n", self.code];
    return description;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.stockID forKey:@"MSearchResultItem.stockID"];
    [coder encodeObject:self.market forKey:@"MSearchResultItem.market"];
    [coder encodeObject:self.name forKey:@"MSearchResultItem.name"];
    [coder encodeObject:self.pinyin forKey:@"MSearchResultItem.pinyin"];
    [coder encodeObject:self.subtype forKey:@"MSearchResultItem.subtype"];
    [coder encodeObject:self.code forKey:@"MSearchResultItem.code"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.stockID = [coder decodeObjectForKey:@"MSearchResultItem.stockID"];
        self.market = [coder decodeObjectForKey:@"MSearchResultItem.market"];
        self.name = [coder decodeObjectForKey:@"MSearchResultItem.name"];
        self.pinyin = [coder decodeObjectForKey:@"MSearchResultItem.pinyin"];
        self.subtype = [coder decodeObjectForKey:@"MSearchResultItem.subtype"];
        self.code = [coder decodeObjectForKey:@"MSearchResultItem.code"];
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    MSearchResultItem *copy = [super copyWithZone:zone];
    copy.stockID = self.stockID;
    copy.market = self.market;
    copy.name = self.name;
    copy.pinyin = self.pinyin;
    copy.subtype = self.subtype;
    copy.code = self.code;
    return copy;
}

@end
