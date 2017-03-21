//
//  _MTransaction.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/4/27.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _MTransaction : NSObject
+ (_MTransaction *)transactionWithTarget:(id)target selector:(SEL)selector;
+ (_MTransaction *)transactionWithTarget:(id)target selector:(SEL)selector userInfo:(NSDictionary *)userInfo;
- (void)commit;
@end
