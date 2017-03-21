//
//  BestBuySellTableViewCell.m
//  TSApi
//
//  Created by Mitake on 2015/3/16.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApi_BestBuySellTableViewCell.h"

@implementation MApi_BestBuySellTableViewCell {
    NSArray *_horizontalConstaint;
    UIFont *_textFont;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _buysellLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _buysellLabel.backgroundColor = [UIColor clearColor];
        _buysellLabel.adjustsFontSizeToFitWidth = YES;
        _buysellLabel.minimumScaleFactor = 0.5;
        [self.contentView addSubview:_buysellLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.adjustsFontSizeToFitWidth = YES;
        _priceLabel.minimumScaleFactor = 0.5;
        [self.contentView addSubview:_priceLabel];
        
        _volumeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _volumeLabel.backgroundColor = [UIColor clearColor];
        _volumeLabel.textAlignment = NSTextAlignmentRight;
        _volumeLabel.adjustsFontSizeToFitWidth = YES;
        _volumeLabel.minimumScaleFactor = 0.5;
        [self.contentView addSubview:_volumeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = CGRectGetHeight(self.contentView.frame);
    _buysellLabel.frame = CGRectMake(0, 0, (20.0/12.0) * _textFont.pointSize, height);
    
    CGFloat buySellLabelSpace = CGRectGetMaxX(_buysellLabel.frame) + 5;
    CGFloat width = (CGRectGetWidth(self.contentView.frame) - buySellLabelSpace) / 2;
    _priceLabel.frame = CGRectMake(buySellLabelSpace, 0, width, height);
    _volumeLabel.frame = CGRectMake(CGRectGetMaxX(_priceLabel.frame), 0, width, height);
}

- (void)setTextFont:(UIFont *)textFont {
    if (_textFont != textFont) {
        _textFont = textFont;
        _buysellLabel.font = textFont;
        _priceLabel.font = textFont;
        _volumeLabel.font = textFont;
        [self setNeedsLayout];
    }
}

@end
