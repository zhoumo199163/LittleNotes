//
//  TaskModel.h
//  小可爱的便利贴
//
//  Created by zm on 2017/12/10.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskModel : NSObject<NSCoding>

@property (nonatomic) NSInteger taskId;
@property (nonatomic, strong) NSString *task;
@property (nonatomic) BOOL isCompleted;

@end
