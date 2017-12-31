//
//  DBHelper.m
//  小可爱的便利贴
//
//  Created by zm on 2017/12/10.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DBHelper.h"
#import "TaskModel.h"
#include <sys/time.h>

#define kDOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Library"]
#define TableName @"TaskList"

@implementation DBHelper

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    __strong static DBHelper *helper = nil;
    dispatch_once(&onceToken, ^{
        helper = [[DBHelper alloc] init];
    });
    return helper;
}

- (instancetype)init{
    self = [super init];
    if(self){
        NSString *writableDBPath = [kDOCUMENTS_FOLDER stringByAppendingPathComponent:@"TaskLists.db"];
        NSLog(@"DBPath:%@",writableDBPath);
        _queue = [FMDatabaseQueue databaseQueueWithPath:writableDBPath];
        
        [self createTaskTable];
    }
    return self;
}

- (BOOL)executeStatements:(NSString *)strSql
{
    __block  BOOL isSuccess = YES;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        *rollback = NO;
        @try {
            isSuccess = [db executeStatements:strSql];
            if ([db hadError])
            {
                isSuccess = NO;
            }
        }
        @catch (NSException *exception) {
            *rollback = YES;
            [db rollback];
        }
        @finally {
            if (!rollback) {
                [db commit];
            }
        }
    }];
    [self.queue close];
    
    return isSuccess;
}

- (void)createTaskTable{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@  ("
                     " pkid integer primary key autoincrement not null, "
                     " task varchar(128)," //任务
                     " isCompleted integer," // 是否完成
                     " addTime datetime" //加入时间
                     ");",TableName];
    [self executeStatements:sql];
}

- (NSArray *)readAllLists{
    __block NSMutableArray *tasks = [NSMutableArray new];
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"SELECT pkid,task,isCompleted FROM %@ ORDER BY addTime DESC;",TableName]];
        while ([result next]) {
            NSInteger taskid = [result intForColumn:@"pkid"];
            NSString *task = [result stringForColumn:@"task"];
            BOOL isCompleted = [result intForColumn:@"isCompleted"];
            
            TaskModel *model = [TaskModel new];
            model.taskId = taskid;
            model.task = task;
            model.isCompleted = isCompleted;
            
            [tasks addObject:model];
        }
    }];
    return [tasks copy];
}

- (BOOL)writeTask:(TaskModel *)model{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (task, isCompleted,addTime) VALUES ('%@','%@','%@')",TableName,model.task,@(model.isCompleted),[self numberWithCurrentTime]];
   return  [self executeStatements:sql];
}

- (BOOL)removeTask:(TaskModel *)model{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ where pkid = '%ld'",TableName,(long)model.taskId];
    return  [self executeStatements:sql];
}

- (BOOL)updateCompleteState:(TaskModel *)model{
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET isCompleted= '%d' , addTime = '%@' where pkid = '%ld'",TableName,model.isCompleted,[self numberWithCurrentTime],(long)model.taskId];
    return  [self executeStatements:sql];
}

- (NSNumber *)numberWithCurrentTime{
    struct timeval curtime;
    gettimeofday(&curtime, nil);
    long long seconds = curtime.tv_sec;
    long long timeM = seconds*1000 + curtime.tv_usec/1000; //毫秒
    return [NSNumber numberWithLongLong:timeM];
}


@end
