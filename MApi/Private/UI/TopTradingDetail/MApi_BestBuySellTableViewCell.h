//
//  BestBuySellTableViewCell.h
//  TSApi
//
//  Created by Mitake on 2015/3/16.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MApi_BestBuySellTableViewCell : UITableViewCell
@property (nonatomic, retain) UILabel *buysellLabel;
@property (nonatomic, retain) UILabel *priceLabel;
@property (nonatomic, retain) UILabel *volumeLabel;
- (void)setTextFont:(UIFont *)textFont;
@end
