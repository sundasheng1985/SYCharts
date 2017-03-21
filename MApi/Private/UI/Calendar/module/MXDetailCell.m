//
//  MXDetailCell.m
//  NewStock
//
//  Created by IOS_HMX on 16/7/4.
//  Copyright © 2016年 humingxing. All rights reserved.
//

#import "MXDetailCell.h"
#import "MXDefine.h"

static const CGFloat kNameLabelWidth = 110.;

@interface MXDetailCell()
{
    @package
    UILabel *_nameLabel;
    UILabel *_valueLabel;
    UITapGestureRecognizer *_tap;
}
@end
@implementation MXDetailCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        self.backgroundColor =
        self.contentView.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:20.0/255.0 blue:25.0/255.0 alpha:1];
        
        
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture)];

        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_nameLabel];
        
        _valueLabel = [[UILabel alloc]init];
        _valueLabel.textAlignment = NSTextAlignmentLeft;
        _valueLabel.numberOfLines = 0;
        [self.contentView addSubview:_valueLabel];
    }
    return self;
}
-(void)tapGesture
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedCell:)]) {
        [self.delegate didClickedCell:self];
    }
}
-(void)setClickEnable:(BOOL)clickEnable
{
    _clickEnable = clickEnable;
    if (_clickEnable) {
        _valueLabel.userInteractionEnabled = YES;
        [_valueLabel addGestureRecognizer:_tap];
    }else
    {
        [_valueLabel removeGestureRecognizer:_tap];
    }
}
-(void)setName:(NSString *)name andValue:(NSString *)value
{
    _nameLabel.textColor = _nameTextColor;
    _nameLabel.font = [UIFont systemFontOfSize:_nameTextFontSize];
    if (self.clickEnable) {
        _valueLabel.textColor = _clickedTextColor;
    }else
    {
        _valueLabel.textColor = _valueTextColor;
    }
    _valueLabel.font = [UIFont systemFontOfSize:_valueTextFontSize];
    _nameLabel.text = name;
    _valueLabel.text = value;

    CGFloat nameHeight = [name boundingRectWithSize:CGSizeMake(kNameLabelWidth, 1000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _nameLabel.font} context:nil].size.height;
    CGFloat valueHeight = [value boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame)-2*LEFT_PADDING-kNameLabelWidth, 1000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _valueLabel.font} context:nil].size.height;
    _nameLabel.frame = CGRectMake(LEFT_PADDING, TOP_PADDING, kNameLabelWidth, nameHeight);
    _valueLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame), TOP_PADDING, CGRectGetWidth(self.frame)-kNameLabelWidth-2*LEFT_PADDING, valueHeight);
}
+(CGFloat)heightWithValueString:(NSString *)value withFont:(UIFont *)font inWidth:(CGFloat)width
{
    NSDictionary *dict = @{NSFontAttributeName: font};
    CGSize textSize = [value boundingRectWithSize:CGSizeMake(width-2*LEFT_PADDING-kNameLabelWidth, 1000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    CGFloat height = MAX(textSize.height, font.pointSize);
    return 2*TOP_PADDING + height;
}
@end
