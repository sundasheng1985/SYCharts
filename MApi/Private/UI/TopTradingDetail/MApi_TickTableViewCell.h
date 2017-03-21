//
//  TickTableViewCell.h
//  TSApi
//
//  Created by Mitake on 2015/3/16.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MApi_TickTableViewCell : UITableViewCell
@property (nonatomic, readonly) UILabel *timeLabel;
@property (nonatomic, readonly) UILabel *priceLabel;
@property (nonatomic, readonly) UILabel *volumeLabel;
- (void)setTextFont:(UIFont *)textFont;
@end
