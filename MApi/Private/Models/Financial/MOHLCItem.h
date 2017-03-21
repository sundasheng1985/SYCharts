//
//  MOHLCItem.h
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MBaseItem.h"

@interface MOHLCItem ()
@property (nonatomic, assign) BOOL xred;

/// MChartResponse called
- (instancetype)initWithChartData:(NSData *)data market:(NSString *)market subtype:(NSString *)subtype;
@end
