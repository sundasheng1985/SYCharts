//
//  MChartView.m
//  Pods
//
//  Created by FanChiangShihWei on 2016/3/27.
//
//

#import "MChartView.h"

NSString * const MChartDidStartEnquiryNotification = @"MApi-MChartDidStartEnquiryNotification";
NSString * const MChartDidEndEnquiryNotification = @"MApi-MChartDidEndEnquiryNotification";

NSString * const MFundValueDidStartEnquiryNotification= @"MApi-MFundValueDidStartEnquiryNotification";
NSString * const MFundValueDidEndEnquiryNotification = @"MApi-MFundValueDidEndEnquiryNotification";

@interface MChartDotView ()
@property (nonatomic, strong) CAShapeLayer *dot;
@property (nonatomic, strong) CAShapeLayer *dotAnimator;
@end

@implementation MChartDotView

+ (MChartDotView *)blinkDot {
    return [[MChartDotView alloc] initWithFrame:CGRectMake(0, 0, 4.0, 4.0)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.dot = [CAShapeLayer layer];
        self.dot.fillColor = [UIColor whiteColor].CGColor;
        self.dot.path = CGPathCreateWithEllipseInRect(self.bounds, NULL);
        self.dot.frame = self.bounds;
        [self.layer addSublayer:self.dot];
        
        self.dotAnimator = [CAShapeLayer layer];
        self.dotAnimator.fillColor = [UIColor whiteColor].CGColor;
        self.dotAnimator.path = CGPathCreateWithEllipseInRect(self.bounds, NULL);
        self.dotAnimator.frame = self.bounds;
        [self.layer addSublayer:self.dotAnimator];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self makeAnimation];
    }
}

- (void)makeAnimation {
    [self.dotAnimator removeAnimationForKey:@"flashAnimation"];
    CAAnimationGroup *group = [CAAnimationGroup animation];
    
    group.delegate = self;
    group.duration = 1.0;
    group.repeatCount = DBL_MAX;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.byValue = @(2.0);
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = @(1.0);
    fadeAnimation.toValue = @(0);
    
    group.animations = @[scaleAnimation, fadeAnimation];
    [self.dotAnimator addAnimation:group forKey:@"flashAnimation"];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.dot.fillColor = color.CGColor;
    self.dotAnimator.fillColor = color.CGColor;
}

@end


@implementation MChartView

- (void)initialized {
    
    self.backgroundColor = [UIColor blackColor];
    
    _yAxisFont = [UIFont systemFontOfSize:10.0];
    _xAxisFont = [UIFont systemFontOfSize:10.0];
    _xAxisTextColor = [UIColor whiteColor];
    _borderWidth = 1;
    _borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    _insideLineWidth = 1;
    _insideLineColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    _enquiryEnabled = YES;
    _enquiryLineMode = MChartEnquiryLineModeSticky;
    _yAxisLabelInsets = UIEdgeInsetsZero;
    _delayEndEnquireTimeInterval = 1.0;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        [self initialized];
    }
    return self;
}

- (void)awakeFromNib {
//    [self initialized];
}

- (void)reloadData {
    
}

- (void)reloadDataWithStockItem:(MStockItem *)stockItem {
    
}

@end
