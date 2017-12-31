//
//  AddTableViewCell.m
//  小可爱的便利贴
//
//  Created by zm on 2017/12/9.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "AddTableViewCell.h"
#import "TaskModel.h"

@implementation AddTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)addTaskToTODOListAction:(id)sender {
    NSString *text = self.taskTextField.text;
    if(self.delegate && [self.delegate respondsToSelector:@selector(addTaskToToDoList:)] && text.length){
        TaskModel *model = [TaskModel new];
        model.task = text;
        model.isCompleted = NO;
        [self.delegate addTaskToToDoList:model];
        self.taskTextField.text = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self addTaskToTODOListAction:textField];
    return NO;
}


@end
