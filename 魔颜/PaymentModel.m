//
//  PaymentModel.m
//  魔颜
//
//  Created by Meiyue on 16/7/6.
//  Copyright © 2016年 Meiyue. All rights reserved.
//

#import "PaymentModel.h"

@implementation PaymentModel

-(instancetype)init{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getOrderPayResult:) name:KWXPayNoti object:nil];
    }
    return self;
}

#pragma mark -创建单例模式
+ (PaymentModel *)defaultPayInstance{
    static PaymentModel *instance = nil;
    @synchronized(self) {
        if (instance == nil) {
            instance = [[PaymentModel alloc] init];
        }
    }
    return instance;
}

-(void)paySuccessWithBlock:(RequestSuccessAndResponseStringBlock)payBlock{
    
    self.successBlock = payBlock;
}

- (void)zhiFubaoPayWithMoney:(NSString *)money productName:(NSString*)productName productDesc:(NSString*)productDesc {
    
    //支付宝支付
    //1.在调用支付宝支付之前，需要我们将相关订单参数发送至我们的后台服务器，由后台服务器进行签名等处理，并返回客户端所有相关参数，客户端直接使用参数调起支付宝支付。
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */

    NSString *partner = KPartner;
    NSString *seller = KSeller;
    NSString *privateKey = KPrivateKey;//不要在客户端保存

    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        [PaymentModel alert:@"提示" msg:@"缺少partner或者seller或者私钥"];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.sellerID = seller;
    order.outTradeNO = [PaymentModel generateTradeNO]; //订单ID（由商家自行制定）
    order.subject = productName; //商品标题
    order.body = productDesc; //商品描述
    order.totalFee = money; //商品价格
    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"alisdkdemo";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
     //应用注册scheme,在AlixPayDemo-Info.plist定义URL types // appScheme：商户自己的协议头
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            NSLog(@"reslut = %@",resultDic);
            
            //充值成功之后返回
            NSString *result =  resultDic[@"result"];
            NSArray *resultArr = [result componentsSeparatedByString:@"&"];
            BOOL isSuccess = false;
            for (NSString *successStr in resultArr) {
                
                if ([successStr hasPrefix:@"success"]&&[successStr containsString:@"true"]) {
                    isSuccess = YES;
                }
            }
            if([resultDic[@"resultStatus"] integerValue] == 9000 && isSuccess){//支付成功
                [PaymentModel alert:@"恭喜" msg:@"您已成功支付啦!"];
                //通知后台支付成功,通过block的方法传递参数值
                self.successBlock(@"1");

            }else if([resultDic[@"resultStatus"] isEqualToString:@"6001"]){
            
                [PaymentModel alert:@"提示" msg:@"用户取消支付"];
            }else{
                
                [PaymentModel alert:@"提示" msg:@"支付失败"];
            }

        }];
    }

}

- (void)weiXinPayWithMoney:(NSString *)money productName:(NSString*)productName productID:(NSString *)productID{
    
    if (![WXApi isWXAppInstalled]) {
        
        [PaymentModel alert:@"提示" msg:@"没有安装微信"];
        return;
    }
    else if (![WXApi isWXAppSupportApi]){
        
        [PaymentModel alert:@"提示" msg:@"不支持微信支付"];
        return;
    }
    
    //本实例只是演示签名过程， 请将该过程在商户服务器上实现
    
    //创建支付签名对象
    payRequsestHandler *req = [payRequsestHandler alloc];
    
    //初始化支付签名对象
    [req init:APP_ID mch_id:MCH_ID];
    //设置密钥
    [req setKey:PARTNER_ID];
    
    //订单标题，展示给用户
//    NSString *order_name    = @"moyanwang";
    
    float  pri = [money floatValue] * 100;
    //订单金额,单位（分）
    NSString *order_price   = [NSString stringWithFormat:@"%.0f",pri];
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req sendPay_demo:order_price orderName:productName oder:productID];
    
    if(dict == nil){
        //错误提示
        NSString *debug = [req getDebugifo];
        
        [PaymentModel alert:@"提示信息" msg:debug];
        
    }else{
        
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        [WXApi sendReq:req];
        
    }
}

#pragma mark -微信支付成功之后的代理方法
- (void)getOrderPayResult:(NSNotification *)notification{
    
    if ([notification.object isEqualToString:@"success"])
    {
        [PaymentModel alert:@"恭喜" msg:@"您已成功支付啦!"];
        self.successBlock(@"2");
        
    }
    else if ([notification.object isEqualToString:@"cancel"])
    {
        [PaymentModel alert:@"提示" msg:@"用户取消支付"];
        
    }else{
        [PaymentModel alert:@"提示" msg:@"支付失败"];
    }
}

#pragma mark -客户端提示信息
+ (void)alert:(NSString *)title msg:(NSString *)msg{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alter show];
}

#pragma mark   ==============产生随机订单号==============
+ (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


#pragma mark -移除观察者
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KWXPayNoti object:nil];
}



@end
