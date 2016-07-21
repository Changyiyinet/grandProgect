//
//  PaymentModel.h
//  魔颜
//
//  Created by Meiyue on 16/7/6.
//  Copyright © 2016年 Meiyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//支付宝
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "Order.h"
//微信
#import "payRequsestHandler.h"
#import "WXApiObject.h"
#import "WXApi.h"

//支付宝支付
#define KWXPayNoti  @""
#define KPartner    @""
#define KSeller     @""
#define KPrivateKey @""


//=============================================================


//微信支付
//更改商户把相关参数后可测试
//==============================================================
#define WXAPP_ID          @"wxee3be451dbc68260" //APPID
#define WXAPP_SECRET      @"" //appsecret
//商户号，填写商户对应参数
#define WXMCH_ID          @"1283314201"
//商户API密钥，填写相应参数
#define WXPARTNER_ID      @""
//支付结果回调页面
#define WXNOTIFY_URL      @"http://wxpay.weixin.qq.com/pub_v2/pay/notify.v2.php"
//获取服务器端支付数据地址（商户自定义）
#define WXSP_URL          @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php"

#define BASE_URL @"https://api.weixin.qq.com"

typedef void (^RequestSuccessAndResponseStringBlock)(NSString *string);
typedef enum {
    KPaymentZhiFuBao,
    KPaymentWeiXin
}KPaymentType;


@protocol PaymentModelDelegate <NSObject>

-(void)paySuccessWithType:(KPaymentType)paymentType;

@end


@interface PaymentModel : NSObject

/**
 *  使用block进行回调
 */
@property (nonatomic,assign)id<PaymentModelDelegate>delegate;

@property (nonatomic,copy)RequestSuccessAndResponseStringBlock successBlock;

/**
 *  单例模式
 */
+ (PaymentModel *)defaultPayInstance;

/**
 *  支付宝支付
 */
- (void)zhiFubaoPayWithMoney:(NSString *)money productName:(NSString*)name productDesc:(NSString*)productDesc;

/**
 *  微信支付
 */
- (void)weiXinPayWithMoney:(NSString *)money productName:(NSString*)productName productID:(NSString *)productID;


/**
 *  支付成功时候的回调
 */
-(void)paySuccessWithBlock:(RequestSuccessAndResponseStringBlock)payBlock;


@end
