//
//  BXTextField.m
//  bxbank
//
//  Created by 李良明 on 2017/8/10.
//  Copyright © 2017年 bxbank. All rights reserved.
//

#import "BXTextField.h"
#define isNull(x)             (!x || [x isKindOfClass:[NSNull class]])
#define isEmptyString(x)   (isNull(x) || [x isEqual:@""] || [x isEqual:@"(null)"] || (x == nil))

@interface BXMoneyTextField () <UITextFieldDelegate>

@end

@implementation BXMoneyTextField

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.delegate = self;
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.delegate = self;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if(menuController)
    {
        [UIMenuController sharedMenuController].menuVisible=NO;
    }
    
    return NO;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.moneyTextFieldDelegate respondsToSelector:@selector(bx_moneyTextFieldShouldBeginEditing:)])
    {
        [self.moneyTextFieldDelegate bx_moneyTextFieldShouldBeginEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.moneyTextFieldDelegate respondsToSelector:@selector(bx_moneyTextFieldDidBeginEditing:)])
    {
        [self.moneyTextFieldDelegate bx_moneyTextFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.moneyTextFieldDelegate respondsToSelector:@selector(bx_moneyTextFieldShouldEndEditing:)])
    {
        [self.moneyTextFieldDelegate bx_moneyTextFieldShouldEndEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.moneyTextFieldDelegate respondsToSelector:@selector(bx_moneyTextFieldDidEndEditing:)])
    {
        [self.moneyTextFieldDelegate bx_moneyTextFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //光标偏移量
    NSInteger offset = textField.text.length - range.location - range.length;
    
    //如果第一位输入的是'.',则直接在点前面补一个0
    if (isEmptyString(textField.text) && [string isEqualToString:@"."])
    {
        textField.text = @"0.";
    }
    
    //拼接后的文本
    NSString *nowText = [self appendMoneyText:textField moneyTextChangRange:range chageText:string];
    
    //将逗号替换掉
    NSString *replacedText;
    if ([textField.text rangeOfString:@","].location != NSNotFound)
    {
        replacedText = [nowText stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    else
    {
        replacedText = nowText;
    }
    
    //将逗号替换掉
    if ([textField.text rangeOfString:@","].location != NSNotFound)
    {
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    
    BOOL result;
    if (![CheckToolsClass validateMoney:replacedText] && replacedText.length > 0)
    {
        result = NO;
    }
    else
    {
        result = YES;
    }
    
    if ([self.moneyTextFieldDelegate respondsToSelector:@selector(bx_moneyTextField:shouldChangeCharactersInRange:replacementString:nowText:checkResult:)])
    {
        [self.moneyTextFieldDelegate bx_moneyTextField:textField shouldChangeCharactersInRange:range replacementString:string nowText:replacedText checkResult:result];
    }
    
    NSString *curruntText = result ? replacedText : textField.text;
    
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    format.numberStyle = NSNumberFormatterDecimalStyle;
    format.minimumIntegerDigits = 1;
    if ([curruntText rangeOfString:@"."].location != NSNotFound)
    {
        NSString *sufText = [curruntText substringFromIndex:[curruntText rangeOfString:@"."].location + 1];
        format.maximumFractionDigits = sufText.length;
        format.minimumFractionDigits = sufText.length;
    }
    
    if (curruntText.length > 0)
    {
        NSString *formatText = [format stringFromNumber:[NSDecimalNumber decimalNumberWithString:curruntText]];
        
        textField.text = formatText;
        
        UITextPosition *currentStart = textField.selectedTextRange.start;
        UITextPosition *start = [textField positionFromPosition:currentStart inDirection:UITextLayoutDirectionLeft offset:offset];
        [textField setSelectedTextRange:[textField textRangeFromPosition:start toPosition:start]];
    }
    else
    {
        textField.text = curruntText;
    }
    
    //format完成之后点会消失，如果最后一位是点拼上
    if (([string isEqualToString:@"."] && [textField.text rangeOfString:@"."].location == NSNotFound) || ([curruntText hasSuffix:@"."] && [textField.text rangeOfString:@"."].location == NSNotFound))
    {
        textField.text = [textField.text stringByAppendingString:@"."];
    }
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.moneyTextFieldDelegate respondsToSelector:@selector(bx_moneyTextFieldShouldClear:)])
    {
        return [self.moneyTextFieldDelegate bx_moneyTextFieldShouldClear:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.moneyTextFieldDelegate respondsToSelector:@selector(bx_moneyTextFieldShouldReturn:)])
    {
        return [self.moneyTextFieldDelegate bx_moneyTextFieldShouldReturn:textField];
    }
    
    return YES;
}

#pragma mark - private mothods
- (NSString *)appendMoneyText:(UITextField *)moneyTextField moneyTextChangRange:(NSRange)range chageText:(NSString *)text
{
    NSString *nowText;
    if (isEmptyString(text))
    {
        NSString *preText;
        NSString *sufText;
        if (range.length == 0)
        {
            if (range.location == 0)
            {
                preText = @"";
                sufText = moneyTextField.text.length > 0 ? [moneyTextField.text substringFromIndex:range.location + range.length + 1] : @"";
            }
            else
            {
                preText = [moneyTextField.text substringToIndex:range.location - 1];
                sufText = [moneyTextField.text substringFromIndex:range.location + range.length];
            }
        }
        else
        {
            preText = [moneyTextField.text substringToIndex:range.location];
            sufText = [moneyTextField.text substringFromIndex:range.location + range.length];
        }
        
        
        nowText = [preText stringByAppendingString:sufText];
    }
    else
    {
        NSString *preText = [moneyTextField.text substringToIndex:range.location];
        NSString *sufText = [moneyTextField.text substringFromIndex:range.location + range.length];
        nowText = [NSString stringWithFormat:@"%@%@%@",preText,text,sufText];
    }
    
    return nowText;
}

@end

@implementation CheckToolsClass

+ (BOOL)validateMoney:(NSString *)money
{
    NSString *moneyRegex = @"^([1-9][\\d]{0,7}|0|)(\\.[\\d]{0,2})?$";
    NSPredicate *moneyTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",moneyRegex];
    return [moneyTest evaluateWithObject:money];
}

@end
