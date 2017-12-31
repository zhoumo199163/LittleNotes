//
//  AddTableViewCell.h
//  小可爱的便利贴
//
//  Created by zm on 2017/12/9.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TaskModel;
@protocol AddTableViewCellDelegate<NSObject>
- (void)addTaskToToDoList:(TaskModel *)task;
@end

@interface AddTableViewCell : UITableViewCell<UITextFieldDelegate>
@property (nonatomic) id<AddTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *taskTextField;

@end
