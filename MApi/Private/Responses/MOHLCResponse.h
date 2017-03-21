//
//  MOHLCResponse.h
//  TSApi
//
//  Created by Mitake on 2015/3/18.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MResponse.h"
#import "MStockXRResponse.h"

@interface MOHLCResponse ()
@property (nonatomic, strong) NSArray *fq;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *subtype;
@property (nonatomic, assign) MOHLCPriceAdjustedMode priceAdjustedMode;
- (void)_XR_calculate;
@end
