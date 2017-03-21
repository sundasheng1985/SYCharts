//
//  BackDoorViewController.m
//  CrystalTouch
//
//  Created by mitake on 2015/5/29.
//  Copyright (c) 2015年 mitake. All rights reserved.
//

#import "BackDoorViewController.h"
#import "MApi.h"

@interface MApi (BackDoor)
+ (UInt8)currentServerIndex;
@end

@implementation BackDoorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.title = @"伺服器";
}

- (void)done {
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
#else
    [self dismissModalViewControllerAnimated:YES];
#endif
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"上证服务器";
            break;
        case 1:
            cell.textLabel.text = @"水晶服务器";
            break;
        case 2:
            cell.textLabel.text = @"台湾服务器";
            break;
        default:
            break;
    }
    UInt8 index = [MApi currentServerIndex];
    if (index == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MApiChangeServerEvent" object:@(indexPath.row) userInfo:nil];
    [tableView reloadData];
}

@end
