//
//  MChartView4Trend.m
//  MAPI
//
//  Created by FanChiangShihWei on 2016/12/23.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MChartView4Trend.h"
#import "_MChartView.h"
#import "_MPlot.h"
#import "_MAsyncLayer.h"
#import "Defines.h"

@implementation MChartView4Trend

- (void)dealloc {
    if (_gradientLocations) {
        free(_gradientLocations);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialized];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialized];
    }
    return self;
}
#pragma mark -- 初始化 --
- (void)initialized {
    [super initialized];
    
    _chartViewFlags.chartFrameChanged = true;
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleLongPressGestureRecognizer:)];
    _longPressGestureRecognizer.numberOfTouchesRequired = 1;
    _longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.longPressGestureRecognizer];
    
    //////// 查价线用，先不添加，等长按开始，才添加这个手势
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handleGestureRecognizerForEnquireWithGesture:)];
    _panGestureRecognizer.delegate = self;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handleGestureRecognizerForEnquireWithGesture:)];
    _tapGestureRecognizer.delegate = self;
    

}


#pragma mark public 

- (CGRect)drawingChartRect {
    CGRect rect = CGRectInset([self chartRect], self.borderWidth, self.borderWidth);
    return CGRectInset(rect, 1.0, 1.0);
}

- (CGRect)chartRect {
    if (_chartViewFlags.chartFrameChanged) {
        _chartViewFlags.chartFrameChanged = false;
        static NSString * const commonDateFormatString = @"0123456789:/-";
        CGSize size = [commonDateFormatString sizeWithFont:self.xAxisFont];
        CGFloat hPadding = 0;
        CGFloat x = 0;
        if (![self isYAxisLabelInside]) {
            x = self.yAxisLabelInsets.left;
            hPadding = self.yAxisLabelInsets.left + self.yAxisLabelInsets.right;
        }
        _chartRect = CGRectMake(x, 0, CGRectGetWidth(self.frame) - (hPadding), CGRectGetHeight(self.frame) - size.height);
    }
    return _chartRect;
}

- (BOOL)isYAxisLabelInside {
    return UIEdgeInsetsEqualToEdgeInsets(self.yAxisLabelInsets, UIEdgeInsetsZero);
}

- (void)contentNeedsUpdate {
    [self _contentNeedsUpdate];
    //    [[_MTransaction transactionWithTarget:self selector:@selector(_contentNeedsUpdate)] commit];
}

- (void)drawLinearGradient:(CGContextRef)context
                      path:(CGPathRef)path
                    colors:(NSArray *)colors
                 locations:(CGFloat *)locations
                      type:(NSInteger)type
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    if (type == 0) { // 涨
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    } else {
        CGContextDrawLinearGradient(context, gradient, endPoint, startPoint, 0);
    }
    
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawLinearGradient:(CGContextRef)context
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  midColor:(CGColorRef)midColor
                  endColor:(CGColorRef)endColor
                      type:(NSInteger)type
{
    CGFloat locations[] = { 0.0, 0.7, 1.0 };
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) midColor, (__bridge id) endColor];
    [self drawLinearGradient:context path:path colors:colors locations:locations type:type];
}

#pragma mark private

- (void)_contentNeedsUpdate {
    [self.layer setNeedsDisplay];
}

- (void)_endEnquireForDelayMode {
    if (!(self.enquiryLineMode & MChartEnquiryLineModeAppearImmediately)) {
        [self removeGestureRecognizer:self.tapGestureRecognizer];
    }
    
    [self override_endEnquire];
}

- (void)_endEnquireWithGesture:(UIGestureRecognizer *)gestureRecognizer {
    /// 延迟消失 是延时模式
    if (self.enquiryLineMode & MChartEnquiryLineModeDelayDisappear) {
        //开启延时关闭定时器
        self.delayCloseEnquiryLineTimer = [NSTimer timerWithTimeInterval:self.delayEndEnquireTimeInterval target:self selector:@selector(_endEnquireForDelayMode) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.delayCloseEnquiryLineTimer forMode:NSRunLoopCommonModes];
        return;
    }
    [self override_endEnquire];
}
#pragma mark -- 开始查价线 --
- (void)_startEnquireWithGesture:(UIGestureRecognizer *)gestureRecognizer {

    [self.delayCloseEnquiryLineTimer invalidate];
    
    if (gestureRecognizer != self.panGestureRecognizer) {
        [self addGestureRecognizer:self.panGestureRecognizer];
    }
    //查到MTrendChartView的这个方法，执行
    [self override_startEnquireWithGesture:gestureRecognizer];
}


#pragma mark override
//将系统layer转换成自定义layer
+ (Class)layerClass {
    return [_MAsyncLayer class];
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    if (!CGRectEqualToRect(oldFrame, self.frame)) {
        _chartViewFlags.chartFrameChanged = true;
    }
}

- (void)setBounds:(CGRect)bounds {
    CGRect oldBounds = self.bounds;
    [super setBounds:bounds];
    if (!CGRectEqualToRect(oldBounds, self.bounds)) {
        _chartViewFlags.chartFrameChanged = true;
    }
}

- (void)setGradientLocations:(CGFloat *)gradientLocations {
    if (_gradientLocations) {
        free(_gradientLocations);
    }
    _gradientLocations = malloc(sizeof(CGFloat) * 10);
    memcpy(_gradientLocations, gradientLocations, sizeof(CGFloat) * 10);
}

- (void)setEnquiryLineMode:(MChartEnquiryLineMode)enquiryLineMode {
    [super setEnquiryLineMode:enquiryLineMode];
    if (enquiryLineMode & MChartEnquiryLineModeAppearImmediately) {
        [self addGestureRecognizer:self.tapGestureRecognizer];
        [self removeGestureRecognizer:self.longPressGestureRecognizer];
    }
}

- (void)setEnquiryLineColor:(UIColor *)enquiryLineColor {
    self.enquiryView.lineColor = enquiryLineColor;
}

- (void)setEnquiryFrameColor:(UIColor *)enquiryFrameColor {
    self.enquiryView.labelBackgroundColor = enquiryFrameColor;
}

- (void)setEnquiryTextFont:(UIFont *)enquiryTextFont {
    self.enquiryView.labelTextFont = enquiryTextFont;
}

- (void)setEnquiryTextColor:(UIColor *)enquiryTextColor {
    self.enquiryView.labelTextColor = enquiryTextColor;
}


#pragma mark getter check

- (MStockItem *)stockItem {
    MAPI_ASSERT_MAIN_THREAD();
    return _stockItem;
}

- (double)minValue {
    MAPI_ASSERT_MAIN_THREAD();
    return _minValue;
}

- (double)maxValue {
    MAPI_ASSERT_MAIN_THREAD();
    return _maxValue;
}


#pragma mark prepare for override

- (void)override_endEnquire {
    NSAssert(false, @"MUST OVERRIDE override_endEnquire");
}

- (void)override_startEnquireWithGesture:(UIGestureRecognizer *)gestureRecognizer {
    NSAssert(false, @"MUST OVERRIDE override_startEnquireWithGesture:");
}

- (_MAsyncLayerDisplayTask *)override_newAsyncDisplayTask {
    NSAssert(false, @"MUST OVERRIDE override_newAsyncDisplayTask");
    return nil;
}

#pragma mark event

- (void)handleGestureRecognizerForEnquireWithGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        /// 查價線處理
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
            gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            //开始查价
            [self _startEnquireWithGesture:gestureRecognizer];
        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (self.enquiryLineMode & MChartEnquiryLineModeDelayDisappear) {
                [self _endEnquireWithGesture:gestureRecognizer];
            }
        }
        
    } else if (gestureRecognizer == self.tapGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            
            if ((_chartViewFlags.isEnquiring ||
                 self.enquiryLineMode & MChartEnquiryLineModeAppearImmediately) &&
                self.enquiryLineMode & MChartEnquiryLineModeDelayDisappear) {
                [self _startEnquireWithGesture:gestureRecognizer];
                [self _endEnquireWithGesture:gestureRecognizer]; /// 触发timer
            }
            else if (_chartViewFlags.isEnquiring &&
                     (!(self.enquiryLineMode & MChartEnquiryLineModeNotToDisappear) ||
                      (self.enquiryLineMode & MChartEnquiryLineModeAppearImmediately))) {
                         [self _endEnquireWithGesture:gestureRecognizer];
                     }
            else {
                [self _startEnquireWithGesture:gestureRecognizer];
            }
        }
    }
}
#pragma mark -- 长按手势 --
- (void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer {
    /// 查價線處理
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            _previousEnquireIndex = NSNotFound;
            _previousEnquireLocationX = 0;
            _previousEnquireLocationY = 0;
            //不立即消失类型，添加tap手势，让其消失
            if (self.enquiryLineMode & MChartEnquiryLineModeNotToDisappear) {
                //刚开始isEnquiring是空，再次执行的时候isEnquiring=1，就是结束的时候
                if (_chartViewFlags.isEnquiring) {
                    [self removeGestureRecognizer:self.tapGestureRecognizer];
                    [self override_endEnquire];
                    return;
                } else {
                    [self addGestureRecognizer:self.tapGestureRecognizer];
                }
            }
            //不立即消失类型，添加tap手势，延时几秒消失
            if (self.enquiryLineMode & MChartEnquiryLineModeDelayDisappear) {
                if (_chartViewFlags.isEnquiring) {
                    return;
                } else {
                    [self addGestureRecognizer:self.tapGestureRecognizer];
                }
            }
        }
        
        if (!(self.enquiryLineMode & MChartEnquiryLineModeAppearImmediately)) {
            [self _startEnquireWithGesture:gestureRecognizer];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
             gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
             gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        
        if (self.enquiryLineMode & MChartEnquiryLineModeNotToDisappear) {
            return;
        }
        
        [self _endEnquireWithGesture:gestureRecognizer];
    }
}


#pragma mark UIGestureRecognizerDelegate

- (_MAsyncLayerDisplayTask *)newAsyncDisplayTask {
    return [self override_newAsyncDisplayTask];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.view == self) {
        //// 避免截走其他view的手势
        if (gestureRecognizer == self.longPressGestureRecognizer ||
            gestureRecognizer == self.tapGestureRecognizer ||
            gestureRecognizer == self.panGestureRecognizer) {
            if (!self.enquiryEnabled) {
                return NO;
            }
            CGPoint location = [gestureRecognizer locationInView:self];
            return CGRectContainsPoint(CGRectInset([self chartRect], self.borderWidth, self.borderWidth), location);
        }
    }
    return YES;
}

@end





/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

@implementation MTrendChartEnquiryView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.lineColor = [UIColor whiteColor];
        self.labelTextFont = [UIFont systemFontOfSize:10.0];
        self.labelTextColor = [UIColor whiteColor];
        self.labelBackgroundColor = [UIColor grayColor];
        
        self.xAxisLabel = [self makeLabel];
        [self addSubview:self.xAxisLabel];
        self.yAxisLabel = [self makeLabel];
        [self addSubview:self.yAxisLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //???:這整塊暫時這樣寫
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, RETINA_LINE(1));
    if (self.lineColor) {
        [self.lineColor set];
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    // X axis
    if (CGRectContainsPoint(CGRectInset(self.priceChartRect, -1, 0), self.touchLocation)) {
        CGPathMoveToPoint(path, nil, CGRectGetMinX(self.priceChartRect), self.touchLocation.y);
        CGPathAddLineToPoint(path, nil, CGRectGetMaxX(self.priceChartRect), self.touchLocation.y);
    } else if (CGRectContainsPoint(CGRectInset(self.volumeChartRect, -1, 0), self.touchLocation)) {
        CGPathMoveToPoint(path, nil, CGRectGetMinX(self.volumeChartRect), self.touchLocation.y);
        CGPathAddLineToPoint(path, nil, CGRectGetMaxX(self.volumeChartRect), self.touchLocation.y);
    }
    // Y axis
    CGFloat xLocation = self.touchLocation.x;
    xLocation = MIN(CGRectGetMaxX(self.priceChartRect), xLocation);
    xLocation = MAX(CGRectGetMinX(self.priceChartRect), xLocation);
    
    CGPathMoveToPoint(path, nil, xLocation, CGRectGetMinY(self.priceChartRect));
    CGPathAddLineToPoint(path, nil, xLocation, CGRectGetMaxY(self.priceChartRect));
    CGPathMoveToPoint(path, nil, xLocation, CGRectGetMinY(self.volumeChartRect));
    CGPathAddLineToPoint(path, nil, xLocation, CGRectGetMaxY(self.volumeChartRect));
    
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
    CGContextRestoreGState(context);
}


#pragma mark factor
+ (instancetype)bindView:(UIView *)view {
    MTrendChartEnquiryView *enquiryView = [[[self class] alloc] initWithFrame:view.bounds];
    [view addSubview:enquiryView];
    return enquiryView;
}

- (UILabel *)makeLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = self.labelBackgroundColor;
    label.textColor = self.labelTextColor;
    label.font = self.labelTextFont;
    label.adjustsFontSizeToFitWidth = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
    label.minimumScaleFactor = 0.5;
    label.textAlignment = NSTextAlignmentCenter;
#else
    label.minimumFontSize = 6.0;
    label.textAlignment = UITextAlignmentCenter;
#endif
    return label;
}

#pragma mark setter
- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

- (void)setLabelTextFont:(UIFont *)labelTextFont {
    _labelTextFont = self.xAxisLabel.font = self.yAxisLabel.font = labelTextFont;
}

- (void)setLabelBackgroundColor:(UIColor *)labelBackgroundColor {
    _labelBackgroundColor = self.xAxisLabel.backgroundColor = self.yAxisLabel.backgroundColor = labelBackgroundColor;
}

- (void)setLabelTextColor:(UIColor *)labelTextColor {
    _labelTextColor = self.xAxisLabel.textColor = self.yAxisLabel.textColor = labelTextColor;
}

#pragma mark public
- (void)drawInRect:(CGRect)rect
    priceChartRect:(CGRect)priceChartRect
   volumeChartRect:(CGRect)volumeChartRect
       yAxisString:(NSString *)yAxisString
       xAxisString:(NSString *)xAxisString
     touchLocation:(CGPoint)touchLocation
       borderWidth:(CGFloat)borderWidth
  yAxisLabelInside:(BOOL)yAxisLabelInside {
    
    //}
    
    //- (void)drawInRect:(CGRect)rect fields:(NSDictionary *)fields touchLocation:(CGPoint)touchLocation yAxisLabelStringFormat:(NSString *)labelStringFormat borderWidth:(CGFloat)borderWidth {
    self.hidden = NO;
    //    [self.superview bringSubviewToFront:self];
    //    self.chartRect = rect;
    self.priceChartRect = priceChartRect;
    self.volumeChartRect = volumeChartRect;
    
    self.touchLocation = touchLocation;
    
    self.yAxisLabel.hidden = (yAxisString == nil);
    self.yAxisLabel.text = yAxisString;
    [self.yAxisLabel sizeToFit];
    CGRect frame = CGRectInset(self.yAxisLabel.frame, -2, -2);
    CGFloat y = self.touchLocation.y - CGRectGetHeight(frame)/2;
    
    CGRect limitRect = rect;
    if (CGRectContainsPoint(priceChartRect, CGPointMake(CGRectGetMidX(priceChartRect), self.touchLocation.y))) {
        limitRect = priceChartRect;
    } else if (CGRectContainsPoint(volumeChartRect, CGPointMake(CGRectGetMidX(volumeChartRect), self.touchLocation.y))) {
        limitRect = volumeChartRect;
    }
    y = MIN(y, (CGRectGetMaxY(limitRect) - CGRectGetHeight(frame)));
    y = MAX(y, CGRectGetMinY(limitRect));
    if (yAxisLabelInside) {
        if (touchLocation.x > CGRectGetMidX(rect)) {
            frame.origin = (CGPoint){CGRectGetMinX(rect), y};
        } else {
            frame.origin = (CGPoint){CGRectGetMaxX(rect) - frame.size.width, y};
        }
    } else {
        if (touchLocation.x > CGRectGetMidX(rect)) {
            frame.origin = (CGPoint){
                CGRectGetMinX(rect) - frame.size.width < 0 ? 0 : CGRectGetMinX(rect) - frame.size.width - 2,
                y};
        } else {
            frame.origin = (CGPoint){
                CGRectGetMaxX(rect) + frame.size.width > CGRectGetWidth(self.bounds)?
                CGRectGetWidth(self.bounds) - frame.size.width:CGRectGetMaxX(rect) + 2,
                y};
        }
    }
    
    if (MPlotRectIsValid(frame)) {
        self.yAxisLabel.frame = frame;
    }
    
    self.xAxisLabel.text = xAxisString;
    [self.xAxisLabel sizeToFit];
    CGFloat labelWidth = CGRectGetWidth(self.xAxisLabel.frame) + 5.0;
    CGFloat x = self.touchLocation.x - (CGRectGetWidth(self.xAxisLabel.frame) / 2);
    x = MIN(x, (CGRectGetMaxX(rect) - labelWidth));
    x = MAX(x, CGRectGetMinX(rect));
    self.xAxisLabel.frame = CGRectMake(x,
                                       CGRectGetMaxY(rect) + (borderWidth*2),
                                       labelWidth,
                                       CGRectGetHeight(self.xAxisLabel.frame));
    [self setNeedsDisplay];
}

- (void)clear {
    self.hidden = YES;
}

@end

