//
//  _MAsyncLayer.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/4/27.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "_MTransaction.h"

@class _MAsyncLayerDisplayTask;

@interface _MAsyncLayer : CALayer

@end

@protocol _MAsyncLayerDelegate <NSObject>
@required
- (_MAsyncLayerDisplayTask *)newAsyncDisplayTask;
@end

@interface _MAsyncLayerDisplayTask : NSObject
@property (nonatomic, copy) void (^willDisplay)(CALayer *layer); //将要显示
@property (nonatomic, copy) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)); //已经显示
@property (nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished); //结束显示
@end
