//
//  MXHeaderCell.h
//  NewStock
//
//  Created by IOS_HMX on 16/7/1.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MXHeaderCell : UITableViewCell
@property (nonatomic , strong) NSArray *titles;

@property (nonatomic , strong) UIColor *headerPromptColor;
@property (nonatomic , assign) CGFloat headerPromptFontSize;
@property (nonatomic , strong) UIColor *promptBackColor;
@property (nonatomic , strong) UIColor *separatorClolor;

@end
