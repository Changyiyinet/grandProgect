//
//  AppDelegate.m
//  魔颜
//
//  Created by Meiyue on 16/7/6.
//  Copyright © 2016年 Meiyue. All rights reserved.
//

#import "AppDelegate.h"
#import "APPHeader.h"
#import "ViewController.h"

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 1 创建window
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 2.设置根控制器
    UINavigationController *Nav = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc] init]];
    self.window.rootViewController = Nav;
    
    //3. 成为主窗口并显示
    [self.window makeKeyAndVisible];
    
    //4. 分享和支付
    [self settingUMSocialShareAndThirdPay];
    
    //5 极光推送
    [JPush registerRemotePushService:application withOptions:launchOptions];
    
    return YES;
}

//分享功能
- (void)settingUMSocialShareAndThirdPay{
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:UmengAppKey];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址(注意点:回调和白名单)
    [UMSocialWechatHandler setWXAppId:WXAPPID appSecret:WXAPPsecret url:WXUrl];
    
     //集成新浪
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:SinaAppKey
            secret:SinaAPPsecret  RedirectURL:SinaRedirecUrl];
    
    //QQ和QQ空间
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:QQAppKey url:QQUrl];
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    
    //1.导入微信支付SDK，注册微信支付
    //2.设置微信APPID为URL Schemes,iOS 9需要在“Info.plist”中添加白名单
    //3.导入微信支付依赖的类库，发起支付，调起微信支付(导入客户端进行签名文件,官方已经不提供这个SDK的下载了)
    //4.处理支付结果
    [WXApi registerApp:WXAPPID withDescription:@"ios weixin pay demo"];
    
}

#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg;
        
        switch (resp.errCode) {
                
            case WXSuccess:
                strMsg = @"支付结果：成功！";
                [[NSNotificationCenter defaultCenter] postNotificationName:KWXPayNoti object:@"success"];
                break;
                
            case WXErrCodeUserCancel://WXErrCodeCommon     = -1,
            {
                strMsg = @"已取消支付";
                [[NSNotificationCenter defaultCenter] postNotificationName:KWXPayNoti object:@"cancel"];
            }
                break;

                
            default:
                 strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                 [[NSNotificationCenter defaultCenter] postNotificationName:KWXPayNoti object:@"fail"];
                break;
        }
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            NSLog(@"result = %@",resultDic);
        }];
    }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            NSLog(@"result = %@",resultDic);
        }];
    }
    
    //微信支付回调
    if ([url.host isEqualToString:@"pay"]) {
        
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    //这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
    BOOL result = [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
    }
    
    return result;
   
}

/**
 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
 */
- (void)applicationDidBecomeActive:(UIApplication *)application{
    [UMSocialSnsService  applicationDidBecomeActive];
}

//上传设备token到推送服务器
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    [JPush registerDeviceToken:deviceToken];
    
}

//iOS7+
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    [JPush handleRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

//iOS7-
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [JPush handleRemoteNotification:userInfo];
}

//接收本地通知时触发
- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    
    [JPush handleLocalNotificationForRemotePush:notification];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
//进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}
//进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
