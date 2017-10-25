//
//  UIButton+FillColor.h
//  eTax
//
//  Created by 田广 on 16/7/12.
//  Copyright © 2016年 ysyc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (FillColor)
/**
 *  设置背景颜色
 *
 *  @param backgroundColor 颜色值
 *  @param state  状态
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
