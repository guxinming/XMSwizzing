//
//  NSString+Size.m
//  EWaters
//
//  Created by jimi on 17/3/15.
//  Copyright © 2017年 jimi. All rights reserved.
//

#import "NSString+Size.h"
#import "ObjectUtil.h"

#define FONT_SYSTEM(obj) [UIFont fontWithName:@"Helvetica" size:obj]
#define FONT_SYSTEM_BOLD(obj) [UIFont fontWithName:@"Helvetica-Bold" size:obj]
#define BOLD_FONT_SYSTEM(obj) [UIFont fontWithName:@"Helvetica" size:obj]

@implementation NSString (Size)
- (CGFloat)widthWithFontOfSize:(CGFloat)fontSize {
    if ([ObjectUtil isEmptyObject:self]) {
        return 0.0;
    }
    
    CGSize size = [self sizeWithFontOfSize:fontSize];
    
    return size.width;
}

- (CGFloat)heightWithFontOfSize:(CGFloat)fontSize {
    if ([ObjectUtil isEmptyObject:self]) {
        return 0.0;
    }
    
    CGSize size = [self sizeWithFontOfSize:fontSize];
    
    return size.height;
}

- (CGSize)sizeWithFontOfSize:(CGFloat)fontSize {
    return [self sizeWithFontOfSize:fontSize isBold:NO maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
}

- (CGSize)sizeWithBoldFontOfSize:(CGFloat)fontSize {
    return [self sizeWithFontOfSize:fontSize isBold:YES maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
}

- (CGSize)sizeWithFontOfSize:(CGFloat)fontSize maxSize:(CGSize)maxSize {
    
    CGSize size = [self sizeWithFontOfSize:fontSize isBold:NO maxSize:maxSize];
    
    return size;
}

- (CGSize)sizeWithFontOfSize:(CGFloat)fontSize isBold:(BOOL)isBold maxSize:(CGSize)maxSize {
    
    UIFont *font = [[UIFont alloc] init];;
    if (isBold) {
        
        font = BOLD_FONT_SYSTEM(fontSize);
    } else {
        
        font = FONT_SYSTEM(fontSize);
    }
    CGSize size = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil].size;
    
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    
    return size;
}

@end
