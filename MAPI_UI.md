
<h1 id="top">移动客户端图形接口说明</h1>
================

* [概述](#概述)
	* [目的](#目的)
	* [形式说明](#形式说明)
	* [UI类别列表](#UI类别列表)
* [使用说明](#使用说明) 
	* [线图父类别(MChartView)](#MChartView)
		* [说明](#MChartViewExplain)
		* [属性](#MChartViewAttribute)
		* [调用样例](#MChartViewSample)
	* [走势图(MTrendChartView)](#MTrendChartView)
		* [说明](#MTrendChartViewExplain)
		* [属性](#MTrendChartViewAttribute)
		* [调用样例](#MTrendChartViewSample)
	* [基金净值走势图(MFundChartView)](#MFundChartView)
		* [说明](#MFundChartViewExplain)
		* [属性](#MFundChartViewAttribute)
		* [调用样例](#MFundChartViewSample)
	* [K线图(MOHLCChartView)](#MOHLCChartView)
		* [说明](#MOHLCChartViewExplain)
		* [属性](#MOHLCChartViewAttribute)
		* [调用样例](#MOHLCChartViewSample)
	* [K线图指标(MPlot)](#MPlot)
		* [说明](#MPlotExplain)
		* [属性](#MPlotAttribute)
		* [主图指标](#主图指标)
			* [移动平均线(MMAPlot)](#MMAPlot)
			* [布林线(MBOLLPlot)](#MBOLLPlot)
		* [副图指标](#副图指标)
			* [成交量指标(MVOLPlot)](#MVOLPlot)
			* [相对强弱指标(MRSIPlot)](#MRSIPlot)
			* [随机指标(MKDJPlot)](#MKDJPlot)	
			* [指数平滑移动平均(MMACDPlot)](#MMACDPlot)
			* [乖离率指标(MBIASPlot)](#MBIASPlot)
			* [顺势指标(MCCIPlot)](#MCCIPlot)	
			* [威廉指标(MWRPlot)](#MWRPlot)	
			* [人气指标(MARPlot)](#MARPlot)	
			* [多空指标(MBBIPlot)](#MBBIPlot)	
			* [意愿指标(MBRPlot)](#MBRPlot)	
			* [随机指数(MKDPlot)](#MKDPlot)	
			* [动向指标(MDMIPlot)](#MDMIPlot)	
			* [心理线指标(MPSYPlot)](#MPSYPlot)	
			* [能量潮指标(MOBVPlot)](#MOBVPlot)	
			* [动量指标(MMTMPlot)](#MMTMPlot)	
			* [成交量变异率(MVRPlot)](#MVRPlot)	
			* [变动速率指标(MROCPlot)](#MROCPlot)
			* [负量指标(MNVIPlot)](#MNVIPlot)	
			* [正成交量指标(MPVIPlot)](#MPVIPlot)
	* [新股日历图(MIPOCalendarView)](#MIPOCalendarView)
		* [说明](#MIPOCalendarViewExplain)
		* [属性](#MIPOCalendarViewAttribute)
		* [调用样例](#MIPOCalendarViewSample)
	* [新股日历详情图(MIPODetailView)](#MIPODetailView)
		* [说明](#MIPODetailViewExplain)
		* [属性](#MIPODetailViewAttribute)
		* [调用样例](#MIPODetailViewSample)
		
	* [五档明细视图(MTopPriceDetailView)](#MTopPriceDetailView)
		* [说明](#MTopPriceDetailViewExplain)
		* [属性](#MTopPriceDetailViewAttribute)
		* [调用样例](#MTopPriceDetailViewSample)

* [其他](#其他)
	* [走势图类型(MTrendChartType)](#MTrendChartType)
	* [K线图类型(MOHLCChartType)](#MOHLCChartType)
	* [新股日历轴线滚动方向(MIPOCalendarViewScrollDirection)](#MIPOCalendarViewScrollDirection)
	* [新股日历视图代理(MIPOCalendarViewDelegate)](#MIPOCalendarViewDelegate)
	* [新股日历详情是图代理(MIPODetailViewDelegate)](#MIPODetailViewDelegate)
	

* * *

<h2 id="概述">概述</h2>

<h3 id="目的">目的</h3>

* 本文档面向的读者是项目开发人员，其中详细描述了iOS系统之请求应答类别名与上下行参数的属性名称及型态。
* 如何通过行情客户端接口发送请求，进而获得行情数据，请至网页下载最新的[API Documentation](http://example.net/)或下载[Demo](http://example.net/)程式码。
* 接口实现了UI层及行情数据请求通讯封装，故开发UI人员可以大量减少处理数据及复杂UI逻辑的代码与时间。

<h3 id="形式说明">形式说明</h3>

* 接口中的类名、属性名及方法名皆以驼峰式命名法，类名首字母皆为大写，属性及方法名首字母皆为小写。
* 由于iOS不支持命名空间，故类名皆冠上M来避免与工程上的其他类重复。

=======
<h2 id="使用说明">使用说明</h2>

<h3 id="MChartView">线图父类别：MChartView</h3>

<h4 id="MChartViewExplain">说明</h4>

* 此为[MTrendChartView](#MTrendChartView)及[MOHLCChartView](#MOHLCChartView)的父类别，包含通用属性及方法，其馀属性及方法请参考各个子类别实现。

<h4 id="MChartViewAttribute">属性</h4>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| code    | 股票代码 | NSString | 包含市场别 如：000001.sh |
	| yAxisFont   | y轴文字风格 | UIFont |      |
	| xAxisFont | x轴文字风格 | UIFont |      |
	| xAxisTextColor | x轴文字颜色 | UIColor |      |
	| borderWidth | 外框线宽 | CGFloat |      |
	| borderColor | 外框颜色 | UIColor | |
	| insideLineWidth | 内部线宽 | CGFloat |      |
	| insideLineColor | 内部线颜色 | UIColor |      |
	| enquiryEnabled    | 是否可使用查价线 | BOOL |      |
	| enquiryLineColor   | 查价线颜色 | UIColor |      |
	| enquiryFrameColor   | 查价线外框颜色 | UIColor |      |
	| enquiryTextFont   | 查价线文字风格 | UIFont |      |
	| enquiryTextColor   | 查价线文字颜色 | UIColor |      |
	| enquiryLineMode   | 查价线绘制模式 | MChartEnquiryLineMode |  类型请参考[MChartEnquiryLineMode](#MChartEnquiryLineMode)  |

* 方法说明:

	| 方法名      | 说明         | 回调型态         | 备注 |
	|-------------|--------------|--------------|------|
	| reloadData | 请求数据并刷新线图 | void |  |


<h4 id="MChartViewSample">调用样例</h4>
调用样例请参考各子类别[top](#top)


<h3 id="MTrendChartView">走势图：MTrendChartView</h3>

<h4 id="MTrendChartViewExplain">说明</h4>

* 从服务器取得取得分时走势或五日走势，并绘制走势图。

<h4 id="MTrendChartViewAttribute">属性</h4>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| type               | 走势图类型 | MTrendChartType | 类型请参考[MTrendChartType](#MTrendChartType) |
	| priceRiseTextColor | 价格涨文字颜色 | UIColor |      |
	| priceFlatTextColor | 价格平盘文字颜色 | UIColor |      |
	| priceDropTextColor | 价格跌文字颜色 | UIColor |      |
	| rangeRiseTextColor | 价格涨幅文字颜色 | UIColor | |
	| rangeFlatTextColor | 价格幅度平盘文字颜色 | UIColor |      |
	| rangeDropTextColor | 价格跌幅文字颜色 | UIColor |      |
	| volumeTextColor    | 量文字颜色 | UIColor |      |
	| currentLineColor   | 价格线颜色 | UIColor |      |
	| currentLineWidth   | 价格线宽 | CGFloat |      |
	| averageLineColor   | 均价线颜色 | UIColor |      |
	| averageLineWidth   | 均价线宽 | CGFloat |      |
	| volumeRiseColor    | 量涨颜色 | UIColor |      |
	| volumeDropColor    | 量跌颜色 | UIColor |      |
	| gradientColors    | 渐层颜色 | NSArray |      |
	| gradientLocations    | 渐层颜色位置 | CGFloat[] |      |
	| lastBlinkDot    | 最后一个报价发亮点 | UIView |      |
	| options    | 其他参数 | NSDictionary |    |
 	
* 其他参数说明:

	| 键值      | 说明         | 型态         | 备注  |
	|-------------|-----------|--------------|------|
	| CUSTOM_DATETIME| 客制日期显示 | NSArray | @[@"09:30", @"11:30/13:00", @"15:00"]|
	| FIVEDAY_LINE_CONTINUOUS | 五日线是否连续 | BOOL | |
	| Y_AXIS_PRICE_LABELS_HIDDEN | Y轴价格Label是否隐藏 | NSArray | @[@YES, @NO, @NO, @YES] |
	| Y_AXIS_UDRATE_LABELS_HIDDEN | Y轴幅度Label是否隐藏 | NSArray |@[@YES, @NO, @NO, @YES] |
	| Y_AXIS_VOLUME_LABELS_HIDDEN | Y轴量Label是否隐藏 | NSArray |@[@YES, @NO, @NO, @YES] |
	| YCLOSE_LINE_COLOR | 昨收线颜色 | UIColor | |
	| YCLOSE_LINE_DASH  | 昨收线实线虚线 | BOOL | @YES|
	| Y_AXIS_UDRATE_LABELS_FORMAT  | Y轴幅度Label正负号 | NSArray | @[@"+%.2f%%", @"+%.2f%%", @"%.2f%%", @"-%.2f%%", @"-%.2f%%"]|
	| Y_AXIS_TICK_SPACING | X轴虚线根数 | NSInteger | @(60)|
	

[top](#top)

<h4 id="MTrendChartViewSample">调用样例</h4>
	// 走势图初始化    MTrendChartView *chartView = [[MTrendChartView alloc] initWithFrame:CGRectZero];
    // 必要属性
    chartView.code = @"000001.sh";
    
    // 订制化属性
    chartView.type = MTrendChartTypeOneDay;
    chartView.yAxisFont = [UIFont boldSystemFontOfSize:17];
    chartView.borderWidth = 5;
    chartView.borderColor = [UIColor whiteColor];
    chartView.insideLineWidth = 2;
    chartView.insideLineColor = [UIColor purpleColor];
    chartView.xAxisFont = [UIFont boldSystemFontOfSize:12.0];
    chartView.xAxisTextColor = [UIColor redColor];
    chartView.priceRiseTextColor = [UIColor yellowColor];
    chartView.priceFlatTextColor = [UIColor greenColor];
    chartView.priceDropTextColor = [UIColor brownColor];
    chartView.volumeTextColor = [UIColor yellowColor];
    chartView.rangeRiseTextColor = [UIColor orangeColor];
    chartView.rangeFlatTextColor = [UIColor purpleColor];
    chartView.rangeDropTextColor = [UIColor redColor];
    chartView.currentLineWidth = 5;
    chartView.currentLineColor = [UIColor blueColor];
    chartView.averageLineColor = [UIColor orangeColor];
    chartView.averageLineWidth = 5;
    chartView.lastBlinkDot = [MChartDotView blinkDot];
    
    [self.view addSubview:chartView];[top](#top)<h3 id="MFundChartView">基金净值走势图：MFundChartView</h3>

<h4 id="MFundChartViewExplain">说明</h4>

* 从服务器取得基金净值信息，并绘制走势图。

<h4 id="MFundChartViewAttribute">属性</h4>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| priceRiseTextColor | 价格涨文字颜色 | UIColor |      |
	| priceFlatTextColor | 价格平盘文字颜色 | UIColor |      |
	| priceDropTextColor | 价格跌文字颜色 | UIColor |      |
	| rangeRiseTextColor | 价格涨幅文字颜色 | UIColor | |
	| rangeFlatTextColor | 价格幅度平盘文字颜色 | UIColor |      |
	| rangeDropTextColor | 价格跌幅文字颜色 | UIColor |      |
	| currentLineColor   | 价格线颜色 | UIColor |      |
	| currentLineWidth   | 价格线宽 | CGFloat |      |
	| gradientColors    | 渐层颜色 | NSArray |      |
	| gradientLocations    | 渐层颜色位置 | CGFloat[] |      |
	| startTime    | 开始时间 | NSString |  @"2016-03-04"    |
	| endTime    | 结束时间 | NSString |   @"2016-03-04"   |

* 方法说明:

	| 方法名      | 说明         | 回调型态         | 备注 |
	|-------------|--------------|--------------|------|
	| getALLFundValue | 获取一年内所有净值信息 | NSArry |  |


<h4 id="MFundChartViewSample">调用样例</h4>
	// 走势图初始化    MFundChartView *chartView = [[MFundChartView alloc] initWithFrame:CGRectZero];
    // 必要属性
    chartView.code = @"502025.sh";
    
    // 订制化属性
    chartView.yAxisFont = [UIFont boldSystemFontOfSize:17];
    chartView.borderWidth = 5;
    chartView.borderColor = [UIColor whiteColor];
    chartView.insideLineWidth = 2;
    chartView.insideLineColor = [UIColor purpleColor];
    chartView.xAxisFont = [UIFont boldSystemFontOfSize:12.0];
    chartView.xAxisTextColor = [UIColor redColor];
    chartView.priceRiseTextColor = [UIColor yellowColor];
    chartView.priceFlatTextColor = [UIColor greenColor];
    chartView.priceDropTextColor = [UIColor brownColor];
    chartView.volumeTextColor = [UIColor yellowColor];
    chartView.rangeRiseTextColor = [UIColor orangeColor];
    chartView.rangeFlatTextColor = [UIColor purpleColor];
    chartView.rangeDropTextColor = [UIColor redColor];
    chartView.currentLineWidth = 5;
    chartView.currentLineColor = [UIColor blueColor];
    chartView.startTime = @"2015-09-10";
    chartView.endTime = @"2016-10-11";
    
    [self.view addSubview:chartView];[top](#top)<h3 id="MOHLCChartView">K线图：MOHLCChartView</h3>

<h4 id="MOHLCChartViewExplain">说明</h4>

* 从服务器取得取得各时间类型数据，如日K、周K、月K...等，并绘制K线图。

<h4 id="MOHLCChartViewAttribute">属性</h4>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| type | K线图类型 | MOHLCChartType | 类型请参考[MOHLCChartType](#MOHLCChartType) |
	| numberOfVisibleRecords   | 设置画面k棒笔数 | NSUInteger |      |
	| majorPlotIndex | 主图当前索引值 | NSUInteger |      |
	| minorPlotIndex | 副图当前索引值 | NSUInteger |      |
	| majorPlotSettingButton | 主图设定按钮 | UIButton |      |
	| majorPlotChangeIndexButton | 主图切换索引按钮 | UIButton | |
	| minorPlotChangeIndexButton | 副图切换索引按钮 | UIButton |      |
	| majorPlots    | 主图plot数组 | NSArray |      |
	| minorPlots   | 副图plot数组 | NSArray |      |
	| barFill   | k棒是否填充 | BOOL |      |
	| scrollEnabled   | 是否可滚动 | BOOL |      |
	| zoomEnabled   | 是否可缩放 | BOOL |      |
	| majorGraphView    | 主图实例 | UIView |      |
	| minorGraphView    | 副图实例 | UIView |      |
	| yAxisTextColor    | y轴文字颜色 | UIColor |      |

* 方法说明:

	| 方法名      | 说明     |  传入参数  | 回调型态         | 备注 |
	|-------------|-------|-------|--------------|------|
	| addMajorPlot: | 加入主图 | (MOHLCPlot *)plot | void |  |
	| addMajorPlots: | 加入主图 | (MOHLCPlot *)plots | void | 以nil结尾 |
	| addMinorPlot: | 加入副图 | (MPlot *)plot | void |  |
	| addMinorPlots: | 加入副图 | (MPlot *)plots | void | 以nil结尾 |


<h4 id="MOHLCChartViewSample">调用样例</h4>
	// K线图初始化    MOHLCChartView *chartView = [[MOHLCChartView alloc] initWithFrame:CGRectZero];
    // 必要属性
    chartView.code = @"600000.sh";
    
    // 线图数据类型
    chartView.type = MOHLCChartTypeDay;
    
    // 订制化属性
    chartView.backgroundColor = [UIColor orangeColor];
    chartView.borderWidth = 5;
    chartView.borderColor = [UIColor brownColor];
    chartView.insideLineColor = [UIColor purpleColor];
    chartView.insideLineWidth = 3;
    chartView.yAxisFont = [UIFont boldSystemFontOfSize:25.0];
    chartView.yAxisTextColor = [UIColor blueColor];
    chartView.xAxisFont = [UIFont boldSystemFontOfSize:25];
    chartView.xAxisTextColor = [UIColor redColor];
    chartView.enquiryFrameColor = [UIColor blueColor];
    chartView.enquiryLineColor = [UIColor orangeColor];
    chartView.enquiryTextColor = [UIColor yellowColor];
    chartView.enquiryTextFont = [UIFont boldSystemFontOfSize:17];
    chartView.barFill = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, 60, 20);
    button.backgroundColor = [UIColor blueColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"设均线" forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(MASettingButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    chartView.majorPlotSettingButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, 60, 20);
    button.backgroundColor = [UIColor yellowColor];
    [button setTitle:@"主图" forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(majorPlotChangeIndexButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    chartView.majorPlotChangeIndexButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, 50, 20);
    button.backgroundColor = [UIColor yellowColor];
    [button setTitle:@"副指标" forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(minorPlotChangeIndexButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    chartView.minorPlotChangeIndexButton = button;
    
    // 设置主图
    MOHLCPlot *plot = [[MOHLCPlot alloc] initWithYAxisLabelCount:5];
    [plot setParameters:5, 10, 15, 20, nil];
    [plot setLineColors:[UIColor whiteColor],
     	[UIColor yellowColor],
     	[UIColor greenColor],
     	[UIColor orangeColor], nil];
    chartView.majorPlots = @[plot];
    
    // 设置副图
    chartView.minorPlots = @[[[MVolumePlot alloc] initWithYAxisLabelCount:5], 
                             [[MRSIPlot alloc] initWithYAxisLabelCount:5], 
                             [[MKDJPlot alloc] initWithYAxisLabelCount:5]];

    [self.view addSubview:chartView];
[top](#top)<h3 id="MPlot">K线图指标：MPlot</h3>

<h4 id="MPlotExplain">说明</h4>

* 此为各个指标父类别，请根据不同指标子类别生成指标实例，并设置MOHLCChartView的majorPlot及minorPlot绘制图形。

<h4 id="MPlotAttribute">属性</h4>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| title | 指标名 | NSString |  |
	| options | 其他参数 | NSDictionary |  |

* 其他参数说明:

	| 键值      | 说明         | 型态         | 备注  |
	|-------------|-----------|--------------|------|
	| Y_AXIS_LABELS_HIDDEN| Y轴Label是否隐藏 | NSArray | @[@YES, @NO, @NO, @YES] |

* 方法说明:

	| 方法名      | 说明     |  传入参数  | 回调型态         | 备注 |
	|-------------|-------|-------|--------------|------|
	| initWithYAxisLabelCount: | 初始化并设置y轴Label个数 | (NSInteger)yAxisLabelCount | instancetype |  |
	| redraw | 重新绘制 |  | void | |
	| setParameters: | 设置参数 | (NSUInteger)param, ... | void | 以nil结尾。参数索引对应请参照各子类别文档 |
	| setParametersFromArray: | 设置参数 | (NSArray *)params | void | 参数索引对应请参照各子类别文档 |
	| setLineColors: | 设置线的颜色 | (UIColor *)color, ... | void | 以nil结尾 |
	| setLineColorsFromArray: | 设置线的颜色 | (NSArray *)colors | void |  |
[top](#top)<h4 id="主图指标">主图指标</h4>
<h5 id="MMAPlot">移动平均线：MMAPlot</h5>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| flatColor | 平盘颜色 | UIColor |  |
	| riseColor | 涨颜色 | UIColor |  |
	| dropColor | 跌颜色 | UIColor |  |
	
* 参数说明:	

	| 参数索引 | 说明     | 默认值            | 备注 |
	|---------|---------|------------------|------|
	| 0~9     | 天数     | 0:6, 1:12, 2:24  |  |
[top](#top)<h5 id="MBOLLPlot">布林线：MBOLLPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 20    |  |
	| 1       | N倍标准差   | 2     |  |
[top](#top)<h4 id="副图指标">副图指标</h4>
<h5 id="MVOLPlot">成交量指标：MVOLPlot</h5>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| flatColor | 平盘颜色 | UIColor |  |
	| riseColor | 涨颜色 | UIColor |  |
	| dropColor | 跌颜色 | UIColor |  |
[top](#top)<h5 id="MRSIPlot">相对强弱指标：MRSIPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 6    |  |
	| 1       | 天数       | 12     |  |
	| 2       | 天数       | 24     |  |
[top](#top)
<h5 id="MKDJPlot">随机指标：MKDJPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 9    |  |
	| 1       | -       | 3     |  |
	| 2       | -       | 3     |  |
[top](#top)
<h5 id="MMACDPlot">指数平滑移动平均：MMACDPlot</h5>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| riseColor | 涨颜色 | UIColor |  |
	| dropColor | 跌颜色 | UIColor |  |

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 短期       | 12    |  |
	| 1       | 长期       | 26     |  |
	| 2       | 天数       | 9     |  |
	[top](#top)<h5 id="MBIASPlot">乖离率指标：MBIASPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 5    |  |
	| 1       | 天数       | 10     |  |
	| 2       | 天数       | 20     |  |

[top](#top)<h5 id="MCCIPlot">顺势指标：MCCIPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 12    |  |
[top](#top)<h5 id="MWRPlot">威廉指标：MWRPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 5    |  |
	| 1       | 天数       | 10     |  |

[top](#top)
<h5 id="MARPlot">人气指标：MARPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 13    |  |
	| 1       | 天数       | 26     |  |

[top](#top)
<h5 id="MBBIPlot">多空指标：MBBIPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 3    |  |
	| 1       | 天数       | 6     |  |
	| 2       | 天数       | 12    |  |
	| 3       | 天数       | 24     |  |

[top](#top)

<h5 id="MBRPlot">意愿指标：MBRPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 13    |  |
	| 1       | 天数       | 26     |  |

[top](#top)<h5 id="MKDPlot">随机指数：MKDPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 9    |  |
[top](#top)
<h5 id="MDMIPlot">动向指标：MDMIPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 14    |  |

[top](#top)
<h5 id="MPSYPlot">心理线指标：MPSYPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 12    |  |
	| 1	       | 天数       | 24    |  |
	[top](#top)

<h5 id="MOBVPlot">能量潮指标：MOBVPlot</h5>

[top](#top)<h5 id="MMTMPlot">动量指标：MMTMPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 12    |  |
	| 1	      | -       | 6    |  |
[top](#top)
<h5 id="MVRPlot">成交量变异率：MVRPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 13    |  |
	| 1	      | 天数       | 26    |  |
[top](#top)
<h5 id="MROCPlot">变动速率指标：MROCPlot</h5>

* 参数说明:	

	| 参数索引 | 说明       | 默认值 | 备注 |
	|---------|-----------|-------|------|
	| 0       | 天数       | 10    |  |
[top](#top)<h5 id="MNVIPlot">负量指标：MNVIPlot</h5>

[top](#top)<h5 id="MPVIPlot">正成交量指标：MPVIPlot</h5>

[top](#top)
<h3 id="MIPOCalendarView">新股日历图：MIPOCalendarView</h3>

<h4 id="MIPOCalendarViewExplain">说明</h4>

* 新股日历列表页面。

<h4 id="MIPOCalendarViewAttribute">属性</h4>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| delegate | 视图代理 | MIPOCalendarViewDelegate | 类型请参考[MIPOCalendarViewDelegate](#MIPOCalendarViewDelegate) |
	| headerTitleColor | section标题文字颜色 | UIColor |      |
	| headerPromptColor | section副标题文字颜色 | UIColor |      |
	| headerTitleFontSize | section标题文字大小 | CGFloat |      |
	| headerPromptFontSize | section副标题文字大小 | CGFloat | |
	| headerBackColor | section背景色 | UIColor |      |
	| separatorClolor | section标题分割线颜色 | UIColor |      |
	| promptSeparatorColor    | section副标题下面的分割线颜色 | UIColor |      |
	| cellTextColor | cell文字颜色 | UIColor |      |
	| cellFontSize | cell文字大小 | CGFloat |      |
	| codeIdColor | 股票代码字体颜色 | UIColor |      |
	| codeIdFontSize | 股票代码字体大小 | CGFloat |      |
	| cellBackColor | cell背景颜色 | UIColor |      |
	| axisHolidayColor | 休息日轴线颜色 | UIColor |      |
	| axisWorkdayColor | 工作日轴线颜色 | UIColor |      |
	| axisSelectColor | 当前选择日期轴线颜色 | UIColor |      |
	| axisLineWidth | 轴线宽度 | CGFloat |      |
	| axisArcRadius | 圆的半径 | CGFloat |      |
	| axisBackColor | 滚动轴背景色 | UIColor |      |
	| dateTextColor | 日期文字颜色 | UIColor |      |
	| dateTextFontSize | 日期字体大小 | CGFloat |      |
	| promptTextColor | 提示消息文字颜色 | UIColor |      |
	| promptTextFontSize | 提示消息文字大小 | CGFloat |      |
	| noDataMessageColor | “暂无数据” 提示文字颜色 | UIColor |      |
	| scrollDirection | 点击日期后的滚动方向 | MIPOCalendarViewScrollDirection |  类型请参考[MIPOCalendarViewScrollDirection](#MIPOCalendarViewScrollDirection)    |
* 方法说明:

	| 方法名      | 说明     |  传入参数  | 回调型态         | 备注 |
	|-------------|-------|-------|--------------|------|
	| loadData | 加载数据 | 无 | 无 |  |


<h4 id="MIPOCalendarViewSample">调用样例</h4>  

	- (void)viewDidLoad {
    	[super viewDidLoad];
	    self.title = @"新股日历";
	    self.view.backgroundColor = [UIColor blackColor];
	    stockView = [[MIPOCalendarView alloc]init];
	    stockView.separatorClolor = [UIColor colorWithRed:20.0/255.0 green:34.0/255.0 blue:50.0/255.0 alpha:1];
	    stockView.headerBackColor = [UIColor colorWithRed:17.0/255.0 green:24.0/255.0 blue:30.0/255.0 alpha:1];
	    stockView.headerTitleColor = [UIColor colorWithRed:61.0/255.0 green:118.0/255.0 blue:148.0/255.0 alpha:1];
	    stockView.headerPromptColor = [UIColor grayColor];
	    stockView.promptSeparatorColor = [UIColor colorWithRed:24./255. green:29./255. blue:33./255. alpha:1];
	    stockView.cellBackColor = [UIColor colorWithRed:16.0/255.0 green:20.0/255.0 blue:25.0/255.0 alpha:1];
	    stockView.cellTextColor = [UIColor whiteColor];
	    stockView.codeIdColor = [UIColor colorWithRed:105.0/255.0 green:113.0/255.0 blue:118.0/255.0 alpha:1];
	    stockView.axisHolidayColor = [UIColor lightGrayColor];
	    stockView.axisWorkdayColor = [UIColor whiteColor];
	    stockView.axisSelectColor = [UIColor redColor];
	    stockView.dateTextColor = [UIColor whiteColor];
	    stockView.promptTextColor = [UIColor lightGrayColor];
	    stockView.axisBackColor = [UIColor colorWithRed:16.0/255.0 green:20.0/255.0 blue:25.0/255.0 alpha:1];
	
	    stockView.delegate = self;
	    [self.view addSubview:stockView];
	    [stockView loadData];
	}[top](#top)

<h3 id="MIPODetailView">新股日历详情视图：MIPODetailView</h3>

<h4 id="MIPODetailViewExplain">说明</h4>

* 新股日历详情页面。

<h4 id="MIPODetailViewAttribute">属性</h4>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| delegate | 视图代理 | MIPODetailViewDelegate | 类型请参考[MIPODetailViewDelegate](#MIPODetailViewDelegate) |
	| sectionHeaderSeparatorColor | section header 的分割线颜色 | UIColor |      |
	| sectionHeaderHeight | section header 高度 | CGFloat |      |
	| sectionHeaderBackgroundColor | section header 背景色 | UIColor |      |
	| sectionHeaderFontSize | section header 文字大小 | CGFloat | |
	| sectionHeaderTextColor | section header 文字颜色 | UIColor |      |
	| cellNameTextColor | cell右边标题文字颜色 | UIColor |      |
	| cellNameTextFontSize    | cell右边标题文字大小 | CGFloat |      |
	| cellValueTextColor | cell左边详情文字颜色 | UIColor |      |
	| cellValueTextFontSize | cell左边详情文字大小 | CGFloat |      |
	| clickedTextColor | 可点击的股票名称文字颜色 | UIColor |      |
	| cellBackColor | cell背景颜色 | UIColor |      |
	
* 方法说明:

	| 方法名      | 说明     |  传入参数  | 回调型态         | 备注 |
	|-------------|-------|-------|--------------|------|
	| loadDataWithCode: | 加载数据 | 股票代码 | 无 |  |


<h4 id="MIPODetailViewSample">调用样例</h4>  

	- (void)viewDidLoad {
	    [super viewDidLoad];
	    self.view.backgroundColor = [UIColor blackColor];
	    detailView = [[MIPODetailView alloc]init];
	    detailView.sectionHeaderSeparatorColor     = [UIColor colorWithRed:20.0/255.0 green:34.0/255.0 blue:50.0/255.0 alpha:1];
	    detailView.sectionHeaderBackgroundColor    = [UIColor colorWithRed:17.0/255.0 green:24.0/255.0 blue:30.0/255.0 alpha:1];
	    detailView.sectionHeaderTextColor    = [UIColor colorWithRed:61.0/255.0 green:118.0/255.0 blue:148.0/255.0 alpha:1];
	    
	    
	    detailView.cellNameTextColor = [UIColor grayColor];
	    detailView.cellValueTextColor = [UIColor whiteColor];
	    detailView.clickedTextColor = [UIColor colorWithRed:61.0/255.0 green:118.0/255.0 blue:148.0/255.0 alpha:1];
	    detailView.cellBackColor = [UIColor blackColor];
	    detailView.delegate = self;
	    [self.view addSubview:detailView];
	    [detailView loadDataWithCode:self.code];
    
	}[top](#top)<h3 id="MTopPriceDetailView">五档明细视图：MTopPriceDetailView</h3>

<h4 id="MTopPriceDetailViewExplain">说明</h4>

* 五档明细视图。

<h4 id="MTopPriceDetailViewAttribute">属性</h4>

* 属性说明:

	| 属性名      | 说明         | 型态         | 备注 |
	|-------------|--------------|--------------|------|
	| code | 股号 | NSString |  |
	| segmentBorderColor | segment边框颜色 | UIColor |      |
	| segmentFont | segment字体 | UIFont |      |
	| segmentBackgroundColor | segment背景色 | UIColor |      |
	| segmentSelectedBackgroundColor | segment选择时背景色 | UIColor | |
	| segmentTextColor | segment文字颜色 | UIColor |      |
	| segmentSelectedTextColor | segment选择时文字颜色 | UIColor |      |
	| segmentHeight | segment高度 | CGFloat |      |
	| riseTextColor | 涨文字色 | UIColor |      |
	| dropTextColor | 跌文字色 | UIColor |      |
	| flatTextColor | 平盘文字色 | UIColor |      |
	| volumeTextColor | 量文字色 | UIColor |      |
	| textColor | 通用文字色 | UIColor |      |
	| textFont | 通用字体 | UIFont |      |	
* 方法说明:

	| 方法名      | 说明     |  传入参数  | 回调型态         | 备注 |
	|-------------|-------|-------|--------------|------|
	| reloadData | 请求数据并刷新 | | 无 |  |


<h4 id="MTopPriceDetailViewSample">调用样例</h4>  

	- (void)viewDidLoad {
	    [super viewDidLoad];
	    self.view.backgroundColor = [UIColor blackColor];
    	_topPriceDetailView = [[MTopPriceDetailView alloc] initWithFrame:self.view.bounds];
    	_topPriceDetailView.code = @"600919.sh";
    	_topPriceDetailView.volumeTextColor = [UIColor yellowColor];
    	[self.view addSubview:_topPriceDetailView];
	}[top](#top)
<h2 id="其他">其他</h2>

<h3 id="MTrendChartType">走势图类型(MTrendChartType)</h3>| 名称                 | 说明     | 备注 |
|----------------------|----------|------|
| MTrendChartTypeOneDay   | 分时 |      |
| MTrendChartTypeFiveDays    | 五日 |      |
[top](#top)
<h3 id="MOHLCChartType">K线图类型(MOHLCChartType)</h3>| 名称                     | 说明     | 备注 |
|--------------------------|----------|------|
| MOHLCChartTypeDay      | 日线 |      |
| MOHLCChartTypeWeek     | 周线 |      |
| MOHLCChartTypeMonth    | 月线 |      |
| MOHLCChartTypeMin5     | 5分钟线 |      |
| MOHLCChartTypeMin15    | 15分钟线 |      |
| MOHLCChartTypeMin30    | 30分钟线   |      |
| MOHLCChartTypeMin60    | 60分钟线 |      |
| MOHLCChartTypeMin120   | 120分钟线 |      |
[top](#top)<h3 id="MChartEnquiryLineMode">查价线模式类型(MChartEnquiryLineMode)</h3>| 名称                 | 说明     | 备注 |
|----------------------|----------|------|
| MChartEnquiryLineModeNone   | y轴线自由移动 |     |
| MChartEnquiryLineModeSticky    | y轴线绘制在当前所查的价格座标上 |  默认值  |
| MChartEnquiryLineModeNotToDisappear    | 查价线出现后不消失 |    |
| MChartEnquiryLineModeDelayDisappear    | 查价线出现后延迟消失 |    |
| MChartEnquiryLineModeAppearImmediately    | 查价线点击立即出现 |    |
[top](#top)
<h3 id="MIPOCalendarViewScrollDirection">新股日历轴线滚动方向(MIPOCalendarViewScrollDirection)</h3>| 名称                 | 说明     | 备注 |
|----------------------|----------|------|
| MIPOCalendarViewScrollDirectionLeft   | 选中日期滚动到左边 |   默认值   |
| MIPOCalendarViewScrollDirectionMiddle    | 选中日期滚动到中间 |      |
| MIPOCalendarViewScrollDirectionRight    | 选中日期滚动到右边 |      |
[top](#top)
<h3 id="MIPOCalendarViewDelegate">新股日历视图代理(MIPOCalendarViewDelegate)</h3>* 方法说明
	| 方法名      | 说明     |  传入参数  | 回调型态         | 备注 |
	|-------------|-------|-------|--------------|------|
	| IPODetailView: didSelectStockWithCode: | 点击股票名称事件回调 | 股票代码 |  | 可选方法 |
	| IPODetailViewWillGetData: | 将要获取数据时调用 |  |  | 可选方法 |
	| IPODetailViewDidEndGetData: | 获取数据完成后调用 |  |  | 可选方法 | 
[top](#top)
<h3 id="MIPODetailViewDelegate">新股日历详情视图代理(MIPODetailViewDelegate)</h3>* 方法说明
	| 方法名      | 说明     |  传入参数  | 回调型态         | 备注 |
	|-------------|-------|-------|--------------|------|
	| IPOCalendarView: didSelectStockWithCode: andName: | 点击股票事件回调 | 股票代码,股票名称 |  | 可选方法 |
	| IPOCalendarViewWillGetData: | 将要获取数据时调用 |  |  | 可选方法 |
	| IPOCalendarViewDidEndGetData: | 获取数据完成后调用 |  |  | 可选方法 |
[top](#top)