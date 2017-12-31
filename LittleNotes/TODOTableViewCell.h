//
//  TODOTableViewCell.h
//  小可爱的便利贴
//
//  Created by zm on 2017/12/9.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskModel.h"

@protocol TODOTableViewCellDelegate<NSObject>
- (void)addTaskToCompletedList:(TaskModel *)task;
@end

@interface TODOTableViewCell : UITableViewCell
@property (nonatomic) id<TODOTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *todoLabel;
@property (weak, nonatomic) IBOutlet UILabel *completedLine;
@property (weak, nonatomic) IBOutlet UIButton *completedButton;
@property (nonatomic, strong) TaskModel *model;

@end
