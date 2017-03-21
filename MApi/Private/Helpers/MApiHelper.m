//
//  MApiHelper.m
//  MobileSDK
//
//  Created by 李政修 on 2015/1/20.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApiHelper.h"
#import "MMarketInfo.h"
#import "MBase64.h"
#import "NSString+MApiAdditions.h"

#define MAPI_DES_AUTH_IP_ENCRYPT_KEY @"b6838aa6609d849s10f72d0e"  //auth ip 加密key

#ifndef MAPI_AUTH_IP_TYPE_PRODUCTION
#define MAPI_AUTH_IP_TYPE_PRODUCTION 0
#endif

//服务器数据
#if MAPI_AUTH_IP_TYPE_PRODUCTION

#define MAPI_AUTH_IP_ADDRESS_DEFAULT \
@[@"http://180.163.112.216:22016", @"http://58.63.252.23:22016", @"http://140.207.241.151:22016"]

NSString * const kAuthIPsStorageKey = @"MAPI_AUTH_IP_STORAGE_PRODUCTION";
NSString * const kQuoteIPsStorageKey = @"MAPI_QUOTE_IP_STORAGE_PRODUCTION";
NSString * const kTokenStorageKey = @"MAPI_TOKEN_STORAGE_PRODUCTION";
NSString * const kMarketInfoStorageKey = @"MAPI_MARKET_INFO_STORAGE_PRODUCTION";

NSString * const kTokenExpireDateStorageKey = @"MAPI_TOKEN_EXPIREDATE_STORAGE_PRODUCTION";
NSString * const kMarketInfoExpireDateStorageKey = @"MAPI_MARKET_INFOS_EXPIREDATE_STORAGE_PRODUCTION";
#else
#define MAPI_AUTH_IP_ADDRESS_DEFAULT @[@"http://114.80.155.134:22016"] //全真环境IP

NSString * const kAuthIPsStorageKey = @"MAPI_AUTH_IP_STORAGE_DEVELOPE";
NSString * const kQuoteIPsStorageKey = @"MAPI_QUOTE_IP_STORAGE_DEVELOPE";
NSString * const kTokenStorageKey = @"MAPI_TOKEN_STORAGE_DEVELOPE";
NSString * const kMarketInfoStorageKey = @"MAPI_MARKET_INFO_STORAGE_DEVELOPE";

NSString * const kTokenExpireDateStorageKey = @"MAPI_TOKEN_EXPIREDATE_STORAGE_DEVELOPE";
NSString * const kMarketInfoExpireDateStorageKey = @"MAPI_MARKET_INFOS_EXPIREDATE_STORAGE_DEVELOPE";
#endif


NSString * const MApiQuoteServerAddressCrystal = @"sseap.mitake.com.cn"; //api服务器IP
NSString * const MApiQuoteServerAddressMitake = @"203.66.57.126"; //api服务器IP
//NSString * const MApiInfoIPForDevelopment = @"59.120.170.7:19888";//info api服务器IP
NSString * const MApiInfoIPForDevelopment = @"f10.mitake.com.cn";//info api服务器IP
//59.120.170.7
//60.251.113.175
NSString * const MApiHttpMethodGET = @"GET"; //http方法
NSString * const MApiHttpMethodPOST = @"POST"; //http方法


@interface MApiHelper() {
    NSArray *_authServers;
    NSDictionary *_quoteServers;
    NSString *_token;
    NSDictionary *_marketInfos;
}

@end

@implementation MApiHelper

+ (instancetype)sharedHelper {
    static MApiHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MApiHelper alloc] initSingleton];
    });
    return instance;
}

- (id)init {
    NSAssert(NO, @"本类只支持单一模式，请改用[TSApiHelper sharedHelper]");
    return nil;
}

- (id)initSingleton {
    if(self = [super init]) {
    }
    return self;
}

- (BOOL)isTokenEmpty {
    return [self.token length] == 0;
}

+ (NSString *)archiveType {
#if MAPI_AUTH_IP_TYPE_PRODUCTION
    return @"RELEASE";
#else
    return @"DEVELOP";
#endif
}

+ (NSString *)formatPrice:(double)price market:(NSString *)market subtype:(NSString *)subtype {
    if (price !=  0) {
        MMarketInfo *marketInfo = [self marketInfoWithMarket:market subtype:subtype];
        price /= pow(10, marketInfo.power);
        return [NSString mapi_stringWithValue:price decimal:marketInfo.decimal];
    }
    return nil;
}

+ (NSString *)formatAveragePrice:(double)price market:(NSString *)market subtype:(NSString *)subtype {
    if (price != 0) {
        MMarketInfo *marketInfo = [self marketInfoWithMarket:market subtype:subtype];
        price /= pow(10, marketInfo.power);
        return [NSString mapi_stringWithValue:price decimal:marketInfo.power];
    }
    return nil;
}


+ (NSString *)formatVolume:(NSString *)volume market:(NSString *)market subtype:(NSString *)subtype {
    if (volume.length > 0) {
        MMarketInfo *marketInfo = [self marketInfoWithMarket:market subtype:subtype];
        if (marketInfo.tradeUnit <= 1) {
            return volume;
        }
        double vol = [volume doubleValue] / marketInfo.tradeUnit;
        return [NSString mapi_stringWithValue:vol decimal:2];
    }
    return nil;
}

+ (NSDictionary *)tradingInfomationWithMarket:(NSString *)market subtype:(NSString *)subtype {
    static NSDictionary *tradingInfomations = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"market" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        tradingInfomations = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    });
    
    NSDictionary *marketInfomation = tradingInfomations[market];
    if (market) {
        NSMutableDictionary *tradingInfomation = [marketInfomation mutableCopy];
        NSDictionary *subtypeInfomation = tradingInfomations[[market stringByAppendingString:subtype ?: @""]];
        [subtypeInfomation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            tradingInfomation[key] = obj;
        }];
        return tradingInfomation;
    }
    return nil;
}

+ (MMarketInfo *)marketInfoWithMarket:(NSString *)market subtype:(NSString *)subtype {
    NSDictionary *tradingInfomations = [MApiHelper sharedHelper].marketInfos;
    if (market) {
        
        /// Level2市场别处理
        NSUInteger level2_literalLocation = NSNotFound;
        if ((level2_literalLocation = [market rangeOfString:@"l2"].location) != NSNotFound) {
            market = [market substringToIndex:level2_literalLocation];
        } /// end Level2市场别处理
        
        NSMutableDictionary *tradingInfomation = [tradingInfomations[market] mutableCopy];
        NSDictionary *subtypeInfomation = tradingInfomations[[market stringByAppendingString:subtype ?: @""]];
        [subtypeInfomation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            tradingInfomation[key] = obj;
        }];
        MMarketInfo *marketInfo = [[MMarketInfo alloc] initWithJSONObject:tradingInfomation];
        return marketInfo;
    }
    return nil;
}

- (void)archiveQuoteServers:(NSDictionary *)quoteServers {
    if (quoteServers) {
        NSData *encryptData = [[NSKeyedArchiver archivedDataWithRootObject:quoteServers] tripleDESEncryptWithKey:MAPI_DES_AUTH_IP_ENCRYPT_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:encryptData forKey:kQuoteIPsStorageKey];
        
        /// 认证ip的处理, 用auth回来的auth server list 取代原本的
        /// 下次进入app时使用
        NSArray *authServers = quoteServers[@"auth"];
        if (authServers) {
            NSMutableArray *authIPs = [@[] mutableCopy];
            __block NSString *authIP = nil;
            [authServers enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
                if ((authIP = dict[@"ip"])) {
                    [authIPs addObject:authIP];
                }
            }];
            if (authIPs) {
                [MApiHelper saveAuthIPs:authIPs];
            }
        }
        
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)archiveToken:(NSString *)token {
    if (token) {
        NSData *encryptData = [[NSKeyedArchiver archivedDataWithRootObject:token] tripleDESEncryptWithKey:MAPI_DES_AUTH_IP_ENCRYPT_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:encryptData forKey:kTokenStorageKey];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kTokenExpireDateStorageKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)archiveMarketInfos:(NSDictionary *)marketInfos {
    if (marketInfos) {
        [[NSUserDefaults standardUserDefaults] setObject:marketInfos forKey:kMarketInfoStorageKey];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kMarketInfoExpireDateStorageKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark auth info storage

+ (void)saveAuthIPs:(NSArray *)IPs {
    NSData *encryptData = [[NSKeyedArchiver archivedDataWithRootObject:IPs] tripleDESEncryptWithKey:MAPI_DES_AUTH_IP_ENCRYPT_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:encryptData forKey:kAuthIPsStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreAuthInfo {
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenExpireDateStorageKey];
    NSTimeInterval hour = 999999;
    if (date) {
        hour = [[NSDate date] timeIntervalSinceDate:date] / 60 / 60;
    }
    
    if (hour < 16) {
        /// Quote ips restore
        {
            NSData *encryptData = [[NSUserDefaults standardUserDefaults] objectForKey:kQuoteIPsStorageKey];
            if (encryptData) {
                NSData *decryptData = [encryptData dataUsingTripleDESDecryptWithKey:MAPI_DES_AUTH_IP_ENCRYPT_KEY];
                _quoteServers = [NSKeyedUnarchiver unarchiveObjectWithData:decryptData];
            }
        }
        {
            NSData *encryptData = [[NSUserDefaults standardUserDefaults] objectForKey:kTokenStorageKey];
            if (encryptData) {
                NSData *decryptData = [encryptData dataUsingTripleDESDecryptWithKey:MAPI_DES_AUTH_IP_ENCRYPT_KEY];
                _token = [[NSKeyedUnarchiver unarchiveObjectWithData:decryptData] copy];
            }
        }
    }
    
    /////////////////////
    /// Market Info Restore
    date = [[NSUserDefaults standardUserDefaults] objectForKey:kMarketInfoExpireDateStorageKey];
    hour = 999999;
    if (date) {
        hour = [[NSDate date] timeIntervalSinceDate:date] / 60 / 60;
    }
    if (hour < 16) {
        self.marketInfos = [[NSUserDefaults standardUserDefaults] objectForKey:kMarketInfoStorageKey];
    }
    
    NSMutableSet *authIps = [NSMutableSet set];
    /// authServers Info Restore
    NSData *encryptData = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthIPsStorageKey];
    if (encryptData) {
        NSData *decryptData = [encryptData dataUsingTripleDESDecryptWithKey:MAPI_DES_AUTH_IP_ENCRYPT_KEY];
        NSArray *storageIPs = [NSKeyedUnarchiver unarchiveObjectWithData:decryptData];
        if ([storageIPs isKindOfClass:[NSArray class]]) {
            [authIps addObjectsFromArray:storageIPs];
        }
    }
    [authIps addObjectsFromArray:MAPI_AUTH_IP_ADDRESS_DEFAULT];
    
    /// 虽说已经是UnorderedSet, 但还是做一次打乱处理
    NSMutableArray *randomAuthDefaultIps = [NSMutableArray arrayWithArray:[authIps allObjects]];
    NSInteger count = [randomAuthDefaultIps count];
    for (NSInteger i = 0; i < count - 1; i++) {
        NSInteger swap = arc4random() % (count - i) + i;
        [randomAuthDefaultIps exchangeObjectAtIndex:swap withObjectAtIndex:i];
    }
    _authServers = [randomAuthDefaultIps copy];
}

- (void)clearAuthInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTokenStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _token = nil;
}


@end
