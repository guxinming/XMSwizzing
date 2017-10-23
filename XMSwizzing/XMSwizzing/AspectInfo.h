//
//  AspectInfo.h
//  XMSwizzing
//
//  Created by 李良明 on 2017/10/20.
//  Copyright © 2017年 李良明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommomProtocol.h"
#import "NSInvocation+Aspects.h"

@interface AspectInfo : NSObject <AspectInfo>

- (id)initWithInstance:(__unsafe_unretained id)instance invocation:(NSInvocation *)invocation;
@property (nonatomic, unsafe_unretained, readonly) id instance;
@property (nonatomic, strong, readonly) NSArray *arguments;
@property (nonatomic, strong, readonly) NSInvocation *originalInvocation;

@end
