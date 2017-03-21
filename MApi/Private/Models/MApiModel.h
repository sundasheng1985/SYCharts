//
//  MApiModel.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/5/27.
//  Copyright © 2016年 Mitake. All rights reserved.
//


#import "MApiObject.h"

@interface MApiModel ()
+ (instancetype)objectWithContentsOfFile:(NSString *)filePath;
- (BOOL)writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile;
- (NSDictionary *)dictionaryRepresentation:(BOOL)forDesciption;
@end
