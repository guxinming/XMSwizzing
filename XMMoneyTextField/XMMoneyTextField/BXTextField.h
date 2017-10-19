//
//  BXTextField.h
//  bxbank
//
//  Created by 李良明 on 2017/8/10.
//  Copyright © 2017年 bxbank. All rights reserved.
//

#import <UIKit/UIKit.h>

//封装系统的UITextField，使用这个类的时候不要使用这个类delegate属性,否则会导致代理无效
@protocol BXMoneyTextFieldDelegate <NSObject>

@optional

- (BOOL)bx_moneyTextFieldShouldBeginEditing:(UITextField *)textField;

- (void)bx_moneyTextFieldDidBeginEditing:(UITextField *)textField;

- (BOOL)bx_moneyTextFieldShouldEndEditing:(UITextField *)textField;

- (void)bx_moneyTextFieldDidEndEditing:(UITextField *)textField;

/**
 textField文字变化回调的方法

 @param textField 当前输入框
 @param range     文本变化范围（系统代理返回）
 @param string    需要变化的文本（系统代理返回）
 @param nowText   变化后的文本
 @param result    正则校验的结果，如果为YES，则当前输入框文本为nowText，如果为NO，则输入框文本为变化前的文本
 @return          是否可以变化
 */
- (BOOL)bx_moneyTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string nowText:(NSString *)nowText checkResult:(BOOL)result;

- (BOOL)bx_moneyTextFieldShouldClear:(UITextField *)textField;

- (BOOL)bx_moneyTextFieldShouldReturn:(UITextField *)textField;

@end

@interface BXMoneyTextField : UITextField

@property (nonatomic, weak) id <BXMoneyTextFieldDelegate>moneyTextFieldDelegate;

@end


@interface CheckToolsClass : NSObject

+ (BOOL)validateMoney:(NSString *)money;

@end
