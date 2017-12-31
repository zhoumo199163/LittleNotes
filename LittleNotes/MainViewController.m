//
//  MainViewController.m
//  小可爱的便利贴
//
//  Created by zm on 2017/12/7.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "MainViewController.h"
#import "AddTableViewCell.h"
#import "TODOTableViewCell.h"
#import "TaskModel.h"
#import "DBHelper.h"

static NSString *AddCellReuseIdentifier = @"AddTableViewCell";
static NSString *TODOCellReuseIdentifier = @"TODOTableViewCell";
static NSUInteger DefaultMaxCompletedCount = 5;

#define kBGImageDataUserDefaults @"bgImageData"

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AddTableViewCellDelegate,TODOTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <TaskModel *>*todoLists;
@property (nonatomic, strong) NSMutableArray <TaskModel *>*completedLists;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopLayoutConstraint;
@property (nonatomic) BOOL isShowAllCompleted;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   NSData *imageData = [[NSUserDefaults standardUserDefaults] dataForKey:kBGImageDataUserDefaults];
    if(imageData){
        UIImage *image = [UIImage imageWithData:imageData];
        if(image) self.backgroundImageView.image = image;
    }
    
    [self updateNavStyle];
    if([[UIDevice currentDevice].systemVersion floatValue] <=11.0){
        [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    }
    
    _todoLists = [NSMutableArray new];
    _completedLists = [NSMutableArray new];
    _isShowAllCompleted = NO;
    
    [self reloadData];
    
    UINib *addNib = [UINib nibWithNibName:@"AddTableViewCell" bundle:nil];
    [self.tableView registerNib:addNib forCellReuseIdentifier:AddCellReuseIdentifier];
    UINib *todoNib = [UINib nibWithNibName:@"TODOTableViewCell" bundle:nil];
    [self.tableView registerNib:todoNib forCellReuseIdentifier:TODOCellReuseIdentifier];
    
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateNavStyle{
     NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    self.title = app_Name;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:156/255.0 green:70/255.0 blue:136/255.0 alpha:1.0]}];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton addTarget:self action:@selector(showAllCompleted:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"addTask_sel"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton addTarget:self action:@selector(chooseOneImage:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:[UIImage imageNamed:@"bgIcon"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark - Reload
- (void)reloadData{
    [_completedLists removeAllObjects];
    [_todoLists removeAllObjects];
    NSArray *allTasks = [[DBHelper sharedInstance] readAllLists];
    NSMutableArray *tempCompleted = [NSMutableArray new];
    for(TaskModel *model in allTasks){
        if(!model.isCompleted){
             [_todoLists addObject:model];
        }else{
            if(_isShowAllCompleted){
                [_completedLists addObject:model];
            }else{
                [tempCompleted addObject:model];
            }
        }
    }
    
    [tempCompleted enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx < DefaultMaxCompletedCount){
            [_completedLists addObject:obj];
        }
    }];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_todoLists];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.zm.eatChicken"];
    [userDefaults setObject:data forKey:@"YOYO_todoLists"];
    
}

#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardHeight = [aValue CGRectValue].size.height;
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = CGRectGetHeight(self.view.frame) - keyboardHeight;
    [UIView animateWithDuration:(NSTimeInterval)animationDuration animations:^{
        self.tableView.frame = tableViewFrame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = CGRectGetHeight(self.view.frame);
    [UIView animateWithDuration:(NSTimeInterval)animationDuration animations:^{
        self.tableView.frame = tableViewFrame;
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self tapGestureAction:nil];
}

#pragma mark - Action
- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)chooseOneImage:(id)sender{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showAllCompleted:(id)sender{
    _isShowAllCompleted = !_isShowAllCompleted;
    [self reloadData];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0f;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BOOL isSuccess = NO;
        if(indexPath.section == 1){
            isSuccess = [[DBHelper sharedInstance] removeTask:_todoLists[indexPath.row]];
        }else if(indexPath.section == 2){
            isSuccess = [[DBHelper sharedInstance] removeTask:_completedLists[indexPath.row]];
        }
        
        if(isSuccess){
            [self reloadData];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0) return 1;
    else if (section == 1) return self.todoLists.count;
    else if (section == 2) return self.completedLists.count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        AddTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddCellReuseIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        return cell;
    }
    if(indexPath.section == 1){
        TODOTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TODOCellReuseIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell.completedButton setSelected:NO];
        TaskModel *model = self.todoLists[indexPath.row];
        cell.todoLabel.text = model.task;
        cell.model = model;
        [cell.completedLine setHidden:YES];
        return cell;
    }
    if(indexPath.section == 2){
        TODOTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TODOCellReuseIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.completedLine setHidden:NO];
        [cell.completedButton setSelected:YES];
        TaskModel *model = self.completedLists[indexPath.row];
        cell.model = model;
        cell.delegate = self;
        cell.todoLabel.text = model.task;
        return cell;
    }
    return nil;
}

#pragma mark - AddTableViewCellDelegate
- (void)addTaskToToDoList:(TaskModel *)task{
    BOOL isSuccess = [[DBHelper sharedInstance] writeTask:task];
    if(isSuccess){
        [self reloadData];
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - TODOTableViewCellDelegate
- (void)addTaskToCompletedList:(TaskModel *)task{
    BOOL isSuccess = [[DBHelper sharedInstance] updateCompleteState:task];
    if(isSuccess){
        [self reloadData];
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    if(image){
        self.backgroundImageView.image = image;
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:kBGImageDataUserDefaults];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.backgroundImageView layoutIfNeeded];
        
    }];
}
@end
