//
//  AspectsContainer.h
//  XMSwizzing
//
//  Created by 李良明 on 2017/10/19.
//  Copyright © 2017年 李良明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AspectIdentifier.h"
#import "commomHeader.h"

@interface AspectsContainer : NSObject

- (void)addAspect:(AspectIdentifier *)aspect withOptions:(AspectOptions)injectPosition;
- (BOOL)removeAspect:(id)aspect;
- (BOOL)hasAspects;
@property (atomic, copy) NSArray *beforeAspects;
@property (atomic, copy) NSArray *insteadAspects;
@property (atomic, copy) NSArray *afterAspects;

@end
