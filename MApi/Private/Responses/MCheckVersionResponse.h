//
//  MCheckVersionResponse.h
//  Pods
//
//  Created by 金融研發一部-蕭裕翰 on 7/22/15.
//
//

#import "MResponse.h"

@interface MCheckVersionResponse ()
@property (nonatomic, readwrite, copy) NSString *versionStatus;
@property (nonatomic, readwrite, copy) NSString *downloadURLString;
@property (nonatomic, readwrite, copy) NSString *checkVersionDescription;
@property (nonatomic, readwrite, copy) NSString *version;

@end
