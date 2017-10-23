//
//  XMSwizzing.h
//  XMSwizzing
//
//  Created by 李良明 on 2017/10/19.
//  Copyright © 2017年 李良明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommomProtocol.h"
#import "commomHeader.h"
#import "AspectIdentifier.h"
#import "AspectTracker.h"
#import "AspectsContainer.h"
#import "AspectInfo.h"

@interface NSObject (XMSwizzing)

+ (id<AspectToken>)aspect_hookSelector:(SEL)selector withOptions:(AspectOptions)options usingBlock:(id)block error:(NSError **)error;

- (id<AspectToken>)aspect_hookSelector:(SEL)selector withOptions:(AspectOptions)options usingBlock:(id)block
    error:(NSError **)error;

@end
