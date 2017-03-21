//
//  MSectionRankingItem+MStockItem.m
//  Pods
//
//  Created by 金融研發一部-蕭裕翰 on 8/24/15.
//
//

#import "MSectionRankingItem+MStockItem.h"

@implementation MSectionRankingItem (MStockItem)
+ (MStockItem *)stockItemBySectionRankingItem:(MSectionRankingItem *)sectionRankingItem {
    MStockItem *stockItem = [[MStockItem alloc] init];
    stockItem.ID = sectionRankingItem.stockID;
    stockItem.name = sectionRankingItem.stockName;
    return stockItem;
}

+ (NSArray *)stockItemsBySectionRankingItems:(NSArray *)sectionRankingItems {
    NSMutableArray  *stockItems =[NSMutableArray array];
    for (MSectionRankingItem *rankingItem in sectionRankingItems) {
        MStockItem *stockItem = [self stockItemBySectionRankingItem:rankingItem];
        [stockItems addObject:stockItem];
    }
    return [stockItems copy];
}

- (MStockItem *)stockItem {
    MStockItem *stockItem = [[MStockItem alloc] init];
    stockItem.ID = self.stockID;
    stockItem.name = self.stockName;
    return stockItem;
}
@end
