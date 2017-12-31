//
//  TODOTableViewCell.m
//  小可爱的便利贴
//
//  Created by zm on 2017/12/9.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "TODOTableViewCell.h"
#import "TaskModel.h"

@implementation TODOTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)completedTaskAction:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(addTaskToCompletedList:)] ){
        self.model.isCompleted = !self.completedButton.selected;
        [self.delegate addTaskToCompletedList:self.model];
    }
}



@end
