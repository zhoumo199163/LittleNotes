//
//  TodayViewController.m
//  LittleNotesWidget
//
//  Created by zm on 2017/12/20.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TaskModel.h"
#import "TodayTableViewCell.h"

static NSString *TodayCellReuseIdentifier = @"TodayTableViewCell";

@interface TodayViewController () <NCWidgetProviding,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <TaskModel *>*todoLists;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _todoLists = [NSMutableArray new];
    [self reloadData];
    
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    
    UINib *addNib = [UINib nibWithNibName:@"TodayTableViewCell" bundle:nil];
    [self.tableView registerNib:addNib forCellReuseIdentifier:TodayCellReuseIdentifier];
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
}

- (void)reloadData{
     [_todoLists removeAllObjects];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.zm.eatChicken"];
    NSData *data = [userDefaults dataForKey:@"YOYO_todoLists"];
    _todoLists = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

// 折叠 展开
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 30*_todoLists.count);
    } else {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 30*_todoLists.count);
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"YOYO://"]];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _todoLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TodayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TodayCellReuseIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    TaskModel *model = _todoLists[indexPath.row];
    cell.todoTaskLabel.text = model.task;
    return cell;
}

@end
