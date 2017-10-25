//
//  ObjectUtil.h
//  EWaters
//
//  Created by jimi on 17/3/14.
//  Copyright © 2017年 jimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectUtil : NSObject
+ (BOOL)isEmptyObject:(NSObject *)object;
+ (BOOL)isNonEmptyObject:(NSObject *)object ofClass:(Class)class;
+ (BOOL)isNonEmptyString:(NSString *)string;
@end
