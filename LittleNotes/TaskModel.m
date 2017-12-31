//
//  TaskModel.m
//  小可爱的便利贴
//
//  Created by zm on 2017/12/10.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "TaskModel.h"
#import <objc/runtime.h>

@implementation TaskModel

// 解档方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    // 获取所有成员变量
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        // 将每个成员变量名转换为NSString对象类型
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 根据变量名解档取值，无论是什么类型
        id value = [aDecoder decodeObjectForKey:key];
        // 取出的值再设置给属性
        [self setValue:value forKey:key];
        // 这两步就相当于以前的 self.age = [aDecoder decodeObjectForKey:@"_age"];
    }
    free(ivars);
    return self;
}

// 归档调用方法
- (void)encodeWithCoder:(NSCoder *)aCoder {
    // 获取所有成员变量
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        // 将每个成员变量名转换为NSString对象类型
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 通过成员变量名，取出成员变量的值
        id value = [self valueForKeyPath:key];
        // 再将值归档
        [aCoder encodeObject:value forKey:key];
        // 这两步就相当于 [aCoder encodeObject:@(self.age) forKey:@"_age"];
    }
    free(ivars);
}


@end
