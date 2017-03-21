//
//  TickTableViewCell.m
//  TSApi
//
//  Created by Mitake on 2015/3/16.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MApi_TickTableViewCell.h"

@implementation MApi_TickTableViewCell {
    NSArray *_horizontalConstaint;
    UIFont *_textFont;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.adjustsFontSizeToFitWidth = YES;
        _timeLabel.minimumScaleFactor = 0.5;
        [self.contentView addSubview:_timeLabel];
        
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
    _timeLabel.frame = CGRectMake(0, 0, (32.0/12.0) * _textFont.pointSize, height);
    CGFloat timeLabelSpace = CGRectGetMaxX(_timeLabel.frame) + 5;
    CGFloat width = (CGRectGetWidth(self.contentView.frame) - timeLabelSpace) / 2;
    _priceLabel.frame = CGRectMake(timeLabelSpace, 0, width, height);
    _volumeLabel.frame = CGRectMake(CGRectGetMaxX(_priceLabel.frame), 0, width, height);
}

- (void)setTextFont:(UIFont *)textFont {
    if (_textFont != textFont) {
        _textFont = textFont;
        _timeLabel.font = textFont;
        _priceLabel.font = textFont;
        _volumeLabel.font = textFont;
        [self setNeedsLayout];
    }
}

@end
