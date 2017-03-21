//
//  MCheckVersionResponse.m
//  Pods
//
//  Created by 金融研發一部-蕭裕翰 on 7/22/15.
//
//

#import "MCheckVersionResponse.h"

@implementation MCheckVersionResponse

- (id)initWithData:(NSData *)data request:(MRequest *)request timestamp:(NSString *)timestamp headers:(NSDictionary *)headers {
    self = [super initWithData:data request:request timestamp:timestamp headers:headers];
    if (self) {
        NSDictionary *JSONDictionary = nil;
        if ([self getJSONObject:&JSONDictionary withData:data parseClass:NSDictionary.class]) {
            self.versionInfo = JSONDictionary[@"versioninfo"];
            self.versionStatus = self.versionInfo[@"status"];
            self.downloadURLString = self.versionInfo[@"download"];
            self.checkVersionDescription = self.versionInfo[@"desc"];
            self.version = self.versionInfo[@"ver"];
        }
    }
    return self;
}

@end
