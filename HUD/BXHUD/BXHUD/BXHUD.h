//
//  BXHUD.h
//  BXHUD
//
//  Created by 李良明 on 2017/6/19.
//  Copyright © 2017年 李良明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define BIND_FAIL       @"绑定失败"
/* 上传失败 */
#define SET_FAIL        @"设置失败"

#define UPDATE_SUCCESS  @"修改成功"
#define UPDATE_FAIL     @"修改失败"
#define CHECK_FAIL      @"校验失败"
#define LOAD_FAIL       @"加载失败"

#define GIF_IMAGE       @"baixin.gif"

#define ERROR_TIP       @"小百只能精确到分哦，请确保输入的金额只有两位小数点"
#define RECOGITIONING   @"识别中..."
#define ERROR_TIP_1     @"请输入正确的手机号"
#define ERROR_MESSAGE_CODE @"输入有误"
#define AGREE_PROTOCOL_TIP @"请阅读并同意用户及相关服务协议"
#define CONFIRM_TITLE   @"收益说明"
#define CONFIRM_CONTENT @"收益以基金公司返回的金额为准，基金产品（货币基金产品除外），双休日及节假日无收益。"

#define GET_PASSWORD_KET_FAIL    @"获取秘钥失败，需要重新获取"
#define GET_AGIAN                @"重新获取"
#define RETURN_HOME              @"返回首页"    

#define ACCOUNT_OPEN     @"已开户"
#define AUTHORIZATION_FAIL       @"授权失败"

#define MODIFY_BINDCARD_HASBALANCE_TITLE        @"钱包还有余额"
#define MODIFY_BINDCARD_HASBALANCE_MESSAGE      @"监测到您当前总资产额不为0，为了保障您的资产安全建议您将资产转出至当前绑定银行卡 "
#define MODIFY_BINDCARD_GO_NOW     @"继续更换"
#define MODIFY_BINDCARD_CANCLE     @"前去转出"

#define RISK_ERROR_TIP             @"请先将答案填写完毕"

#define OPEN_ACCOUNT_TITLE        @"退出开户流程"
#define OPEN_ACCOUNT_MESSAGE      @"确定退出开户流程？这样系统将不会保存您已输入的信息。"
#define OPEN_ACCOUNT_GO_NOW     @"确定"
#define OPEN_ACCOUNT_CANCLE     @"取消"

@interface BXHUD : NSObject

/*
 * @describe      普通的等待图（延时消失）
 * @param         text       label的提示文字
 * @param         view       显示等待图的view
 */
+ (void)showBXNormalHUDToView:(UIView *)view text:(NSString *)text compelete:(void(^)(BOOL finished))compelete;

/*
 * @describe      展示GIF等待图
 * @param         imageName  gif图片的名称（全名）
 * @param         duration   一帧GIF的时间
 * @param         text       图片下方label的提示文字 默认是 加载中...
 * @param         view       显示等待图的view
 */
+ (void)showBXGIFHUDToView:(UIView *)view GIFImageName:(NSString *)imageName animateDuration:(NSTimeInterval)duration text:(NSString *)text;


/**
 默认gif图

 @param view      显示等待图的view
 @param duration  一帧GIF的时间
 @param text      图片下方label的提示文字 默认是 加载中...
 */
+ (void)showBXDefaultGIFHUDToView:(UIView *)view animateDuration:(NSTimeInterval)duration text:(NSString *)text;

/*
 * @describe      成功的等待图（延时消失）
 * @param         duration   显示的时间
 * @param         text       图片下方label的提示文字 默认是 成功
 * @param         view       显示等待图的view
 */
+ (void)showBXCompeleteHUDToView:(UIView *)view text:(NSString *)text showTime:(NSTimeInterval)duration compelete:(void(^)(BOOL finished))compelete;


/*
 * @describe      失败的等待图（延时消失）
 * @param         duration   显示的时间
 * @param         text       图片下方label的提示文字 默认是 失败
 * @param         view       显示等待图的view
 */
+ (void)showBXFailHUDToView:(UIView *)view text:(NSString *)text showTime:(NSTimeInterval)duration compelete:(void(^)(BOOL finished))compelete;

/*
 * @describe      加载中（延时消失）
 * @param         duration   显示的时间
 * @param         text       图片下方label的提示文字
 * @param         view       显示等待图的view
 */
+ (void)showBXLoadingHUDToView:(UIView *)view text:(NSString *)text showTime:(NSTimeInterval)duration compelete:(void(^)(BOOL finished))compelete;

/*
 * @describe      隐藏GIF等待图
 * @param         view       显示等待图的view
 */
+ (void)hideBXHUDForView:(UIView *)view;


@end
