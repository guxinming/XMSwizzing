//
//  NSString+Size.h
//  EWaters
//
//  Created by jimi on 17/3/15.
//  Copyright © 2017年 jimi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface NSString (Size)
- (CGFloat)widthWithFontOfSize:(CGFloat)fontSize;

- (CGFloat)heightWithFontOfSize:(CGFloat)fontSize;

- (CGSize)sizeWithFontOfSize:(CGFloat)fontSize;

- (CGSize)sizeWithBoldFontOfSize:(CGFloat)fontSize;

- (CGSize)sizeWithFontOfSize:(CGFloat)fontSize maxSize:(CGSize)maxSize;
@end
