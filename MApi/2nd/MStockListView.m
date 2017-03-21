//
//  MStockListView.m
//
//  Created by FanChiangShihWei on 2016/5/16.
//  Copyright © 2016年 Mitake Inc. All rights reserved.
//

#import "MStockListView.h"
#import <objc/runtime.h>
#import <mach/mach.h>
#import <libkern/OSAtomic.h>

#if DEBUG
#define CLEAR_DEQUEUE_ITEMPATH(itemPath) \
do { \
  if (__debug_itemPath == nil) break; \
  NSAssert([__debug_itemPath isEqual:itemPath], @"some problems happened..."); \
  __debug_itemPath = nil; \
} while(0)
#define CHECK_DEQUEUE_ITEMPATH(itemPath) \
do { \
  if (__debug_itemPath == nil) { \
    __debug_itemPath = itemPath; \
    break; \
  } \
  NSAssert(![__debug_itemPath isEqual:itemPath], @"不要在同一次 stockListView:cellForLayoutType:atItemPath: 的方法中多次调用dequeueReusableXXXXWithReuseIdentifier. for performance"); \
} while(0)
#else
#define CLEAR_DEQUEUE_ITEMPATH(...)
#define CHECK_DEQUEUE_ITEMPATH(...)
#endif

static const CGFloat kSeparatorLineHeight = 1.0;

static CGFloat mstocklistview_screenscale() {
    static dispatch_once_t onceToken;
    static CGFloat scale;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
};

double subtractTimes(uint64_t endTime, uint64_t startTime) {
    uint64_t difference = endTime - startTime;
    static double conversion = 0.0;
    if (conversion == 0.0) {
        mach_timebase_info_data_t info;
        kern_return_t err = mach_timebase_info(&info);
        if (err == 0) conversion = 1e-9 * (double) info.numer / (double) info.denom;
    }
    return conversion * (double)difference;
}

@interface MStockListItemPath () {
    NSInteger _section;
    NSInteger _row;
    NSInteger _column;
    NSInteger _item;
}
+ (instancetype)pathWithSection:(NSInteger)section row:(NSInteger)row column:(NSInteger)column item:(NSInteger)item;
+ (instancetype)pathWithSection:(NSInteger)section row:(NSInteger)row column:(NSInteger)column;
@end

@implementation MStockListItemPath
+ (instancetype)pathWithSection:(NSInteger)section row:(NSInteger)row column:(NSInteger)column item:(NSInteger)item {
    MStockListItemPath *itemIndex = [MStockListItemPath new];
    itemIndex->_section = section;
    itemIndex->_row = row;
    itemIndex->_column = column;
    itemIndex->_item = item;
    return itemIndex;
}

+ (instancetype)pathWithSection:(NSInteger)section row:(NSInteger)row column:(NSInteger)column {
    return [self pathWithSection:section row:row column:column item:0];
}

- (NSUInteger)hash {
    /// TODO: 先暂时满足需求即可
    return ((_section*100000000)^(_column*1000000)^_row);
//    return _section^_row^_column;
}
- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    MStockListItemPath *other = object;
    return other->_section== _section &&
    other->_row==_row && other->_column==_column;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ section:%zd, row:%zd, column:%zd, item:%zd", [super description], _section, _row, _column, _item];
}

@end

@protocol MStockListReusableViewDelegate <NSObject>
- (BOOL)beganTouchAtItemPath:(MStockListItemPath *)itemPath;
- (void)cancelledTouchAtItemPath:(MStockListItemPath *)itemPath;
- (void)endedTouchAtItemPath:(MStockListItemPath *)itemPath;
- (BOOL)shouldEndedTouchWithoutHighlightAtItemPath:(MStockListItemPath *)itemPath;
@end

@interface MStockListReusableView ()
{
    @package
    NSString *_innerIdentifier;
    MStockListItemPath *_innerItemPath;
    __weak id <MStockListReusableViewDelegate>_delegate;
    UIColor *_highlightTempBackgroundColor;
}

@end
@implementation MStockListReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
//        self.layer.shouldRasterize = YES;
//        self.layer.rasterizationScale = mstocklistview_screenscale();
    }
    return self;
}


- (void)prepareForReuse {
    
}

@end

@interface MStockListCell ()
@end

@implementation MStockListCell
#define SEPARATOR_FRAME CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kSeparatorLineHeight/mstocklistview_screenscale())
{
    struct {
        unsigned int shouldLayoutSubviews:1;
        unsigned int shouldHighlight:1;
        unsigned int shouldUpdateSeparatorColor:1;
    } _state;
    BOOL _separatorEnabled;
    CALayer *_separator;
    __weak NSTimer *_timer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _state.shouldUpdateSeparatorColor = true;
    }
    return self;
}

- (CALayer *)separator {
    if (_separator == nil) {
        _separator = [CALayer layer];
        _separator.frame = SEPARATOR_FRAME;
        _separator.zPosition = 100;
//        _separator.shouldRasterize = YES;
//        _separator.rasterizationScale = mstocklistview_screenscale();
    }
    return _separator;
}

- (void)setSeparatorEnabled:(BOOL)separatorEnabled {
    _separatorEnabled = separatorEnabled;
    if (!_separatorEnabled && [self separator].superlayer) {
        [[self separator] removeFromSuperlayer];
    }
}

- (void)setNeedsUpdateSeparator {
    _state.shouldUpdateSeparatorColor = true;
}

- (void)setSeparatorEnabled:(BOOL)separatorEnabled color:(UIColor *)color {
    [self setSeparatorEnabled:separatorEnabled];
    if (!_separatorEnabled) return;
    if (_state.shouldUpdateSeparatorColor) {
        if ([self separator].superlayer == nil) {
            [self.layer addSublayer:[self separator]];
        }
        [[self separator] setBackgroundColor:color.CGColor];
        _state.shouldUpdateSeparatorColor = false;
    }
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    if (!CGRectEqualToRect(oldFrame, frame)) {
        [self separator].frame = SEPARATOR_FRAME;
    }
}

- (void)setBounds:(CGRect)bounds {
    CGRect oldBounds = self.bounds;
    [super setBounds:bounds];
    if (!CGRectEqualToRect(oldBounds, bounds)) {
        [self separator].frame = SEPARATOR_FRAME;
    }
}
- (void)highlight {
    NSAssert([NSThread isMainThread], @"not main thread");
    BOOL shouldHighlight = [_delegate beganTouchAtItemPath:_innerItemPath];
    if (shouldHighlight || [_delegate shouldEndedTouchWithoutHighlightAtItemPath:_innerItemPath]) {
        _state.shouldHighlight = true;
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _state.shouldHighlight = false;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(highlight) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
   [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_timer invalidate]; _timer = nil;
    [_delegate cancelledTouchAtItemPath:_innerItemPath];
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_timer fire]; _timer = nil;
    if (_state.shouldHighlight) {
        [_delegate endedTouchAtItemPath:_innerItemPath];
    }
    [super touchesEnded:touches withEvent:event];
}

#undef SEPARATOR_FRAME
@end

@implementation MStockListFixedCell


@end

@implementation MStockListHeaderView {

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}
@end


#pragma mark -

@interface _MStockListViewInterceptor : NSObject <UIScrollViewDelegate> {
    @package
     __weak id receiver;
     __weak id proxy;
}
@end

@implementation _MStockListViewInterceptor
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([proxy respondsToSelector:aSelector]) {
        return proxy;
    }
    if ([receiver respondsToSelector:aSelector]) {
        return receiver;
    }
    return [super forwardingTargetForSelector:aSelector];
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([proxy respondsToSelector:aSelector] || [receiver respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}
@end


#pragma mark -

typedef struct {
    NSUInteger numberOfRows;
    CGFloat rowHeight;
    NSUInteger numberOfItems;
} SectionInfo;

enum { Cell, Header };

@interface MStockListView () <UIScrollViewDelegate, MStockListReusableViewDelegate>
{
    _MStockListViewInterceptor *_delegate_interceptor;
    NSMutableDictionary *_reusableViews;
    NSMutableDictionary *_registerClasses;
    NSMapTable *_visibleCells;
    NSMapTable *_visibleHeaders;
    
    NSMutableArray *_columnWidths;
    NSMutableArray *_sectionInfos;
    struct {
        unsigned int shouldCalculateContentSize:1;
        unsigned int useDefaultColumnWidth:1;
//        unsigned int shouldSetupCellSeparatorConfig:1; // on cell create or separator config changed
    } _state;

    
    struct {
        CGPoint startPoint;
        unsigned int direction:2;
    } _basicLayoutScrollingFlags;

    NSMapTable *_weakObjects;
    NSMutableSet *_highlightCellSet;
    
    
    /***
     主要测试同一次的delegate call是否调用两次dequeueReusableView.
     
     因为每次的dequeueReusableView只要reusableSet没有东西就会创建view且addSubview, 如此一来view就会越来越多
     注记：其实__addSubview时就应该记录所有在MStockListView上的的subview, 或著每次layout都把所有subview remove
          但考虑效能问题（可能差异不大）, 所以就用这个__debug_itemPath在开发时期就避免在同一次delegate call里重复调用dequeueReusableView
    **/
    __weak MStockListItemPath *__debug_itemPath;
}

@end

@implementation MStockListView
@synthesize delegate = _delegate;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame layoutType:(MStockListViewLayout)layoutType {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initializeVariableWithLayoutType:layoutType];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame layoutType:MStockListViewLayoutBasic];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero layoutType:MStockListViewLayoutBasic];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initializeVariableWithLayoutType:MStockListViewLayoutBasic];
    }
    return self;

}

- (void)_initializeVariableWithLayoutType:(MStockListViewLayout)layoutType {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mstocklistview_didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    self.directionalLockEnabled = YES;
    self.alwaysBounceVertical = YES;

    if (layoutType == MStockListViewLayoutBigWord1 || layoutType == MStockListViewLayoutBigWord2) {
        _separatorStyle = MStockListViewCellSeparatorStyleNone;
    } else {
        _separatorStyle = MStockListViewCellSeparatorStyleSingleLine;
    }
    
    _separatorColor = [UIColor blackColor];
    
    _layoutType = layoutType;
    
    _state.shouldCalculateContentSize = true;
    
    _delegate_interceptor = [_MStockListViewInterceptor new];
    _delegate_interceptor->proxy = self;
    super.delegate = _delegate_interceptor;
    
    _reusableViews = [NSMutableDictionary new];
    _registerClasses = [NSMutableDictionary new];
    _visibleCells = [NSMapTable strongToStrongObjectsMapTable];
    _visibleHeaders = [NSMapTable strongToStrongObjectsMapTable];
    
    /// Size
    _columnWidths = [NSMutableArray new];
    _sectionInfos = [NSMutableArray new];
    _headerHeight = 0;
    
    ///
    _weakObjects = [NSMapTable weakToWeakObjectsMapTable];
    _highlightCellSet = [NSMutableSet set];
    
}

#pragma mark - property handle
- (void)setSeparatorColor:(UIColor *)separatorColor {
    [self _setAllVisibleCellSeparatorFlagsNeedsUpdate];
    _state.shouldCalculateContentSize = true;

    _separatorColor = separatorColor;
    if (self.window) {
        [self _reloadData];
    }
}

- (void)setSeparatorStyle:(MStockListViewCellSeparatorStyle)separatorStyle {
    [self _setAllVisibleCellSeparatorFlagsNeedsUpdate];
    _state.shouldCalculateContentSize = true;

    _separatorStyle = separatorStyle;
    if (self.window) {
        [self _reloadData];
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight {
    _headerHeight = headerHeight;
}

- (void)setDelegate:(id<MStockListViewDelegate>)delegate {
    _delegate_interceptor->receiver = delegate;
    _delegate = delegate;
}

- (void)setLayoutType:(MStockListViewLayout)layoutType {
    if (_layoutType == layoutType) return;
    _layoutType = layoutType;
    
    if (layoutType == MStockListViewLayoutBigWord1 || layoutType == MStockListViewLayoutBigWord2) {
        _separatorStyle = MStockListViewCellSeparatorStyleNone;
    } else {
        _separatorStyle = MStockListViewCellSeparatorStyleSingleLine;
    }
    [self _setAllVisibleCellSeparatorFlagsNeedsUpdate];
    _state.shouldCalculateContentSize = true;

    [self _enqueueAllVisibleCellFromSuperview]; /// clear
    
    if (self.window) {
        [self _reloadData];
    }
}


#pragma mark - public 

- (void)reloadData {
    _state.shouldCalculateContentSize = true;
    [self _reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _calculateContentSizeIfNeeded];
    [self _layoutVisibleCell];
}

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    if (cellClass == nil) {
        cellClass = [MStockListCell class];
    }
    NSAssert([cellClass isSubclassOfClass:[MStockListCell class]] , @"register cell class must be kind of MStockListCell class.");
    identifier = [self _identifierWithCategory:Cell identifier:identifier];
    _registerClasses[identifier] = cellClass;
}

- (void)registerClass:(nullable Class)headerClass forHeaderWithReuseIdentifier:(NSString *)identifier {
    if (headerClass == nil) {
        headerClass = [MStockListHeaderView class];
    }
    NSAssert([headerClass isSubclassOfClass:[MStockListHeaderView class]] , @"register class must be kind of MStockListHeaderView class.");
    identifier = [self _identifierWithCategory:Header identifier:identifier];
    _registerClasses[identifier] = headerClass;
}

- (__kindof MStockListCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forItemPath:(MStockListItemPath *)itemPath {
    identifier = [self _identifierWithCategory:Cell identifier:identifier];
    MStockListCell *cell = [_visibleCells objectForKey:itemPath];
    if (cell) {
        if (cell->_innerIdentifier && [cell->_innerIdentifier isEqualToString:identifier])
            return cell; /// return visible Cell to config user data
        else
            [self _enqueueReusableCell:cell forKey:itemPath deeply:true]; /// or deeply removeFromSuperview
    }
    /// because of deeply enqueue, so that dequeue with new identifier for itemPath
    cell = [self _dequeueReusableViewWithReuseIdentifier:identifier forItemPath:itemPath];
    [cell setNeedsUpdateSeparator]; // dequeue needs update separator style
    NSAssert(cell, @"impossible");
    return cell;
}

- (__kindof MStockListHeaderView *)dequeueReusableHeaderWithReuseIdentifier:(NSString *)identifier forItemPath:(MStockListItemPath *)itemPath {
    identifier = [self _identifierWithCategory:Header identifier:identifier];
    MStockListHeaderView *header = [_visibleHeaders objectForKey:itemPath];
    if (header) {
        if (header->_innerIdentifier && [header->_innerIdentifier isEqualToString:identifier])
            return header;
        else
            [self _enqueueReusableHeader:header forKey:itemPath deeply:true];
    }
    header = [self _dequeueReusableViewWithReuseIdentifier:identifier forItemPath:itemPath];
    NSAssert(header, @"impossible");
    return header;
}


- (NSUInteger)numberOfSections {
    return [self _numberOfSections];
//    if ([_dataSource respondsToSelector:@selector(numberOfSectionsInStockListView:)]) {
//        return [_dataSource numberOfSectionsInStockListView:self];
//    }
//    return 1;
}

#pragma mark - private

- (void)_setAllVisibleCellSeparatorFlagsNeedsUpdate {
    for (MStockListItemPath *itemPath in _visibleCells.keyEnumerator) {
        MStockListCell *cell = [_visibleCells objectForKey:itemPath];
        [cell setNeedsUpdateSeparator];
    }
}

- (void)_reloadData {
    [self _calculateContentSizeIfNeeded];
    CGRect rect = (CGRect){self.contentOffset, self.bounds.size};
    [self _layoutVisibleCellInRect:rect reload:true];
}

- (BOOL)_displayHeaderViewInSection:(NSUInteger)section {
    switch ((NSInteger)_layoutType) {
        case MStockListViewLayoutBasic:
        case MStockListViewLayoutSimplify: {
            break;
        }
        case MStockListViewLayoutBigWord1:
        case MStockListViewLayoutBigWord2: {
            return NO;
        }
        case MStockListViewLayoutBangkuai:
        case MStockListViewLayoutQuoteOverview: {
            break;
        }
    }
    return _headerHeight > 0;
}

- (CGFloat)_columnWidthInSection:(NSInteger)section atColumnIndex:(NSUInteger)columnIndex {
    switch ((NSInteger)_layoutType) {
        case MStockListViewLayoutBasic:
            return [_columnWidths[columnIndex] doubleValue];
        case MStockListViewLayoutSimplify: {
            if (columnIndex == 0) {
                return CGRectGetWidth(self.bounds) * 0.36; /// design(136) / iPhone6(375) about 0.36
            }
            return CGRectGetWidth(self.bounds) * 0.64 / ([self _numberOfColumnInSection:section] - 1);
        } break;
        case MStockListViewLayoutBigWord1:
        case MStockListViewLayoutBigWord2:
            return CGRectGetWidth(self.bounds) / [self _numberOfColumnInSection:section];
        case MStockListViewLayoutBangkuai: {
#define MORE_COLUME 20.0
/// design(120) / (iPhone6(375) - MORE_COLUME(20))
#define RATIO (120.0/(375.0-MORE_COLUME))
            CGFloat width = CGRectGetWidth(self.bounds) - MORE_COLUME;
            if (columnIndex == 0) {
                return width * RATIO;
            } else if (columnIndex == [self _numberOfColumnInSection:section] - 1) {
                return MORE_COLUME;
            }
            /// exclude first column & more column
            return width * (1-RATIO) / ([self _numberOfColumnInSection:section] - 2);
#undef MORE_COLUME
#undef RATIO
        } break;
        case MStockListViewLayoutBangkuai | MStockListViewLayoutBasic:
        case MStockListViewLayoutBangkuai | MStockListViewLayoutSimplify:
            return CGRectGetWidth(self.bounds) / [self _numberOfColumnInSection:section];
        case MStockListViewLayoutQuoteOverview: {
            if (section == 0 || section == 1) {
                return CGRectGetWidth(self.bounds) / 3;
            }
            return [_columnWidths[columnIndex] doubleValue];
        } break;
    }
    return 0;
}

- (CGFloat)_rowHeightInSection:(NSUInteger)section {
    if (section < _sectionInfos.count) {
        SectionInfo info; [_sectionInfos[section] getValue:&info];
        return info.rowHeight;
    }
    return 44.0;
}

- (NSUInteger)_numberOfSections {
    switch ((NSInteger)_layoutType) {
        case MStockListViewLayoutBasic:     return 1;
        case MStockListViewLayoutSimplify:  return 1;
        case MStockListViewLayoutBigWord1:  return 1;
        case MStockListViewLayoutBigWord2:  return 1;
        case MStockListViewLayoutBangkuai:
        {
            if ([_dataSource respondsToSelector:@selector(stockListView:numberOfSectionsForLayoutType:)]) {
                return [_dataSource stockListView:self numberOfSectionsForLayoutType:_layoutType];
            }
            /// or continue next case
        }
        case MStockListViewLayoutBangkuai | MStockListViewLayoutBasic:
        case MStockListViewLayoutBangkuai | MStockListViewLayoutSimplify: return 1;
        case MStockListViewLayoutQuoteOverview: return 3;
    }
    return 0;
}

- (NSUInteger)_numberOfRowsInSection:(NSUInteger)section {
    if (section < _sectionInfos.count) {
        SectionInfo info; [_sectionInfos[section] getValue:&info];
        return info.numberOfRows;
    }
    return 0;
}

- (NSUInteger)_numberOfItemsInSection:(NSUInteger)section {
    if (section < _sectionInfos.count) {
        SectionInfo info; [_sectionInfos[section] getValue:&info];
        return info.numberOfItems;
    }
    return 0;
}

- (NSUInteger)_numberOfColumnInSection:(NSInteger)section {
    switch ((NSInteger)_layoutType) {
        case MStockListViewLayoutBasic:     return _columnWidths.count;
        case MStockListViewLayoutSimplify:  return 4;
        case MStockListViewLayoutBigWord1:  return 2;
        case MStockListViewLayoutBigWord2:  return 1;
        case MStockListViewLayoutBangkuai:  return 5;
        case MStockListViewLayoutBangkuai | MStockListViewLayoutBasic: return 4;
        case MStockListViewLayoutBangkuai | MStockListViewLayoutSimplify: return 3;
        case MStockListViewLayoutQuoteOverview: {
            if (section == 0 || section == 1) {
                return 3;
            }
            return _columnWidths.count;
        } break;
    }
    return 0;
}

- (BOOL)_freezeAllColumnsInSection:(NSUInteger)section {
    switch ((NSInteger)_layoutType) {
        case MStockListViewLayoutBasic:
        case MStockListViewLayoutSimplify:
        case MStockListViewLayoutBigWord1:
        case MStockListViewLayoutBigWord2:
        case MStockListViewLayoutBangkuai: break;
        case MStockListViewLayoutQuoteOverview: {
            return (section <= 1);
        } break;
    }
    return NO;
}

- (BOOL)_freezeFirstColumnInSection:(NSUInteger)section {
    switch ((NSInteger)_layoutType) {
        case MStockListViewLayoutBasic: return YES;
        case MStockListViewLayoutSimplify:
        case MStockListViewLayoutBigWord1:
        case MStockListViewLayoutBigWord2:
        case MStockListViewLayoutBangkuai: break;
        case MStockListViewLayoutQuoteOverview: {
            return (section >= 2);
        } break;
    }
    return NO;
}

- (NSInteger)_persistColumnsForFixedRowInSection:(NSUInteger)section {
    switch ((NSInteger)_layoutType) {
        case MStockListViewLayoutBasic: return 1;
        case MStockListViewLayoutSimplify: return 2;
        case MStockListViewLayoutBigWord1:
        case MStockListViewLayoutBigWord2:
        case MStockListViewLayoutBangkuai: break;
        case MStockListViewLayoutQuoteOverview: {
            if (section >= 2) return 1;
        } break;
    }
    return -1;
}

- (void)_highlightRowAtItemPath:(MStockListItemPath *)itemPath startColumn:(NSInteger)startColumn {
    UIColor *highlightBackgroundColor = nil;
    NSInteger numberOfColumns = [self _numberOfColumnInSection:itemPath.section];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    for (NSInteger column = startColumn; column < numberOfColumns; column++) {
        MStockListItemPath *targetItemPath = [MStockListItemPath pathWithSection:itemPath.section
                                                                             row:itemPath.row
                                                                          column:column];
        MStockListReusableView *cell = [_visibleCells objectForKey:targetItemPath];
        if (!cell) continue;
        [self _highlightView:cell color:&highlightBackgroundColor];
    }
    [CATransaction commit];
}

- (void)_highlightRowAtItemPath:(MStockListItemPath *)itemPath {
    [self _highlightRowAtItemPath:itemPath startColumn:0];
}

- (void)_highlightItemAtItemPath:(MStockListItemPath *)itemPath {
    UIColor *highlightBackgroundColor = nil;
    MStockListReusableView *cell = [_visibleCells objectForKey:itemPath];
    if (cell) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        [self _highlightView:cell color:&highlightBackgroundColor];
        [CATransaction commit];
    }
}

- (void)_highlightSelectionAtItemPath:(MStockListItemPath *)itemPath {
    switch ((NSInteger)_layoutType) {
        case MStockListViewLayoutBasic:
        case MStockListViewLayoutSimplify: {
            [self _highlightRowAtItemPath:itemPath];
        } break;
        case MStockListViewLayoutBigWord1:
        case MStockListViewLayoutBigWord2: {
            [self _highlightItemAtItemPath:itemPath];
        } break;
        case MStockListViewLayoutBangkuai:
        case MStockListViewLayoutBangkuai | MStockListViewLayoutBasic:
        case MStockListViewLayoutBangkuai | MStockListViewLayoutSimplify:
        {
            if (itemPath.column == 0) {
                [self _highlightItemAtItemPath:itemPath];
            } else {
                [self _highlightRowAtItemPath:itemPath startColumn:1];
            }
        } break;
        case MStockListViewLayoutQuoteOverview: {
            if (itemPath.section == 0 || itemPath.section == 1) {
                [self _highlightItemAtItemPath:itemPath];
            } else {
                [self _highlightRowAtItemPath:itemPath];
            }
        } break;
    }
}

- (void)_unhighlightSelection {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    for (MStockListReusableView *cell in _highlightCellSet) {
        cell.layer.backgroundColor = cell->_highlightTempBackgroundColor.CGColor;
    }
    [CATransaction commit];
    [_highlightCellSet removeAllObjects];
}

- (void)_highlightView:(MStockListReusableView * _Nonnull)view color:(__autoreleasing UIColor **)color {
    view->_highlightTempBackgroundColor = view.backgroundColor;
    
    if (*color == nil) {
        *color = view.highlightBackgroundColor;
        if (*color == nil) {
            CGFloat h, s, b, a;
            [view.backgroundColor getHue:&h saturation:&s brightness:&b alpha:&a];
            *color = [UIColor colorWithHue:h
                                saturation:s
                                brightness:fabs(b-0.9)
                                     alpha:1];
        }
    }
    view.layer.backgroundColor = (*color).CGColor;

    [_highlightCellSet addObject:view];
}

- (void)_calculateContentSizeIfNeeded {
    if (_state.shouldCalculateContentSize == false) return;
    _state.shouldCalculateContentSize = false;
    
    /// clean cache data
    [_columnWidths removeAllObjects];
    [_sectionInfos removeAllObjects];
    
    
    CGFloat contentHeight = 0;
    CGFloat contentWidth = 0;
    
    /// 先算宽
    switch ((NSInteger)_layoutType) {
        case MStockListViewLayoutBasic:
        case MStockListViewLayoutQuoteOverview: {
            NSUInteger numberOfColumns = 0;
            
            if ([self.basicLayoutDataSource respondsToSelector:@selector(numberOfColumnsForBasicStockListView:)]) {
                numberOfColumns = [self.basicLayoutDataSource numberOfColumnsForBasicStockListView:self];
            }
            
            _state.useDefaultColumnWidth = ![self.basicLayoutDataSource respondsToSelector:@selector(basicStockListView:columnWidthAtColumnIndex:)];
            CGFloat columnWidth;
            for (NSUInteger column = 0; column < numberOfColumns; column++) {
                if (_state.useDefaultColumnWidth) {
                    columnWidth = CGRectGetWidth(self.bounds) / numberOfColumns;
                } else {
                    columnWidth = [self.basicLayoutDataSource basicStockListView:self columnWidthAtColumnIndex:column];
                }
                [_columnWidths addObject:@(columnWidth)];
                contentWidth += columnWidth;
            }
        } break;
        default: {
            contentWidth = CGRectGetWidth(self.bounds);
        } break;
    }

    /// 后算高
    for (NSInteger section = 0; section < self.numberOfSections; section++) {
        
        NSUInteger numberOfColumns = [self _numberOfColumnInSection:section];
        NSUInteger numberOfItems = [_dataSource stockListView:self numberOfItemsInSection:section forLayoutType:_layoutType];;
        BOOL displayHeader = [self _displayHeaderViewInSection:section];
        
        SectionInfo info = {0, 44.0, 0};

        switch ((NSInteger)_layoutType) {
            case MStockListViewLayoutBasic:
            case MStockListViewLayoutSimplify: {
                info.numberOfRows = numberOfItems;
                info.numberOfItems = numberOfItems * numberOfColumns + numberOfColumns;
                if (displayHeader) info.numberOfItems += numberOfColumns;
            } break;
            case MStockListViewLayoutBigWord1:
            case MStockListViewLayoutBigWord2: {
                if (numberOfItems % numberOfColumns == 0) {
                    info.numberOfRows = numberOfItems / numberOfColumns;
                } else {
                    info.numberOfRows = (numberOfItems / numberOfColumns) + 1;
                }
                info.numberOfItems = numberOfItems;
                if (displayHeader) info.numberOfItems += numberOfColumns;
            } break;
            case MStockListViewLayoutBangkuai:
            case MStockListViewLayoutBangkuai | MStockListViewLayoutBasic:
            case MStockListViewLayoutBangkuai | MStockListViewLayoutSimplify:
            {
                info.numberOfRows = numberOfItems;
                info.numberOfItems = numberOfItems * numberOfColumns + numberOfColumns;
                if (displayHeader) info.numberOfItems += numberOfColumns;
            } break;
            case MStockListViewLayoutQuoteOverview: {
                
                if (section == 0 || section == 1) {
                    if (numberOfItems % numberOfColumns == 0) {
                        info.numberOfRows = numberOfItems / numberOfColumns;
                    } else {
                        info.numberOfRows = (numberOfItems / numberOfColumns) + 1;
                    }
                    info.numberOfItems = numberOfItems;
                    if (displayHeader) info.numberOfItems += numberOfColumns;
                } else {
                    info.numberOfRows = numberOfItems;
                    info.numberOfItems = numberOfItems * numberOfColumns + numberOfColumns;
                    if (displayHeader) info.numberOfItems += numberOfColumns;
                }
            } break;
        }
        if ([_dataSource respondsToSelector:@selector(stockListView:rowHeightInSection:forLayoutType:)]) {
            info.rowHeight = [_dataSource stockListView:self rowHeightInSection:section forLayoutType:_layoutType];
        }
        [_sectionInfos addObject:[NSValue value:&info withObjCType:@encode(SectionInfo)]];
        
        if ([self _displayHeaderViewInSection:section]) {
            contentHeight += _headerHeight;
        }
        
        /// 分隔线高
        if (_separatorStyle == MStockListViewCellSeparatorStyleSingleLine) {
            contentHeight += (info.numberOfRows*kSeparatorLineHeight);
        }
        contentHeight += info.rowHeight*info.numberOfRows;
        
    }
    
    self.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)_enqueueReusableCell:(MStockListCell *)cell forKey:(id)key {
    [self _enqueueReusableCell:cell forKey:key deeply:false];
}

- (void)_enqueueReusableCell:(MStockListCell *)cell forKey:(id)key deeply:(bool)deeply {
    [_visibleCells removeObjectForKey:key];
    cell.hidden = YES;
    if (deeply) {
        [cell removeFromSuperview];
    }
    if (cell->_innerIdentifier == nil) return;
    NSMutableSet *cells = _reusableViews[cell->_innerIdentifier];
    NSAssert(cells, @"shouldn't nil");
    [cells addObject:cell];
}

- (void)_enqueueReusableHeader:(MStockListHeaderView *)header forKey:(id)key {
    [self _enqueueReusableHeader:header forKey:key deeply:false];
}

- (void)_enqueueReusableHeader:(MStockListHeaderView *)header forKey:(id)key deeply:(bool)deeply {
    [_visibleHeaders removeObjectForKey:key];
    header.hidden = YES;
    if (deeply) [header removeFromSuperview];
    if (header->_innerIdentifier == nil) return;
    NSMutableSet *headers = _reusableViews[header->_innerIdentifier];
    NSAssert(headers, @"shouldn't nil");
    [headers addObject:header];
}

- (NSString *)_identifierWithCategory:(NSInteger)category identifier:(NSString *)identifier {
    if (category == Header) return [NSString stringWithFormat:@"%@-Header", identifier];
    if (category == Cell) return [NSString stringWithFormat:@"%@-Cell", identifier];
    return identifier;
}

- (__kindof MStockListReusableView *)_dequeueReusableViewWithReuseIdentifier:(NSString *)identifier forItemPath:(MStockListItemPath *)itemPath {
    CHECK_DEQUEUE_ITEMPATH(itemPath);
    NSMutableSet *views = _reusableViews[identifier];
    if (views == nil) {
        views = [NSMutableSet set];
        _reusableViews[identifier] = views;
    }
    MStockListReusableView *view = [views anyObject];
    if (view == nil) {
        Class cellClass = _registerClasses[identifier];
        NSAssert(cellClass, @"must call register class for cell or header.");
        /// likes UITableViewCell default height
        view = [[cellClass alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 44.0)];
        view->_delegate = self;
        view->_innerIdentifier = [identifier copy];
    } else {
        [views removeObject:view];
    }
    view->_innerItemPath = itemPath;
    [view prepareForReuse]; /// override call
    
    /// move to window if needed
    if (view.superview == nil) {
        [self __addSubview:view];
    }
    return view;
}

- (void)_enqueueAllVisibleCellFromSuperview {
    for (id obj in self.subviews) {
        if ([obj isKindOfClass:[MStockListReusableView class]]) {
            MStockListReusableView *view = obj;
            [view removeFromSuperview];

            if (view->_innerIdentifier == nil) continue;
            NSMutableSet *cells = _reusableViews[view->_innerIdentifier];
            NSAssert(cells, @"shouldn't nil");
            [cells addObject:view];
        }
    }
    [_visibleCells removeAllObjects];
    [_visibleHeaders removeAllObjects];
}

- (void)_layoutVisibleCell {
    CGRect rect = (CGRect){self.contentOffset, self.bounds.size};
    [self _layoutVisibleCellInRect:rect reload:false];
}

- (void)_layoutVisibleCellInRect:(CGRect)rect reload:(bool)reload {
    
    NSMapTable *visibleCells = [_visibleCells mutableCopy];
    NSMapTable *disabledCells = [NSMapTable weakToWeakObjectsMapTable];
    for (MStockListItemPath *itemPath in visibleCells.keyEnumerator) {
        MStockListCell *cell = [visibleCells objectForKey:itemPath];
        BOOL isKindOfFixedCell = [cell isKindOfClass:[MStockListFixedCell class]];
        if (!CGRectIntersectsRect(cell.frame, rect) || isKindOfFixedCell) {
            [self _enqueueReusableCell:cell forKey:itemPath deeply:isKindOfFixedCell?true:false];
            continue;
        }
        [disabledCells setObject:cell forKey:itemPath]; /// 还在画面上的cell, 但等等要判断是否layout
    }
    
    NSMapTable *visibleHeaders = [_visibleHeaders mutableCopy];
    NSMapTable *disabledHeaders = [NSMapTable weakToWeakObjectsMapTable];
    for (MStockListItemPath *itemPath in visibleHeaders.keyEnumerator) {
        MStockListHeaderView *header = [visibleHeaders objectForKey:itemPath];
        if (!CGRectIntersectsRect(header.frame, rect)) {
            [self _enqueueReusableHeader:header forKey:itemPath];
            continue;
        }
        [disabledHeaders setObject:header forKey:itemPath];
    }
    
    CGFloat visibleMinOffsetY = MAX(0, self.contentOffset.y);
    CGFloat visibleMaxOffsetY = MIN(self.contentSize.height, self.contentOffset.y + CGRectGetHeight(self.frame));
    CGFloat sectionStartOffsetY = 0;
    
    CGFloat separatorLineHeight = 0;
    if (_separatorStyle == MStockListViewCellSeparatorStyleSingleLine) {
        separatorLineHeight = kSeparatorLineHeight;
    }
    
    for (NSInteger section = 0; section < self.numberOfSections; section++) {
        
        if (sectionStartOffsetY > visibleMaxOffsetY) break; /// 超过可视范围
        
        /// Get section information
        NSUInteger numberOfRows = [self _numberOfRowsInSection:section];
        CGFloat rowHeight = [self _rowHeightInSection:section] + separatorLineHeight; /// 如果有值，后面的cell frame会减回来
        BOOL displayHeader = [self _displayHeaderViewInSection:section];
        NSUInteger numberOfItems = [self _numberOfItemsInSection:section];
        NSInteger numberOfColumns = [self _numberOfColumnInSection:section];
        NSInteger persistColumnsForFixedRow = [self _persistColumnsForFixedRowInSection:section];
        
        CGFloat sectionHeight = rowHeight * numberOfRows;
        if (displayHeader) {
            sectionHeight += _headerHeight;
            numberOfRows += 1;
        }
        
        if (sectionStartOffsetY + sectionHeight < visibleMinOffsetY) { /// 小于可视范围
            sectionStartOffsetY += sectionHeight;
            continue;
        }
        
        CGFloat yOffset = visibleMinOffsetY;
        NSInteger sectionStartRow = (visibleMinOffsetY - sectionStartOffsetY) / rowHeight;
        
        if (displayHeader) {
            yOffset = sectionStartOffsetY + MAX(0,sectionStartRow - 1)*rowHeight;
        } else {
            yOffset = sectionStartOffsetY + MAX(0,sectionStartRow)*rowHeight;
        }
        CGFloat xOffset = 0.0;
        CGFloat currentRowHeight = 0;
        
        __unused bool headerDidDisplay = false;
        for (NSInteger row = displayHeader ? 0 : sectionStartRow;
             row < numberOfRows;
             sectionStartRow > 0 ? (row == 0 ? row+=sectionStartRow : row++) : row++)
        {
            ///
            if (displayHeader && row == 0) {
                currentRowHeight = _headerHeight;
            } else {
                currentRowHeight = rowHeight;
            }
            /// skip
            if (row >= numberOfRows) break; // 超过
            if (row < 0) {
                yOffset += currentRowHeight;
                continue;
            }
            
            bool fixedCellFlag = false;
            
            for (NSUInteger column = 0; column < numberOfColumns; column++) {
                CGFloat columnWidth = [self _columnWidthInSection:section atColumnIndex:column];
                
                CGRect frame = CGRectIntegral(CGRectMake(xOffset, yOffset, columnWidth, currentRowHeight));
                
                //// sticky header
                if (displayHeader && row == 0) {
                    CGFloat nextSectionOffsetY = sectionStartOffsetY + sectionHeight;
                    CGFloat headerInset = ((nextSectionOffsetY - self.contentOffset.y) - _headerHeight);
                    if (headerInset < 0) {
                        frame.origin.y = MAX(sectionStartOffsetY, self.contentOffset.y) + headerInset;
                    } else {
                        frame.origin.y = MAX(sectionStartOffsetY, self.contentOffset.y);
                    }
                }
                
                /// 判断栏位x轴是否固定
                /// 1. basic layout左边名称固定栏位
                /// 2. quote overview layout section(1) & section(2)固定的View
                if ([self _freezeAllColumnsInSection:section] ||
                    (column == 0 && [self _freezeFirstColumnInSection:section])) {
                    frame.origin.x = self.contentOffset.x + (column * columnWidth);
                }
                
                NSInteger itemIndex = row * numberOfColumns + column;
                if (itemIndex >= numberOfItems) break; /// 单数Item, exit
                
                if (CGRectIntersectsRect(frame, rect)) {
                    /// Header
                    if (displayHeader && row == 0) {
                        MStockListItemPath *itemPath = [MStockListItemPath pathWithSection:section row:row column:column item:itemIndex];
                        
                        MStockListHeaderView *header = [_visibleHeaders objectForKey:itemPath];

                        if (header == nil) {
                            header = [self.dataSource stockListView:self headerForLayoutType:_layoutType atItemPath:itemPath];
                            NSAssert(header, @"must return header cell");
                            if (header.isHidden) {
                                header.hidden = NO;
                            }
                            [_visibleHeaders setObject:header forKey:itemPath];
                            
                        } else if (reload) {
                            /// reload的作法比较特殊，参考底下cell reload的注解
                            MStockListHeaderView *reconfigHeader = [self.dataSource stockListView:self headerForLayoutType:_layoutType atItemPath:itemPath];
                            NSAssert(header, @"must return header cell");
                            
                            if (header != reconfigHeader) {
                                /// enqueue old
                                [self _enqueueReusableHeader:header forKey:itemPath deeply:true];
                                
                                if (reconfigHeader.isHidden) {
                                    reconfigHeader.hidden = NO;
                                }
                                [_visibleHeaders setObject:reconfigHeader forKey:itemPath];
                            }
                            /// and 重新定向
                            header = reconfigHeader;
                        }
                        CLEAR_DEQUEUE_ITEMPATH(itemPath);
                        
                        if (row == 0 && column == 0) {
                            header.layer.zPosition = -1;
                        } else {
                            header.layer.zPosition = -2;
                        }
                        if (!CGRectEqualToRect(header.frame, frame)) {
                            header.frame = frame;
                        }
                        [disabledHeaders removeObjectForKey:itemPath];
                    }
                    /// Other
                    else {
                        //// note: SeparatorLine处理，看一下前面逻辑
                        frame.size.height -= separatorLineHeight;
                        
                        MStockListItemPath *itemPath;
                        if (displayHeader) {
                            itemPath = [MStockListItemPath pathWithSection:section row:row-1 column:column item:itemIndex-numberOfColumns];
                        } else {
                            itemPath = [MStockListItemPath pathWithSection:section row:row column:column item:itemIndex];
                        }
                        
                        MStockListCell *cell = [_visibleCells objectForKey:itemPath];
                        
                        if (cell == nil) {
                            cell = [self.dataSource stockListView:self cellForLayoutType:_layoutType atItemPath:itemPath];
                            NSAssert(cell, @"must return cell");
                            NSAssert(!(column < persistColumnsForFixedRow &&
                                       [cell isKindOfClass:[MStockListFixedCell class]]), @"column(%zd) can not be kind of MStockListFixedCell class.", column);
                            if (cell.isHidden) {
                                cell.hidden = NO;
                            }
                            [_visibleCells setObject:cell forKey:itemPath];

                        } else if (reload) {
                            
                            /***
                             note一下：
                             这里的cell是从_visibleCells里拿出来的，表示在画面上的itemPath，利用这个itemPath去呼叫底下的dataSource
                             dataSource回传的是user dequeue的cell并进行重新附值，但user dequeue的cell有两种可能性：
                               1. dequeue的是相同identifier且itemPath相同的cell
                               2. otherwise ...
                             如果是第二种情况则视为这个cell被改变了，所以必须enqueue它，然后再将reconfig后的cell重新layout
                             **/
                            MStockListCell *reconfigCell = [self.dataSource stockListView:self cellForLayoutType:_layoutType atItemPath:itemPath];
                            NSAssert(reconfigCell, @"must return cell");
                            NSAssert(!(column < persistColumnsForFixedRow &&
                                       [reconfigCell isKindOfClass:[MStockListFixedCell class]]), @"column(%zd) can not be kind of MStockListFixedCell class.", column);
                            if (cell != reconfigCell) {
                                /// enqueue old
                                [self _enqueueReusableCell:cell forKey:itemPath deeply:true];

                                /// 这里的 cell不是刚刚从_visibleCells里拿出来的，不在画面上，所以必须替换掉原本旧的
                                if (reconfigCell.isHidden) {
                                    reconfigCell.hidden = NO;
                                }
                                [_visibleCells setObject:reconfigCell forKey:itemPath];
                            }
                            /// and 重新定向
                            cell = reconfigCell;
                        }

                        CLEAR_DEQUEUE_ITEMPATH(itemPath);

                        // update separator IF NEEDED!!
                        [cell setSeparatorEnabled:separatorLineHeight > 0 color:_separatorColor];
                        
                        /// 设置固定的Cell
                        if ([cell isKindOfClass:[MStockListFixedCell class]])
                        {
                            if (column >= persistColumnsForFixedRow) {
                                fixedCellFlag = true;
                                CGFloat leftColumnWidth = 0;
                                for (NSInteger idx = 0; idx < persistColumnsForFixedRow; idx++) {
                                    leftColumnWidth += [self _columnWidthInSection:section atColumnIndex:idx];
                                }
                                CGFloat xx = self.contentSize.width - self.contentOffset.x - CGRectGetWidth(self.frame);
                                frame.origin.x = MAX(0, self.contentOffset.x) + leftColumnWidth + MIN(0, xx);
                                frame.size.width = CGRectGetWidth(self.frame) - leftColumnWidth;
                                cell.layer.zPosition = -100;
                                cell.frame = frame;
                                
                                [disabledCells removeObjectForKey:itemPath];
                            } else {
                                [self _enqueueReusableCell:cell forKey:itemPath deeply:true];
                            }
                            goto EXIT_FOR_COLUMN;
                        }
                        {
                            if (column == 0) {
                                cell.layer.zPosition = -50;
                            } else {
                                cell.layer.zPosition = -101;
                            }
                            if (!CGRectEqualToRect(cell.frame, frame)) {
                                cell.frame = frame;
                            }
                            [disabledCells removeObjectForKey:itemPath];
                        }
                    }
                }
                
            EXIT_FOR_COLUMN:
                xOffset = xOffset+columnWidth;
                if (column == numberOfColumns - 1){
                    xOffset = 0;
                    yOffset += currentRowHeight;
                } else if (fixedCellFlag) {
                    xOffset = 0;
                    yOffset += currentRowHeight;
                    break;
                }
            } //column end
            
            if (yOffset > visibleMaxOffsetY) { /// yOffset超过可视范围
                break;
            }
            
        } // row end
        sectionStartOffsetY += sectionHeight;
        
    } // section end
    
    
    //// enqueue 未被layout的view
    for (MStockListItemPath *itemPath in disabledCells.keyEnumerator) {
        MStockListCell *cell = [visibleCells objectForKey:itemPath];
        [self _enqueueReusableCell:cell forKey:itemPath];
    }
    for (MStockListItemPath *itemPath in disabledHeaders.keyEnumerator) {
        MStockListHeaderView *header = [visibleHeaders objectForKey:itemPath];
        [self _enqueueReusableHeader:header forKey:itemPath];
    }
}

#pragma mark - memory warning handle

- (void)mstocklistview_didReceiveMemoryWarning:(NSNotification *)notification {
    if (self.window == nil) {
        [_reusableViews removeAllObjects];
        
        for (MStockListCell *cell in _visibleCells.objectEnumerator) {
            if (cell.superview) [cell removeFromSuperview];
        }
        [_visibleCells removeAllObjects];
        
        for (MStockListHeaderView *header in _visibleHeaders.objectEnumerator) {
            if (header.superview) [header removeFromSuperview];
        }
        [_visibleHeaders removeAllObjects];
    
        [self _unhighlightSelection];
    }
}

#pragma mark - MStockListReusableView delegate

- (BOOL)beganTouchAtItemPath:(MStockListItemPath *)itemPath {
    BOOL shouldHighlight =
        !self.isDecelerating
    && !self.isDragging;
//        && !self.isTracking;
    if (!shouldHighlight) return NO;
    
    /// MARK: 简易报价最后一栏不highlight
    shouldHighlight = !(_layoutType & MStockListViewLayoutSimplify &&
                        itemPath.column == [self _numberOfColumnInSection:itemPath.section] - 1);
    if (!shouldHighlight) return NO;
    ////
    
    [self _highlightSelectionAtItemPath:itemPath];
    return YES;
}

- (void)endedTouchAtItemPath:(MStockListItemPath *)itemPath {
    if ([_delegate respondsToSelector:@selector(stockListView:didSelectItemAtItemPath:)]) {
        [_delegate stockListView:self didSelectItemAtItemPath:itemPath];
    }
    [self _unhighlightSelection];
}

- (BOOL)shouldEndedTouchWithoutHighlightAtItemPath:(MStockListItemPath *)itemPath {
    return (_layoutType & MStockListViewLayoutSimplify &&
            itemPath.column == [self _numberOfColumnInSection:itemPath.section] - 1);
}

- (void)cancelledTouchAtItemPath:(MStockListItemPath *)itemPath {
    [self _unhighlightSelection];
}


#pragma mark - Basic layout v&h scrolling handle

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_delegate scrollViewDidScroll:self];
    }

    if (self != scrollView) return;
    /// Horizontal scrolling handle
    for (UIView *v in _weakObjects) {
        CGRect bounds = v.bounds;
        bounds.origin.x = -scrollView.contentOffset.x;
        v.bounds = bounds;
    }
    ///////
    
    if (self.contentSize.width <= CGRectGetWidth(self.bounds)) return;
    
    if (_basicLayoutScrollingFlags.direction == 0) {
        if (fabs(_basicLayoutScrollingFlags.startPoint.x-scrollView.contentOffset.x)
            < fabs(_basicLayoutScrollingFlags.startPoint.y-scrollView.contentOffset.y)){
            //Vertical Scrolling
            _basicLayoutScrollingFlags.direction = 1;
        } else {
            //Horitonzal Scrolling
            _basicLayoutScrollingFlags.direction = 2;
        }
    }
    if (_basicLayoutScrollingFlags.direction == 1) {
        scrollView.contentOffset = CGPointMake(_basicLayoutScrollingFlags.startPoint.x,
                                               scrollView.contentOffset.y);
    } else if (_basicLayoutScrollingFlags.direction == 2){
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x,
                                               _basicLayoutScrollingFlags.startPoint.y);
        
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_delegate scrollViewWillBeginDragging:self];
    }
    
    if (self != scrollView) return;
    if (scrollView.isDecelerating) return;
    _basicLayoutScrollingFlags.startPoint = scrollView.contentOffset;
    _basicLayoutScrollingFlags.direction = 0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_delegate scrollViewDidEndDecelerating:self];
    }
    
    if (self != scrollView) return;
    
    _basicLayoutScrollingFlags.startPoint = scrollView.contentOffset;
    _basicLayoutScrollingFlags.direction = 0;
}


#pragma mark - Subclassing hooks

- (void)__addSubview:(UIView *)view {
    [super addSubview:view];
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    [_weakObjects setObject:(NSNull *)kCFNull forKey:view];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    [super insertSubview:view atIndex:index];
    [_weakObjects setObject:(NSNull *)kCFNull forKey:view];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    [super insertSubview:view aboveSubview:siblingSubview];
    [_weakObjects setObject:(NSNull *)kCFNull forKey:view];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
    [super insertSubview:view belowSubview:siblingSubview];
    [_weakObjects setObject:(NSNull *)kCFNull forKey:view];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    /// 优先处理Header
    MStockListHeaderView *hitHeader = nil;
    for (MStockListHeaderView *header in _visibleHeaders.objectEnumerator) {
        if (CGRectContainsPoint(header.frame, point)) {
            if (!hitHeader || hitHeader.layer.zPosition < header.layer.zPosition)
                hitHeader = header;
        }
    }
    if (hitHeader) {
        CGPoint p = [self convertPoint:point toView:hitHeader];
        return [hitHeader hitTest:p withEvent:event];
    }
    return [super hitTest:point withEvent:event];
}

@end
