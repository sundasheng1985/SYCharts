//
//  MCategorySortingRequest.h
//  MAPI
//
//  Created by FanChiangShihWei on 2016/5/23.
//  Copyright © 2016年 Mitake. All rights reserved.
//

#import "MRequest.h"

//排序栏位，因应标准版(???)需求，多一些复杂的排序功能，因此此API，你开心用哪个栏位排序就用哪一个，但是其中
//18 均价, 33 五档买价, 34 五档买量, 35	五档卖价, 36 五档卖量, 26 总值, 29 PE(市盈),30 ROE(净资产收益率) 这几个栏位并不会进行排序。

//@{@"key": @"tempStatus", @"type": @"string", @"encrypt": @(NO)},    //0
//@{@"key": @"ID", @"type": @"string", @"encrypt": @(NO)},            //1
//@{@"key": @"name", @"type": @"string", @"encrypt": @(NO)},          //2
//@{@"key": @"datetime", @"type": @"string", @"encrypt": @(YES)},      //3
//@{@"key": @"pinyin", @"type": @"string", @"encrypt": @(NO)},        //4
//@{@"key": @"market", @"type": @"string", @"encrypt": @(NO)},        //5
//@{@"key": @"subtype", @"type": @"string", @"encrypt": @(NO)},       //6
//@{@"key": @"lastPrice", @"type": @"string", @"encrypt": @(YES)},    //7
//@{@"key": @"highPrice", @"type": @"string", @"encrypt": @(YES)},     //8
//@{@"key": @"lowPrice", @"type": @"string", @"encrypt": @(YES)},      //9
//@{@"key": @"openPrice", @"type": @"string", @"encrypt": @(YES)},     //10
//@{@"key": @"preClosePrice", @"type": @"string", @"encrypt": @(YES)}, //11
//@{@"key": @"changeRate", @"type": @"string", @"encrypt": @(YES)},    //12
//@{@"key": @"volume", @"type": @"string", @"encrypt": @(YES)},        //13
//@{@"key": @"nowVolume", @"type": @"string", @"encrypt": @(YES)},     //14
//@{@"key": @"turnoverRate", @"type": @"string", @"encrypt": @(YES)},  //15
//@{@"key": @"limitUp", @"type": @"string", @"encrypt": @(YES)},       //16
//@{@"key": @"limitDown", @"type": @"string", @"encrypt": @(YES)},     //17
//@{@"key": @"averageValue", @"type": @"string", @"encrypt": @(YES)},  //18
//@{@"key": @"change", @"type": @"string", @"encrypt": @(YES)},        //19
//@{@"key": @"amount", @"type": @"string", @"encrypt": @(YES)},        //20
//@{@"key": @"volumeRatio", @"type": @"string", @"encrypt": @(YES)},   //21
//@{@"key": @"buyPrice", @"type": @"string", @"encrypt": @(YES)},      //22
//@{@"key": @"sellPrice", @"type": @"string", @"encrypt": @(YES)},     //23
//@{@"key": @"buyVolume", @"type": @"string", @"encrypt": @(YES)},     //24
//@{@"key": @"sellVolume", @"type": @"string", @"encrypt": @(YES)},    //25
//@{@"key": @"totalValue", @"type": @"string", @"encrypt": @(YES)},    //26
//@{@"key": @"flowValue", @"type": @"string", @"encrypt": @(YES)},     //27
//@{@"key": @"netAsset", @"type": @"string", @"encrypt": @(NO)},      //28
//@{@"key": @"PE", @"type": @"string", @"encrypt": @(YES)},            //29
//@{@"key": @"ROE", @"type": @"string", @"encrypt": @(YES)},           //30
//@{@"key": @"capitalization", @"type": @"string", @"encrypt": @(YES)},//31
//@{@"key": @"circulatingShare", @"type": @"string", @"encrypt": @(YES)},//32
//@{@"key": @"buyPrices", @"type": @"prices", @"encrypt": @(YES)},     //33
//@{@"key": @"buyVolumes", @"type": @"volumes", @"encrypt": @(YES)},   //34
//@{@"key": @"sellPrices", @"type": @"prices", @"encrypt": @(YES)},    //35
//@{@"key": @"sellVolumes", @"type": @"volumes", @"encrypt": @(YES)},  //36
//@{@"key": @"amplitudeRate", @"type": @"string", @"encrypt": @(YES)}, //37
//@{@"key": @"receipts", @"type": @"string", @"encrypt": @(NO)}       //38


@interface MCategorySortingRequest()

@end
