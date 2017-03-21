//
//  MGetSourceResponse.m
//  Pods
//
//  Created by 金融研發一部-蕭裕翰 on 7/27/15.
//
//

#import "MGetSourceResponse.h"

@implementation MGetSourceResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONDictionary = nil;
        if ([self getJSONObject:&JSONDictionary withData:data parseClass:NSDictionary.class]) {
            self.sourceInfos = JSONDictionary;
        }
    }
    return self;
}

@end
