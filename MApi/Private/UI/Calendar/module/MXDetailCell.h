//
//  MXDetailCell.h
//  NewStock
//
//  Created by IOS_HMX on 16/7/4.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MXDetailCell;
@protocol MXDetailCellDelegate <NSObject>

@optional
-(void)didClickedCell:(MXDetailCell *)cell;
@end
@interface MXDetailCell : UITableViewCell

@property (nonatomic , strong) UIColor *nameTextColor;
@property (nonatomic , assign) NSInteger nameTextFontSize;
@property (nonatomic , strong) UIColor *valueTextColor;
@property (nonatomic , assign) NSInteger valueTextFontSize;
@property (nonatomic , strong) UIColor  *clickedTextColor;
@property (nonatomic , assign) BOOL clickEnable;
@property (nonatomic , weak) id<MXDetailCellDelegate> delegate;
-(void)setName:(NSString *)name andValue:(NSString *)value;
+(CGFloat)heightWithValueString:(NSString *)value withFont:(UIFont *)font inWidth:(CGFloat)cellWidth;
@end
