//
//  DBHelper.h
//  小可爱的便利贴
//
//  Created by zm on 2017/12/10.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fmdb.h"
#import "TaskModel.h"

@interface DBHelper : NSObject
@property (nonatomic,strong) FMDatabaseQueue* queue;

+ (instancetype)sharedInstance;
- (NSArray *)readAllLists;

- (BOOL)writeTask:(TaskModel *)model;
- (BOOL)removeTask:(TaskModel *)model;
- (BOOL)updateCompleteState:(TaskModel *)model;
@end
