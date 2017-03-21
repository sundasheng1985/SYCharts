//
//  MXListCell.h
//  NewStock
//
//  Created by IOS_HMX on 16/7/1.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MXListCell : UITableViewCell
@property (nonatomic , strong) NSArray *values;

@property (nonatomic , strong) UIColor *cellTextColor;
@property (nonatomic , assign) CGFloat cellFontSize;
@property (nonatomic , strong) UIColor *codeIdColor;
@property (nonatomic , assign) CGFloat codeIdFontSize;

@end
