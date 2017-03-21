
#import <XCTest/XCTest.h>
#import "MApiHelper.h"
#import "MApi.h"
#import "MGetServerRequest.h"



#define MAPI_TEST_CONFIG_TEST_RANKING_REQUEST 0

//static NSString *kUnitTestBundleID = @"com.foundersc.square";
//static NSString *kUnitTestAppKey = @"b/ekxNm958trmyVZcYtHUD3XHu9v2hPynvXJHELbBJc=";

static NSString *kUnitTestBundleID = @"com.mitake.dev.CrystalTouch";
static NSString *kUnitTestAppKey = @"8B9mlW1EC0oeg6JjBH3xjwrLSzXak9dPjobCBVnX2Ac=";


static NSString *kUnitTestCorpID = @"168";
static NSString *kUnitTestVersion = @"0";


@interface MApiTests : XCTestCase

@end

@implementation MApiTests

- (void)setUp {
    [super setUp];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MApi setDebugMode:@{@"token":@"|F)w*7sYaoIdM+!#8d10LsT#0x|cA.xX/a@;a~",
                             @"enabled":@YES,
                             @"mode":@3}];

        NSString *eString = [NSString stringWithFormat:@"注册%@", kUnitTestAppKey];
        __block XCTestExpectation *expectation = [self expectationWithDescription:eString];
        [MApiHelper sharedHelper].corpID = kUnitTestCorpID;
        [MApiHelper sharedHelper].unitTest_bundleID = kUnitTestBundleID;
        [MApiHelper sharedHelper].unitTest_version = kUnitTestVersion;

//        NSDictionary *options = nil;
        NSDictionary *options = @{@"MAPI_DEBUG_AUTH_SERVERS":@[@"http://114.80.155.134:22016"],
                                  @"MAPI_DEBUG_QUOTE_SERVERS":@{
                                          @"pb":@[@{@"ip":@"http://mtk01.mitake.com.cn"}],
                                          @"sh":@[@{@"ip":@"http://114.80.155.61:22016"}],
                                          @"shl2":@[@{@"ip":@"http://114.80.155.61:22016"}],
                                          @"hk":@[@{@"ip":@"http://114.80.155.61:22016"}],
                                          @"hkl2":@[@{@"ip":@"http://114.80.155.61:22016"}],
                                          @"sz":@[@{@"ip":@"http://114.80.155.61:22016"}],
                                          @"szl2":@[@{@"ip":@"http://114.80.155.61:22016"}],
                                          @"nf":@[@{@"ip":@"http://114.80.155.58:22013"}
                                          /*@"nf":@[@{@"ip":@"http://f10.mitake.com.cn:19888"}*/]
                                          }
                                  };
//        NSDictionary *options = @{@"MAPI_DEBUG_AUTH_SERVERS":@[@"http://114.80.155.61:22016"]};
        
        [MApi registerAPP:kUnitTestAppKey
              withOptions:options
              sourceLevel:MApiSourceLevel2
        completionHandler:^(NSError *error) {
            XCTAssertNil(error, @"%@", [error localizedDescription]);
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:10 handler:NULL];
    });
}

- (void)tearDown {
    [super tearDown];
}


#pragma mark test start
- (void)testRegiserApp {
    
}

- (void)testSendRequest {
    [MApi sendRequest:nil completionHandler:nil];
    [MApi sendRequest:[[MQuoteRequest alloc] init] completionHandler:nil];
}

- (void)testMGetSourceRequest {
    __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    //获取资讯源类别
    MGetSourceRequest *request = [[MGetSourceRequest alloc] init];
    
    //发送请求
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
        NSLog(@"%@", resp);
        [e fulfill]; e = nil;
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 获取行情分类
- (void)testMGetSourceClassRequest {
    __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    MGetSourceClassRequest *request = [[MGetSourceClassRequest alloc] init];
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
        NSLog(@"%@", resp);
        [e fulfill]; e = nil;
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求主选单功能列表
- (void)testMGetMenuRequest {
    __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    MGetMenuRequest *request = [[MGetMenuRequest alloc] init];
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
        NSLog(@"%@", resp);
        [e fulfill]; e = nil;
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求广告资讯
- (void)testMAdvertRequest {
    __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    MAdvertRequest *request = [[MAdvertRequest alloc] init];
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
        NSLog(@"%@", resp);
        [e fulfill]; e = nil;
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 获取公告
- (void)testMAnnouncementRequest {
    __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    MAnnouncementRequest *request = [[MAnnouncementRequest alloc] init];
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
        NSLog(@"%@", resp);
        [e fulfill]; e = nil;
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求股票行情
- (void)testMQuoteRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MQuoteRequest *r = [[MQuoteRequest alloc] init];
        r.code = @"000001.sh,600004.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MQuoteRequest *r = [[MQuoteRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MQuoteRequest *r = [[MQuoteRequest alloc] init];
        r.code = @"jaslkdfj983ur892jfcmwd";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MQuoteRequest *r = [[MQuoteRequest alloc] init];
        r.code = @"";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }

    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求快照行情
- (void)testMSnapQuoteRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MSnapQuoteRequest *r = [[MSnapQuoteRequest alloc] init];
        r.code = @"600000.sh";//600000.sh、01316.hk、000001.sz
//        r.type = MSnapQuoteRequestType1;//MSnapQuoteRequestType1、MSnapQuoteRequestType5、MSnapQuoteRequestType10
//        r.tickCount = 50;//0、10、50
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            
            [e fulfill]; e = nil;
        }];
    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MSnapQuoteRequest *r = [[MSnapQuoteRequest alloc] init];
//        r.code = @"00981.hk";//01316.hk
//        r.type = MSnapQuoteRequestType10;
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            
//            [e fulfill]; e = nil;
//        }];
//    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MSnapQuoteRequest *r = [[MSnapQuoteRequest alloc] init];
//        r.code = @"00001fdfdas";
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MSnapQuoteRequest *r = [[MSnapQuoteRequest alloc] init];
//        r.code = nil;
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求板块排行
- (void)testMSectionRankingRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MSectionRankingRequest *r = [[MSectionRankingRequest alloc] init];
        r.code = @"allstocks";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            MSectionRankingResponse *response = (MSectionRankingResponse *)resp;
            XCTAssert(response.sectionRankingItems, @"response.sectionRankingItems shound not be nil;");
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MSectionRankingRequest *r = [[MSectionRankingRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MSectionRankingRequest *r = [[MSectionRankingRequest alloc] init];
        r.code = @"000001sdfsdfsdf";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MSectionRankingRequest *r = [[MSectionRankingRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}


#pragma mark - 请求板块排行 sorting
- (void)testMSectionSortingRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MSectionSortingRequest *r = [[MSectionSortingRequest alloc] init];
        r.code = @"Notion";
        r.pageSize = 20;
        r.field = MSectionSortingFieldAdvanceAndDeclineCount;
        r.ascending = YES;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            MSectionSortingResponse *response = (MSectionSortingResponse *)resp;
            
            XCTAssert(response.sectionSortingItems, @"response.sectionSortingItems shound not be nil;");
            NSLog(@"%@", response.sectionSortingItems);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求板块类别个股即時列表
- (void)testMCategoryQuoteListRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCategoryQuoteListRequest *request = [[MCategoryQuoteListRequest alloc] init];
        request.categoryID = @"";
        request.pageIndex = -11232;
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCategoryQuoteListRequest *request = [[MCategoryQuoteListRequest alloc] init];
        request.categoryID = nil;
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCategoryQuoteListRequest *request = [[MCategoryQuoteListRequest alloc] init];
        request.categoryID = @"fsafsdfsda";
        request.pageIndex = -112322;
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求排行数据
#if MAPI_TEST_CONFIG_TEST_RANKING_REQUEST
enum { Rise, Drop };
static NSInteger numberOfPages;
static NSInteger pageIndex;
static NSInteger counter;
static NSMutableArray *categoryIDs;
static MStockItem *compareValue = nil;
- (void)ranking_init {
    numberOfPages = -1; pageIndex = 0; counter = 0;
    categoryIDs = [@[@"allstocks", @"SHSZTurnoverRate", @"SHSZAmp", @"SHSZTurnover", @"SHSZVolumeRatio"] mutableCopy];
}

- (void)recusiveCheckRanking:(XCTestExpectation *)e type:(NSInteger)type {
    static NSDictionary *valueMaps;
    if (!valueMaps) {
        valueMaps = @{@"allstocks":@"changeRate",
                      @"SHSZTurnoverRate":@"turnoverRate",
                      @"SHSZAmp":@"amplitudeRate",
                      @"SHSZTurnover":@"amount",
                      @"SHSZVolumeRatio": @"volumeRatio"};
    }
    NSString *code = [categoryIDs firstObject];
    if (code == nil) {
        [e fulfill]; return;
    }
    
    MRequest *request;
    if (type == Drop) {
        MFallRankingRequest *r =[[MFallRankingRequest alloc] init];
        r.code = code;
        r.pageIndex = pageIndex;
        r.pageSize = 100;
        request = r;
    } else {
        MRiseRankingRequest *r =[[MRiseRankingRequest alloc] init];
        r.code = code;
        r.pageIndex = pageIndex;
        r.pageSize = 100;
        request = r;
    }
    
    [MApi sendRequest:request completionHandler:^(MResponse *resp) {
        MFallRankingResponse *response = (MFallRankingResponse *)resp;
        XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
        
        if (numberOfPages < 0) numberOfPages = response.numberOfPages;
        for (MStockItem *st in response.stockItems) {
            if (compareValue == nil) {
                compareValue = st; counter++;
                continue;
            }
            NSString *kvc_key = valueMaps[code];
            if (type == Drop) {
                XCTAssertTrue([[compareValue valueForKey:kvc_key] doubleValue] <= [[st valueForKey:kvc_key] doubleValue],
                              @"跌幅榜(%@) failed with: %zd.%@(%@)-%f <= %zd.%@(%@)-%f", code,
                              counter-1, compareValue.name, compareValue.ID, [[compareValue valueForKey:kvc_key] doubleValue],
                              counter, st.name, st.ID, [[st valueForKey:kvc_key] doubleValue]);
            } else {
                XCTAssertTrue([[compareValue valueForKey:kvc_key] doubleValue] >= [[st valueForKey:kvc_key] doubleValue],
                              @"涨幅榜(%@) failed with: %zd.%@(%@)-%f >= %zd.%@(%@)-%f", code,
                              counter-1, compareValue.name, compareValue.ID, [[compareValue valueForKey:kvc_key] doubleValue],
                              counter, st.name, st.ID, [[st valueForKey:kvc_key] doubleValue]);
            }
            compareValue = st; counter++;
        }
        if (pageIndex < numberOfPages) {
            pageIndex++;
        } else {
            compareValue = nil;
            numberOfPages = -1; pageIndex = 0; counter = 0;
            [categoryIDs removeObjectAtIndex:0];
        }
        [self recusiveCheckRanking:e type:type];
    }];
}

- (void)testMRiseRankingRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MRiseRankingRequest *r =[[MRiseRankingRequest alloc] init];
        r.code = @"SH1001";
        r.pageIndex = 0;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MRiseRankingRequest *r =[[MRiseRankingRequest alloc] init];
        r.code = @"SH1001";
        r.pageIndex = 0;
        r.pageSize = 20;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MRiseRankingRequest *r =[[MRiseRankingRequest alloc] init];
        r.code = @"gsgw35hbdfs";
        r.pageIndex = -23932312;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MRiseRankingRequest *r =[[MRiseRankingRequest alloc] init];
        r.code = @"gsgw35hbdfs";
        r.pageIndex = 0;
        r.pageSize = -238743;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MRiseRankingRequest *r =[[MRiseRankingRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        [self ranking_init];
        [self recusiveCheckRanking:e type:Rise];
    }
    [self waitForExpectationsWithTimeout:10000 handler:NULL];
}


- (void)testMFallRankingRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFallRankingRequest *request =[[MFallRankingRequest alloc] init];
        request.code = @"allstocks";
        request.pageIndex = 0;
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFallRankingRequest *request =[[MFallRankingRequest alloc] init];
        request.code = @"allstocks";
        request.pageIndex = 0;
        request.pageSize = 20;
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFallRankingRequest *request =[[MFallRankingRequest alloc] init];
        request.code = @"dfag43rhebf";
        request.pageIndex = -139783;
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFallRankingRequest *request =[[MFallRankingRequest alloc] init];
        request.code = @"dfag43rhebf";
        request.pageIndex = 0;
        request.pageSize = -29348294;
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFallRankingRequest *request =[[MFallRankingRequest alloc] init];
        request.code = nil;
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        [self ranking_init];
        [self recusiveCheckRanking:e type:Drop];
    }
    [self waitForExpectationsWithTimeout:10000 handler:NULL];
}
#endif

#pragma mark - 请求排行数据
- (void)__checkSortingStockItems:(NSArray *)sortingStockItems field:(MCategorySortingField)field ascending:(BOOL)ascending includeSuspension:(BOOL)includeSuspension {
    static NSString *map[] = {
        [MCategorySortingFieldID] = @"ID",
        [MCategorySortingFieldLastPrice] = @"lastPrice",
        [MCategorySortingFieldName] = @"name",
        [MCategorySortingFieldOpenPrice] = @"openPrice"
    };
    

    NSInteger _idx = 0;
    for (MStockItem *st in sortingStockItems) {
        NSString *string = [st valueForKey:map[field]];
        for (NSInteger idx = (_idx + 1); idx < sortingStockItems.count; idx++) {
            MStockItem *comparisonSt = sortingStockItems[idx];
            NSString *comparisonString = [comparisonSt valueForKey:map[field]];
//            XCTAssertNotNil(string);
//            XCTAssertNotNil(comparisonString);
            XCTAssertFalse(!includeSuspension && st.status != MStockStatusNormal, @"includeSuspension(%@), but status(%zd)", includeSuspension?@"YES":@"NO", st.status);
            NSComparisonResult ret = [string compare:comparisonString options:NSNumericSearch];
            NSLog(@" COMPARE(%zd): %@  %@",ret, string, comparisonString);

            if (ret == NSOrderedSame) {
                
            }
            else if (ascending) {
                XCTAssertFalse(ret != NSOrderedAscending, @"request is ascending, but result %@ compare to %@ is not.", string, comparisonString);
            } else {
                XCTAssertFalse(ret != NSOrderedDescending, @"request is descending, but result %@ compare to %@ is not.", string, comparisonString);
            }
        }
        NSLog(@"------------");
        _idx++;
    }
}

- (void)testMCategorySortingRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCategorySortingRequest *request =[[MCategorySortingRequest alloc] init];
        request.code = @"SH1001";
        request.pageIndex = 0;
        request.pageSize = 100;
        request.field = MCategorySortingFieldLastPrice;
        request.ascending = YES;
        request.includeSuspension = NO;
        
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            
            MCategorySortingResponse *r = (MCategorySortingResponse *)resp;
            XCTAssertNotNil(r.stockItems);
            [self __checkSortingStockItems:r.stockItems field:request.field ascending:request.ascending includeSuspension:request.includeSuspension];
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCategorySortingRequest *request =[[MCategorySortingRequest alloc] init];
        request.code = @"SH1001";
        request.pageIndex = 0;
        request.pageSize = 100;
        request.field = MCategorySortingFieldLastPrice;
        request.ascending = NO;
        request.includeSuspension = NO;
        
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            
            MCategorySortingResponse *r = (MCategorySortingResponse *)resp;
            XCTAssertNotNil(r.stockItems);
            [self __checkSortingStockItems:r.stockItems field:request.field ascending:request.ascending includeSuspension:request.includeSuspension];
            [e fulfill]; e = nil;
        }];
    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MFallRankingRequest *request =[[MFallRankingRequest alloc] init];
//        request.code = @"allstocks";
//        request.pageIndex = 0;
//        request.pageSize = 20;
//        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MFallRankingRequest *request =[[MFallRankingRequest alloc] init];
//        request.code = @"dfag43rhebf";
//        request.pageIndex = -139783;
//        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MFallRankingRequest *request =[[MFallRankingRequest alloc] init];
//        request.code = @"dfag43rhebf";
//        request.pageIndex = 0;
//        request.pageSize = -29348294;
//        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MFallRankingRequest *request =[[MFallRankingRequest alloc] init];
//        request.code = nil;
//        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}


#pragma mark - 请求当日走势
- (void)testMChartRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MChartRequest *r = [[MChartRequest alloc] init];
        r.code = @"000001.sh";
        r.subtype = @"1400";
        r.chartType = MChartTypeOneDay;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MChartRequest *r = [[MChartRequest alloc] init];
        r.code = @"afsdpjasfjds";
        r.chartType = 2103982;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusParameterError, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MChartRequest *r = [[MChartRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusParameterError, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求K线数据
- (void)testMOHLCRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOHLCRequest *r = [[MOHLCRequest alloc] init];
        r.code = @"000001.sh";
        r.period = MOHLCPeriodDay;
        r.subtype = @"1400";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOHLCRequest *r = [[MOHLCRequest alloc] init];
        r.code = @"000001.sh";
        r.period = MOHLCPeriodWeek;
        r.subtype = @"1400";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOHLCRequest *r = [[MOHLCRequest alloc] init];
        r.code = @"000001.sh";
        r.period = MOHLCPeriodMonth;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusParameterError, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOHLCRequest *r = [[MOHLCRequest alloc] init];
        r.code = @"000001.sh";
        r.period = 4124521;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusParameterError, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOHLCRequest *r = [[MOHLCRequest alloc] init];
        r.code = @"fjdsailfjsdafds";
        r.period = MOHLCPeriodDay;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusParameterError, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOHLCRequest *r = [[MOHLCRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusParameterError, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求经纪席位买
- (void)testMBrokerSeatRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBrokerSeatRequest *r = [[MBrokerSeatRequest alloc] init];
        r.code = @"00699.hk";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBrokerSeatRequest *r = [[MBrokerSeatRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBrokerSeatRequest *r = [[MBrokerSeatRequest alloc] init];
        r.code = @"dfawfdafsa";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusParameterError, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBrokerSeatRequest *r = [[MBrokerSeatRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusParameterError, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 股票查询
- (void)testMSearchRequestLocal {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        [MApi downloadStockTableWithCompletionHandler:^(NSError *error) {
            XCTAssertNil(error, @"download stock table error");
            MSearchRequest *r = [[MSearchRequest alloc] init];
            r.keyword = @"1";
            r.searchLocal = YES;
            r.market = @"sh";
            r.subtype = @"1001";
//            
//            r.markets = @[@"sh"];
//            r.subtypes = @[@"1001"];
            [MApi sendRequest:r completionHandler:^(MResponse *resp) {
                NSLog(@"%@", resp);
                XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
                [e fulfill]; e = nil;
            }];
        }];
        
    }
    [self waitForExpectationsWithTimeout:60 handler:NULL];
}
- (void)testMSearchRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MSearchRequest *r = [[MSearchRequest alloc] init];
        r.keyword = @"000001";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MSearchRequest *r = [[MSearchRequest alloc] init];
        r.keyword = @"asdfsdfafdasf";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MSearchRequest *r = [[MSearchRequest alloc] init];
        r.keyword = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:60 handler:NULL];
}

#pragma mark - 请求期权标的证劵
- (void)testMUnderlyingStockRequest {
    __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    MUnderlyingStockRequest *r =[[MUnderlyingStockRequest alloc] init];
    [MApi sendRequest:r completionHandler:^(MResponse *resp) {
        XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
        [e fulfill]; e = nil;
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}


#pragma mark - 期权-交割月列表
- (void)testMExpireMonthRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MExpireMonthRequest *r = [[MExpireMonthRequest alloc] init];
        r.stockID = @"510050.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MExpireMonthRequest *r = [[MExpireMonthRequest alloc] init];
        r.stockID = @"fslakdjflsadfew";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MExpireMonthRequest *r = [[MExpireMonthRequest alloc] init];
        r.stockID = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

- (void)testMOptionRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOptionRequest *r =[[MOptionRequest alloc] init];
        r.stockID = @"510050.sh";
        r.optionType = MOptionTypeCall;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOptionRequest *r =[[MOptionRequest alloc] init];
        r.stockID = @"510050.sh";
        r.optionType = MOptionTypePut;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOptionRequest *r =[[MOptionRequest alloc] init];
        r.stockID = @"510050.sh";
        r.optionType = MOptionTypeUnknown;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOptionRequest *r =[[MOptionRequest alloc] init];
        r.stockID = @"510050.sh";
        r.optionType = 32409;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOptionRequest *r =[[MOptionRequest alloc] init];
        r.stockID = @"fadg3h35";
        r.optionType = 342848237;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

- (void)testMOptionTRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOptionTRequest *r = [[MOptionTRequest alloc] init];
        r.stockID = @"510050.sh";
        r.expireMonth = @"1603";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOptionTRequest *r = [[MOptionTRequest alloc] init];
        r.stockID = @"510050.sh";
        r.expireMonth = @"fasdfwe";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOptionTRequest *r = [[MOptionTRequest alloc] init];
        r.stockID = @"510050.sh";
        r.expireMonth = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOptionTRequest *r = [[MOptionTRequest alloc] init];
        r.stockID = @"43rf4gev";
        r.expireMonth = @"r4fevd";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOptionTRequest *r = [[MOptionTRequest alloc] init];
        r.stockID = nil;
        r.expireMonth = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - ##########################
#pragma mark - 请求个股最新指标
- (void)testMLatestIndexRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MLatestIndexRequest *r = [[MLatestIndexRequest alloc] init];
        r.code = @"600000.sh";
        r.sourceType = MF10DataSourceGA;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"最新指标：%@",((MLatestIndexResponse*)resp).record);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MLatestIndexRequest *r = [[MLatestIndexRequest alloc] init];
        r.code = @"gresgffvd";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MLatestIndexRequest *r = [[MLatestIndexRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10000 handler:NULL];
}

#pragma mark - 请求个股大事提醒
- (void)testMBigEventNotificationRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBigEventNotificationRequest *r = [[MBigEventNotificationRequest alloc] init];
        r.code = @"601600.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBigEventNotificationRequest *r = [[MBigEventNotificationRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBigEventNotificationRequest *r = [[MBigEventNotificationRequest alloc] init];
        r.code = @"fdosiajkckldv";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBigEventNotificationRequest *r = [[MBigEventNotificationRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股分红配送资讯
- (void)testMBonusFinanceRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBonusFinanceRequest *r = [[MBonusFinanceRequest alloc] init];
        r.code = @"600000.sh";
        r.sourceType = MF10DataSourceGA;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBonusFinanceRequest *r = [[MBonusFinanceRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBonusFinanceRequest *r = [[MBonusFinanceRequest alloc] init];
        r.code = @"fsdafewvbfd";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBonusFinanceRequest *r = [[MBonusFinanceRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }

    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股融资融券资讯
- (void)testMTradeDetailInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTradeDetailInfoRequest *r = [[MTradeDetailInfoRequest alloc] init];
        r.code = @"601600.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTradeDetailInfoRequest *r = [[MTradeDetailInfoRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTradeDetailInfoRequest *r = [[MTradeDetailInfoRequest alloc] init];
        r.code = @"fag4revfdc";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTradeDetailInfoRequest *r = [[MTradeDetailInfoRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股机构预测资讯
- (void)testMForecastYearRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MForecastYearRequest *r = [[MForecastYearRequest alloc] init];
        r.code = @"601600.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MForecastYearRequest *r = [[MForecastYearRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MForecastYearRequest *r = [[MForecastYearRequest alloc] init];
        r.code = @"fagwarbwv";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MForecastYearRequest *r = [[MForecastYearRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股机构评等资讯
- (void)testMForecastRatingRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MForecastRatingRequest *r = [[MForecastRatingRequest alloc] init];
        r.code = @"601600.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MForecastRatingRequest *r = [[MForecastRatingRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MForecastRatingRequest *r = [[MForecastRatingRequest alloc] init];
        r.code = @"faegawdsv";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MForecastRatingRequest *r = [[MForecastRatingRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股大宗交易资讯
- (void)testMBlockTradeInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBlockTradeInfoRequest *r = [[MBlockTradeInfoRequest alloc] init];
        r.code = @"601600.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBlockTradeInfoRequest *r = [[MBlockTradeInfoRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBlockTradeInfoRequest *r = [[MBlockTradeInfoRequest alloc] init];
        r.code = @"dafafeawv";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBlockTradeInfoRequest *r = [[MBlockTradeInfoRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股基本情况
- (void)testMCompanyInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCompanyInfoRequest *r = [[MCompanyInfoRequest alloc] init];
        r.code = @"600000.sh";
        r.sourceType = MF10DataSourceGA;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCompanyInfoRequest *r = [[MCompanyInfoRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCompanyInfoRequest *r = [[MCompanyInfoRequest alloc] init];
        r.code = @"fewfwaevd";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCompanyInfoRequest *r = [[MCompanyInfoRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股主要业务
- (void)testMCoreBusinessRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCoreBusinessRequest *r = [[MCoreBusinessRequest alloc] init];
        r.code = @"601600.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCoreBusinessRequest *r = [[MCoreBusinessRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCoreBusinessRequest *r = [[MCoreBusinessRequest alloc] init];
        r.code = @"fefvdnte";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MCoreBusinessRequest *r = [[MCoreBusinessRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股管理层资讯
- (void)testMLeaderPersonInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MLeaderPersonInfoRequest *r = [[MLeaderPersonInfoRequest alloc] init];
        r.code = @"601600.sh";
        r.sourceType = MF10DataSourceGA;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MLeaderPersonInfoRequest *r = [[MLeaderPersonInfoRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MLeaderPersonInfoRequest *r = [[MLeaderPersonInfoRequest alloc] init];
        r.code = @"ganrsyndc";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MLeaderPersonInfoRequest *r = [[MLeaderPersonInfoRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股发行上市资讯
- (void)testMIPOInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MIPOInfoRequest *r = [[MIPOInfoRequest alloc] init];
        r.code = @"601600.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MIPOInfoRequest *r = [[MIPOInfoRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MIPOInfoRequest *r = [[MIPOInfoRequest alloc] init];
        r.code = @"faegrefdsger";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MIPOInfoRequest *r = [[MIPOInfoRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股财务指标
- (void)testMFinancialSummaryRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFinancialSummaryRequest *r = [[MFinancialSummaryRequest alloc] init];
        r.code = @"601600.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFinancialSummaryRequest *r = [[MFinancialSummaryRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFinancialSummaryRequest *r = [[MFinancialSummaryRequest alloc] init];
        r.code = @"fahfdhrytgf";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFinancialSummaryRequest *r = [[MFinancialSummaryRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股财务报表
- (void)testMFinancialInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFinancialInfoRequest *r = [[MFinancialInfoRequest alloc] init];
        r.code = @"601600.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFinancialInfoRequest *r = [[MFinancialInfoRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFinancialInfoRequest *r = [[MFinancialInfoRequest alloc] init];
        r.code = @"fae4gfzdbz";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFinancialInfoRequest *r = [[MFinancialInfoRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股控股股东资讯
- (void)testMControlingShareHolderRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MControlingShareHolderRequest *r = [[MControlingShareHolderRequest alloc] init];
        r.code = @"601600.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MControlingShareHolderRequest *r = [[MControlingShareHolderRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MControlingShareHolderRequest *r = [[MControlingShareHolderRequest alloc] init];
        r.code = @"fsdafewvb";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MControlingShareHolderRequest *r = [[MControlingShareHolderRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股股本结构资讯
- (void)testMStockShareInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockShareInfoRequest *r = [[MStockShareInfoRequest alloc] init];
        r.code = @"601600.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockShareInfoRequest *r = [[MStockShareInfoRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockShareInfoRequest *r = [[MStockShareInfoRequest alloc] init];
        r.code = @"fdsafbvdvs";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockShareInfoRequest *r = [[MStockShareInfoRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股股本变动资讯
- (void)testMStockShareChangeInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockShareChangeInfoRequest *r = [[MStockShareChangeInfoRequest alloc] init];
        r.code = @"601600.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockShareChangeInfoRequest *r = [[MStockShareChangeInfoRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockShareChangeInfoRequest *r = [[MStockShareChangeInfoRequest alloc] init];
        r.code = @"dshwtrnsbd";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockShareChangeInfoRequest *r = [[MStockShareChangeInfoRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 请求个股股东变动资讯
- (void)testMShareHolderHistoryInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MShareHolderHistoryInfoRequest *r = [[MShareHolderHistoryInfoRequest alloc] init];
        r.code = @"601600.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MShareHolderHistoryInfoRequest *r = [[MShareHolderHistoryInfoRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MShareHolderHistoryInfoRequest *r = [[MShareHolderHistoryInfoRequest alloc] init];
        r.code = @"fawegar";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MShareHolderHistoryInfoRequest *r = [[MShareHolderHistoryInfoRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 最新十大流通股股东
- (void)testMTopLiquidShareHolderRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTopLiquidShareHolderRequest *r = [[MTopLiquidShareHolderRequest alloc] init];
        r.code = @"601600.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTopLiquidShareHolderRequest *r = [[MTopLiquidShareHolderRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTopLiquidShareHolderRequest *r = [[MTopLiquidShareHolderRequest alloc] init];
        r.code = @"fawegar";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTopLiquidShareHolderRequest *r = [[MTopLiquidShareHolderRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 最新十大机构股东
- (void)testMTopShareHolderRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTopShareHolderRequest *r = [[MTopShareHolderRequest alloc] init];
        r.code = @"601600.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTopShareHolderRequest *r = [[MTopShareHolderRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTopShareHolderRequest *r = [[MTopShareHolderRequest alloc] init];
        r.code = @"fawegar";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTopShareHolderRequest *r = [[MTopShareHolderRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 最新基金持股
- (void)testMFundShareHolderInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundShareHolderInfoRequest *r = [[MFundShareHolderInfoRequest alloc] init];
        r.code = @"601600.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundShareHolderInfoRequest *r = [[MFundShareHolderInfoRequest alloc] init];
        r.code = @"000001.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundShareHolderInfoRequest *r = [[MFundShareHolderInfoRequest alloc] init];
        r.code = @"fawegar";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundShareHolderInfoRequest *r = [[MFundShareHolderInfoRequest alloc] init];
        r.code = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 财经资讯列表
- (void)testMNewsListRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MNewsListRequest *r = [[MNewsListRequest alloc] init];
        r.newsType = @"0000";
        r.pageIndex = 0;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MNewsListRequest *r = [[MNewsListRequest alloc] init];
        r.newsType = @"f4fav";
        r.pageIndex = -10293;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MNewsListRequest *r = [[MNewsListRequest alloc] init];
        r.newsType = nil;
        r.pageIndex = 23109;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 财经资讯明细
- (void)testMNewsRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MNewsRequest *r = [[MNewsRequest alloc] init];
        r.newsID = @"73418468393";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MNewsRequest *r = [[MNewsRequest alloc] init];
        r.newsID = @"f94uejfwdics320eiwc";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MNewsRequest *r = [[MNewsRequest alloc] init];
        r.newsID = nil;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 个股公告列表
- (void)testMStockBulletinListRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockBulletinListRequest *r = [[MStockBulletinListRequest alloc] init];
        r.code = @"00023.hk";
        r.pageIndex = 0;
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockBulletinListRequest *r = [[MStockBulletinListRequest alloc] init];
        r.code = @"000001.sh";
        r.pageIndex = 0;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockBulletinListRequest *r = [[MStockBulletinListRequest alloc] init];
        r.code = @"dgfhf4i3hrev";
        r.pageIndex = -21324;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockBulletinListRequest *r = [[MStockBulletinListRequest alloc] init];
        r.code = @"349tugjrv";
        r.pageIndex = 927358;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockBulletinListRequest *r = [[MStockBulletinListRequest alloc] init];
        r.code = nil;
        r.pageIndex = 0;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 个股公告明细
- (void)testMStockBulletinRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockBulletinRequest *r = [[MStockBulletinRequest alloc] init];
        r.stockBulletinID = @"601600.sh_72828869956";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MStockBulletinRequest *r = [[MStockBulletinRequest alloc] init];
//        r.stockBulletinID = @"43t9gwjvdsca";
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MStockBulletinRequest *r = [[MStockBulletinRequest alloc] init];
//        r.stockBulletinID = nil;
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 个股新闻列表
- (void)testMStockNewsListRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockNewsListRequest *r = [[MStockNewsListRequest alloc] init];
        r.code = @"601600.sh";
        r.pageIndex = 0;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MStockNewsListRequest *r = [[MStockNewsListRequest alloc] init];
//        r.code = @"f43grvsvds";
//        r.pageIndex = -123489894;
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MStockNewsListRequest *r = [[MStockNewsListRequest alloc] init];
//        r.code = @"gferijgidsv";
//        r.pageIndex = 2492385;
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MStockNewsListRequest *r = [[MStockNewsListRequest alloc] init];
//        r.code = nil;
//        r.pageIndex = 0;
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 个股新闻明细
- (void)testMStockNewsRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockNewsRequest *r = [[MStockNewsRequest alloc] init];
        r.stockNewsID = @"601600.sh_71983398859";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MStockNewsRequest *r = [[MStockNewsRequest alloc] init];
//        r.stockNewsID = @"fgerivsdkcsc";
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MStockNewsRequest *r = [[MStockNewsRequest alloc] init];
//        r.stockNewsID = nil;
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 个股研报列表
- (void)testMStockReportListRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockReportListRequest *r = [[MStockReportListRequest alloc] init];
        r.code = @"601600.sh";
        r.pageIndex = 0;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockReportListRequest *r = [[MStockReportListRequest alloc] init];
        r.code = @"f43grvsvds";
        r.pageIndex = -123489894;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockReportListRequest *r = [[MStockReportListRequest alloc] init];
        r.code = @"gferijgidsv";
        r.pageIndex = 2492385;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockReportListRequest *r = [[MStockReportListRequest alloc] init];
        r.code = nil;
        r.pageIndex = 0;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 个股研报明细
- (void)testMStockReportRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockReportRequest *r = [[MStockReportRequest alloc] init];
        r.stockReportID = @"601600.sh_71983398859";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MStockReportRequest *r = [[MStockReportRequest alloc] init];
//        r.stockReportID = @"fgerivsdkcsc";
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
//    {
//        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MStockReportRequest *r = [[MStockReportRequest alloc] init];
//        r.stockReportID = nil;
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            [e fulfill]; e = nil;
//        }];
//    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}


#pragma mark - 股票分类代码表
- (void)testMStockCategoryListRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStockCategoryListRequest *r = [[MStockCategoryListRequest alloc] init];
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}


#pragma mark - Level2 分时明细
- (void)testMTimeTickRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTimeTickRequest *r = [[MTimeTickRequest alloc] init];
        r.code = @"600000.sh";
        r.index = @"0";
        r.type = MTimeTickRequestTypeRecent;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            MTimeTickResponse *response = (MTimeTickResponse *)resp;
            NSLog(@"response.items.count:%zd", response.items.count);
            NSLog(@"%@", response);
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - Level2 分价量表
- (void)testMPriceVolumeRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MPriceVolumeRequest *r = [[MPriceVolumeRequest alloc] init];
        r.code = @"600000.sh";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - Level2 最佳一档明细
- (void)testMOrderQuantityRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MOrderQuantityRequest *r = [[MOrderQuantityRequest alloc] init];
        r.code = @"600000.sh";
        r.subtype = @"1001";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 港股其他信息
- (void)testMHKQuoteInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MHKQuoteInfoRequest *r = [[MHKQuoteInfoRequest alloc] init];
        r.code = @"00005.hk";
        r.subtype = @"1001";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            NSLog(@"%@", resp);
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}


#pragma mark - 新股日历上面列表
- (void)testMIPODateRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MIPODateRequest *r = [[MIPODateRequest alloc] init];
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 新股日历
- (void)testMIPOCalendarRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MIPOCalendarRequest *r = [[MIPOCalendarRequest alloc] init];
        r.date = @"2016-07-15";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}


#pragma mark - IPO明细
- (void)testMIPOShareDetailRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MIPOShareDetailRequest *r = [[MIPOShareDetailRequest alloc] init];
        r.code = @"600919";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 假日档
- (void)testMMarketHolidayRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MMarketHolidayRequest *r = [[MMarketHolidayRequest alloc] init];
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

- (void)testMTimeTickDetailRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MTimeTickDetailRequest *r = [[MTimeTickDetailRequest alloc] init];
        r.code = @"600000.sh";
        r.pageIndex = 0;
        r.pageSize = 50;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            MTimeTickDetailResponse *response = (MTimeTickDetailResponse *)resp;
            NSLog(@"%@", response);
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 基金净值
- (void)testMFundValueRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundValueRequest *r = [[MFundValueRequest alloc] init];
        r.code = @"502002.sh";
        r.type = @"12";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 取IP清单
- (void)testMGetServerRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MGetServerRequest *r = [[MGetServerRequest alloc] init];
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 个股静态数据
- (void)testMGetStaticDataRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MStaticDataRequest *r = [[MStaticDataRequest alloc] init];
        r.code = @"600000.sh,000001.sz";
        r.param = @"bk";
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            MStaticDataResponse* response = (MStaticDataResponse *)resp;
            [response.dataItems enumerateObjectsUsingBlock:^(MStaticDataItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"%@",obj.description);
            }];
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 两市港股通数据
- (void)testMGetHKMarketInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MHKMarketInfoRequest *r = [[MHKMarketInfoRequest alloc] init];
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"%@",resp.description);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:1000000 handler:NULL];
}

#pragma mark - 基金概况
- (void)testMFundBasicInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundBasicInfoRequest *r = [[MFundBasicInfoRequest alloc] init];
        r.code = @"500058.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"基金概况 === %@",((MFundBasicInfoResponse *)resp).record);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 基金净值
- (void)testMFundNetValueRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundNetValueRequest *r = [[MFundNetValueRequest alloc] init];
        r.code = @"500058.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"基金净值 === %@",((MFundNetValueResponse *)resp).records);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 资产配置
- (void)testMFundAssetAllocationRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundAssetAllocationRequest *r = [[MFundAssetAllocationRequest alloc] init];
        r.code = @"500058.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"资产配置 === %@",((MFundAssetAllocationResponse *)resp).record);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 行业组合
- (void)testMFundIndustryPortfolioRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundIndustryPortfolioRequest *r = [[MFundIndustryPortfolioRequest alloc] init];
        r.code = @"500058.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"行业组合 === %@",((MFundIndustryPortfolioResponse *)resp).record);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 股票组合
- (void)testMFundStockPortfolioRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundStockPortfolioRequest *r = [[MFundStockPortfolioRequest alloc] init];
        r.code = @"500058.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"股票组合 === %@",((MFundStockPortfolioResponse *)resp).record);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 份额结构
- (void)testMFundShareStructRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundShareStructRequest *r = [[MFundShareStructRequest alloc] init];
        r.code = @"500058.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"份额结构 === %@",((MFundShareStructResponse *)resp).record);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 基金财务
- (void)testMFundFinanceRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundFinanceRequest *r = [[MFundFinanceRequest alloc] init];
        r.code = @"500058.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"基金财务 === %@",((MFundFinanceResponse *)resp).record);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 基金分红
- (void)testMFundDividendRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MFundDividendRequest *r = [[MFundDividendRequest alloc] init];
        r.code = @"500058.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"基金分红 === %@",((MFundDividendResponse *)resp).record);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 债券概况
- (void)testMBoundBasicInfoRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBondBasicInfoRequest *r = [[MBondBasicInfoRequest alloc] init];
        r.code = @"010619.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"债券概况 === %@",((MBondBasicInfoResponse *)resp).record);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 付息情况
- (void)testMBoundInterestPayRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
        MBondInterestPayRequest *r = [[MBondInterestPayRequest alloc] init];
        r.code = @"019508.sh";
        r.sourceType = MF10DataSourceCH;
        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
            NSLog(@"付息情况 === %@",((MBondInterestPayResponse *)resp).record);
            [e fulfill]; e = nil;
        }];
    }
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

#pragma mark - 债券回购情况
- (void)testMBoundBuyBacksRequest {
    {
        __block XCTestExpectation *e = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//        MBoundBuyBacksRequest *r = [[MBoundBuyBacksRequest alloc] init];
//        r.code = @"010619.sh";
//        r.sourceType = MF10DataSourceCH;
//        [MApi sendRequest:r completionHandler:^(MResponse *resp) {
//            XCTAssertEqual(resp.status, MResponseStatusSuccess, @"%@", resp.message);
//            NSLog(@"债券回购 === %@",((MBoundInterestPayResponse *)resp).record);
//            [e fulfill]; e = nil;
//        }];
        MQuoteRequest *request = [[MQuoteRequest alloc]init];
            request.code = @"000595.sz,002833.sz,600853.sh,300219.sz,002264.sz,300331.sz,160617.sz,160718.sz,160217.sz,150297.sz,150298.sz,300402.sz,002059.sz,150264.sz,601601.sh,519888.sh,502030.sh,002346.sz,300577.sz,165513.sz,161217.sz,502013.sh,159935.sz,502032.sh,502031.sh,150201.sz,601799.sh,300576.sz,150067.sz,150066.sz,160137.sz,161818.sz,502016.sh,150033.sz,150032.sz,000798.sz,600232.sh,600798.sh,002576.sz,000672.sz,150214.sz,600050.sh,000656.sz,603319.sh,300506.sz,300507.sz,600773.sh,000001.sh,150149.sz,150284.sz,150206.sz,399006.sz,600366.sh,600017.sh,600586.sh,000529.sz,150059.sz,150109.sz,000680.sz,600538.sh,150144.sz,002436.sz,601168.sh,300411.sz,601669.sh,300308.sz,601015.sh,150176.sz,502015.sh,150276.sz,399001.sz,300560.sz,300557.sz,150252.sz,002695.sz,603997.sh,000968.sz,000815.sz,000591.sz,150278.sz,002124.sz,000736.sz,150230.sz,000573.sz,600315.sh,600759.sh,000518.sz";
//        request.code = @"600000.sh,600004.sh,600005.sh,600006.sh,600007.sh,600008.sh,600009.sh,600010.sh,600011.sh,600012.sh,600015.sh,600016.sh,600017.sh,600018.sh,600019.sh,600020.sh,600021.sh,600022.sh,600023.sh,600026.sh,600027.sh,600028.sh,600029.sh,600030.sh,600031.sh,600032.sh,600033.sh,600035.sh,600036.sh,600037.sh,600038.sh,600039.sh,600048.sh,600050.sh,600051.sh,600052.sh,600053.sh,600054.sh,600055.sh,600056.sh,600057.sh,600058.sh,600059.sh,600060.sh,600061.sh,600062.sh,600063.sh,600064.sh,600066.sh,600067.sh,600068.sh,600069.sh,600070.sh,600071.sh,600072.sh,600073.sh,600074.sh,600075.sh,600076.sh,600077.sh,600078.sh,600079.sh,600080.sh,600081.sh,600082.sh,600083.sh,600084.sh,600085.sh,600086.sh,600088.sh,600089.sh,600090.sh,600091.sh,600093.sh,600094.sh,600095.sh,600096.sh,600097.sh,600098.sh,000001.sz,";
        [MApi sendRequest:request completionHandler:^(MResponse *resp) {
            if (resp.status == MResponseStatusSuccess) {
                NSLog(@"成功");
            }
            else{
                NSLog(@"失败");
            }
        }];
    }
    [self waitForExpectationsWithTimeout:10000 handler:NULL];
}

@end



