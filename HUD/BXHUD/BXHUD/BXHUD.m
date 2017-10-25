//
//  BXHUD.m
//  BXHUD
//
//  Created by 李良明 on 2017/6/19.
//  Copyright © 2017年 李良明. All rights reserved.
//

#import "BXHUD.h"

#import <ImageIO/ImageIO.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define FONT_SYSTEM(obj) [UIFont fontWithName:@"Helvetica" size:obj]
#define UIColorFromRGB(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

static NSMutableDictionary *_gifImageDict;

@implementation BXHUD

+ (void)showBXCompeleteHUDToView:(UIView *)view text:(NSString *)text showTime:(NSTimeInterval)duration compelete:(void (^)(BOOL))compelete
{
    NSString *labelText = text.length > 0 ? text : @"成功";
    
    [self initBXHUDToView:view imageName:@"toast_icon_yes" text:labelText showTime:duration compelete:compelete];
}

+ (void)showBXFailHUDToView:(UIView *)view text:(NSString *)text showTime:(NSTimeInterval)duration compelete:(void (^)(BOOL))compelete
{
    NSString *labelText = text.length > 0 ? text : @"失败";
    
    [self initBXHUDToView:view imageName:@"toast_icon_fail" text:labelText showTime:duration compelete:compelete];
}

+ (void)showBXLoadingHUDToView:(UIView *)view text:(NSString *)text showTime:(NSTimeInterval)duration compelete:(void(^)(BOOL finished))compelete
{
    NSString *labelText = text.length > 0 ? text : @"加载中";
    
    [self initBXHUDToView:view imageName:@"toast_icon_loading" text:labelText showTime:duration compelete:compelete];
}

+ (void)initBXHUDToView:(UIView *)view imageName:(NSString *)imageName text:(NSString *)text showTime:(NSTimeInterval)duration compelete:(void(^)(BOOL finished))compelete
{
    if (!view) return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor clearColor];
    hud.backgroundView.backgroundColor = [UIColor clearColor];
    
    UIImage *image = [UIImage imageNamed:@"toast_icon_bg"];
    CGSize baseSize = image.size;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.bounds = CGRectMake(0, 0, baseSize.width, baseSize.height);
    hud.customView = imageView;
    
    UIImage *compeleteImage = [UIImage imageNamed:imageName];
    CGSize compeleteSize = compeleteImage.size;
    UIImageView *compeleteImageView = [[UIImageView alloc] initWithImage:compeleteImage];
    if([imageName isEqualToString:@"toast_icon_loading"])
    {
        compeleteImageView.frame = CGRectMake((baseSize.width - compeleteSize.width) / 2, 50, compeleteSize.width, compeleteSize.height);
    }
    else
    {
        compeleteImageView.frame = CGRectMake((baseSize.width - compeleteSize.width) / 2, 30, compeleteSize.width, compeleteSize.height);
    }
    
    [imageView addSubview:compeleteImageView];
    
    UILabel *label = [[UILabel alloc] init];
    if([imageName isEqualToString:@"toast_icon_loading"])
    {
        label.frame = CGRectMake(5, 55 + compeleteSize.height, baseSize.width - 10, baseSize.height - 60 - compeleteSize.height);
    }
    else
    {
        label.frame = CGRectMake(5, 35 + compeleteSize.height, baseSize.width - 10, baseSize.height - 40 - compeleteSize.height);
    }
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = FONT_SYSTEM(15);
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [imageView addSubview:label];
    
    NSTimeInterval durationTime = duration > 0 ? duration : 1;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(durationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [hud hideAnimated:YES];
        if(compelete)
        {
            compelete(YES);
        }
    });
}

+ (void)showBXGIFHUDToView:(UIView *)view GIFImageName:(NSString *)imageName animateDuration:(NSTimeInterval)duration text:(NSString *)text
{
    if (!view) return;
    
    if (!_gifImageDict)
    {
        _gifImageDict = [[NSMutableDictionary alloc] init];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor clearColor];
    hud.backgroundView.backgroundColor = [UIColor clearColor];
    
    UIImage *image = [UIImage imageNamed:@"toast_icon_bg"];
    CGSize baseSize = image.size;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.bounds = CGRectMake(0, 0, baseSize.width, baseSize.height);
    hud.customView = imageView;
    
    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(46.5, 30, 51, 51)];
    
    if (!_gifImageDict[imageName])
    {
        NSArray *imageArray = [self praseGIFDataToImageArray:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],imageName]]];
        gifImageView.animationImages = imageArray;
        
        _gifImageDict[imageName] = imageArray;
    }
    else
    {
        gifImageView.animationImages = _gifImageDict[imageName];
    }
    gifImageView.animationDuration = duration;
    [gifImageView startAnimating];
    [imageView addSubview:gifImageView];
    
    NSString *labelText = text.length > 0 ? text : @"加载中";
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 86, 134, 53)];
    label.text = labelText;
    label.textColor = [UIColor whiteColor];
    label.font = FONT_SYSTEM(15);
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [imageView addSubview:label];
}

+ (void)showBXDefaultGIFHUDToView:(UIView *)view animateDuration:(NSTimeInterval)duration text:(NSString *)text
{
    if (!view) return;
    
    if (!_gifImageDict)
    {
        _gifImageDict = [[NSMutableDictionary alloc] init];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor clearColor];
    hud.backgroundView.backgroundColor = [UIColor clearColor];
    
    UIImage *image = [UIImage imageNamed:@"toast_icon_bg"];
    CGSize baseSize = image.size;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.bounds = CGRectMake(0, 0, baseSize.width, baseSize.height);
    hud.customView = imageView;
    
    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 143, 143)];
    if (!_gifImageDict[@"DefaultLoading"])
    {
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        for (int i = 0; i <= 30; i ++)
        {
            UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Rocket_%d",[[NSBundle mainBundle] resourcePath],i]];
            if (image)
            {
                [imageArray addObject:image];
            }
        }
        
        _gifImageDict[@"DefaultLoading"] = imageArray;
        gifImageView.animationImages = imageArray;
    }
    else
    {
        gifImageView.animationImages = _gifImageDict[@"DefaultLoading"];
    }
    gifImageView.animationDuration = duration;
    [gifImageView startAnimating];
    [imageView addSubview:gifImageView];
    
    NSString *labelText = text.length > 0 ? text : @"加载中";
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 114, 134, 11)];
    label.text = labelText;
    label.textColor = [UIColor whiteColor];
    label.font = FONT_SYSTEM(11);
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [imageView addSubview:label];
}

+ (void)showBXNormalHUDToView:(UIView *)view text:(NSString *)text compelete:(void (^)(BOOL))compelete
{
    if (!view) return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = UIColorFromRGB(0x000000, 0.85);
    hud.label.text = text;
    hud.label.textColor = [UIColor whiteColor];
    hud.label.numberOfLines = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [hud hideAnimated:YES];
        if(compelete)
        {
            compelete(YES);
        }
    });
}


+ (void)hideBXHUDForView:(UIView *)view
{
    if (!view) return;
    
    [MBProgressHUD hideHUDForView:view animated:YES];
}

//将gif转换为图片数组
+ (NSMutableArray *)praseGIFDataToImageArray:(NSData *)data;
{
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    CGFloat animationTime = 0.f;
    if (src)
    {
        size_t l = CGImageSourceGetCount(src);
        frames = [NSMutableArray arrayWithCapacity:l];
        for (size_t i = 0; i < l; i++)
        {
            CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, i, NULL));
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            animationTime += [delayTime floatValue];
            
            if (img)
            {
                [frames addObject:[UIImage imageWithCGImage:img]];
                CGImageRelease(img);
            }
        }
        
        CFRelease(src);
    }
    
    return frames;
}

@end
