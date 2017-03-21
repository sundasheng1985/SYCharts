//
//  _MTransaction.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/4/27.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "_MTransaction.h"

@interface _MTransaction ()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) NSDictionary *userInfo;
@end

static NSHashTable *transactions = nil;

static void _MRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if (transactions.count) {
        NSHashTable *transactionsToCommit = transactions;
        transactions = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPersonality];
        for (_MTransaction *t in transactionsToCommit) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [t.target performSelector:t.selector withObject:t.userInfo];
#pragma clang diagnostic pop
        }
    }
}

static void _MTransactionSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactions = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPersonality];
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,      // repeat
                                           INT_MAX,   // 优先权在 CATransaction(2000000) 之后
                                           _MRunLoopObserverCallBack, NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}


@implementation _MTransaction

+ (_MTransaction *)transactionWithTarget:(id)target selector:(SEL)selector userInfo:(NSDictionary *)userInfo {
    if (!target || !selector) return nil;
    _MTransaction *t = [_MTransaction new];
    t.target = target;
    t.selector = selector;
    t.userInfo = userInfo;
    return t;
}

+ (_MTransaction *)transactionWithTarget:(id)target selector:(SEL)selector {
    return [self transactionWithTarget:target selector:selector userInfo:nil];
}

- (void)commit {
    if (!_target || !_selector) return;
    _MTransactionSetup();
    if (![transactions containsObject:self]) {
        [transactions addObject:self];
    }
}

- (NSUInteger)hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    return v1 ^ v2;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isMemberOfClass:self.class]) return NO;
    _MTransaction *other = object;
    return other.selector == _selector && other.target == _target;
}

@end
