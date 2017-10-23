//
//  Header.h
//  XMSwizzing
//
//  Created by 李良明 on 2017/10/19.
//  Copyright © 2017年 李良明. All rights reserved.
//
#import <libkern/OSAtomic.h>
#ifndef Header_h
#define Header_h

typedef NS_OPTIONS(NSUInteger, AspectOptions) {
    AspectPositionAfter   = 0,            /// Called after the original implementation (default)
    AspectPositionInstead = 1,            /// Will replace the original implementation.
    AspectPositionBefore  = 2,            /// Called before the original implementation.
    
    AspectOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
};

static void aspect_performLocked(dispatch_block_t block) {
    static OSSpinLock aspect_lock = OS_SPINLOCK_INIT;
    OSSpinLockLock(&aspect_lock);
    block();
    OSSpinLockUnlock(&aspect_lock);
}

#define AspectPositionFilter 0x07
static NSString *const AspectsMessagePrefix = @"aspects_";
static NSString *const AspectsSubclassSuffix = @"_Aspects_";
static NSString *const AspectsForwardInvocationSelectorName = @"__aspects_forwardInvocation:";

static SEL aspect_aliasForSelector(SEL selector) {
    NSCParameterAssert(selector);
    return NSSelectorFromString([AspectsMessagePrefix stringByAppendingFormat:@"_%@", NSStringFromSelector(selector)]);
}

#endif /* Header_h */
