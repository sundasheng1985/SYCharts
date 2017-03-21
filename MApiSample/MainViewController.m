//
//  ViewController.m
//  MApiSample
//
//  Created by mitake on 2015/5/28.
//  Copyright (c) 2015年 Mitake. All rights reserved.
//

#import "MainViewController.h"
#import "ResponseViewController.h"
#import "BackDoorViewController.h"
#import "MApi.h"

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *requestInfo;
@property (nonatomic, strong) UIView *titleView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerServer];
    [self.view addSubview:self.tableView];
    //self.title = @"测试数据";
    self.navigationItem.titleView = self.titleView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Method

- (void)registerServer {
    //[MApi setCorpID:@"00015"];
    [MApi registerAPP:@"xOIC9eqj9sIFujj85bm3TCWk2qr3JuxcdikarSmhhZw=" completionHandler:^(NSError *error) {
        if (!error) {
            NSLog(@"注册成功");
        }
        else {
            NSLog(@"注册失败, %@", error);
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

#pragma mark - property

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (NSArray *)requestInfo {
    if (!_requestInfo) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"TestQuoteInfos" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        _requestInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    }
    return _requestInfo;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 64)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 100, 64)];
        titleLabel.text = @"测试数据";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleView addSubview:titleLabel];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToPopbackView:)];
        [_titleView addGestureRecognizer:tapGesture];
    }
    return _titleView;
}

- (void)tapToPopbackView:(id)sender {
    BackDoorViewController *vc = [[BackDoorViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
    [self presentViewController:nav animated:YES completion:^{
        
    }];
#else
    [self presentModalViewController:nav animated:YES];
#endif
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.requestInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *info = _requestInfo[indexPath.row];
    
    cell.textLabel.text = info[@"title"];
    return cell;
}

#pragma mark- tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = _requestInfo[indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ResponseViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ResponseViewController"];
    viewController.title = info[@"title"];
    viewController.info = info;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self registerServer];
}

- (IBAction)marketInfo:(id)sender {
    MMarketInfo *marketInfo = [MApi marketInfoWithMarket:@"sh" subtype:@"3002"];
    NSLog(@"%@", marketInfo);
}
@end
