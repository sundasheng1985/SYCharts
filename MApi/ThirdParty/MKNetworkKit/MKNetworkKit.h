//
//  MKNetworkKit.h
//  Tokyo
//
//  Created by Mugunth on 26/6/14.
//  Copyright (c) 2014 LifeOpp Pte Ltd. All rights reserved.
//

#ifndef MApi_MKNetworkKit_h
#define MApi_MKNetworkKit_h
///////////////////////////////////////////////////////////
// general
#if 0
#define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#define ALog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#else
#define DLog(...)
#define ALog(...)
#endif

#import "NSDate+RFC1123.h"
#import "NSDictionary+MKNKAdditions.h"
#import "NSHTTPURLResponse+MKNKAdditions.h"
#import "NSMutableDictionary+MKNKAdditions.h"
#import "NSString+MKNKAdditions.h"
#import "NSData+MKBase64.h"

///////////////////////////////////////////////////////////
// v2
#import "MApi_MKNetworkHost.h"
#import "MApi_MKNetworkRequest.h"
#import "MApi_MKObject.h"

///////////////////////////////////////////////////////////
// v1
#import "MApi_Reachability.h"
#import "MApi_MKNetworkOperation.h"
#import "MApi_MKNetworkEngine.h"

#define kMApi_MKNetworkEngineOperationCountChanged @"kMApiNetworkEngineOperationCountChanged"
#define MApi_MKNETWORKCACHE_DEFAULT_COST 10
#define MApi_MKNETWORKCACHE_DEFAULT_DIRECTORY @"MApiNetworkCache"
#define kMApi_MKNetworkKitDefaultCacheDuration 60 // 1 minute
#define kMApi_MKNetworkKitDefaultImageHeadRequestDuration 3600*24*1 // 1 day (HEAD requests with eTag are sent only after expiry of this. Not that these are not RFC compliant, but needed for performance tuning)
#define kMApi_MKNetworkKitDefaultImageCacheDuration 3600*24*7 // 1 day
// if your server takes longer than 30 seconds to provide real data,
// you should hire a better server developer.
// on iOS (or any mobile device), 30 seconds is already considered high.
#define kMApi_MKNetworkKitRequestTimeOutInSeconds 30
///////////////////////////////////////////////////////////

#endif
