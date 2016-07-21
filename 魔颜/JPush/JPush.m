//
//  JPush.m
//  test2
//
//  Created by Meiyue on 15/12/26.
//  Copyright © 2016年 Meiyue. All rights reserved.
//

#import "JPush.h"

static NSString *appKey = @"45bd79eed1f85316ccfbe90e";
static NSString *channel = @"Publish channel";
static BOOL isProduction = FALSE;

static JPush* manager = nil;

@implementation JPush

+(JPush *)shareManager
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[JPush alloc] init];
    });
    return manager;
}

/**
 *  注册极光推送
 *
 */
+(void)registerRemotePushService:(UIApplication *)application withOptions:(NSDictionary *)launchOptions{
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)   categories:nil];
    }
    else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)  categories:nil];
    }
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    
    //获取自定义消息推送内容
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    [JPUSHService setLogOFF];
    
}

+ (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    // 1. 个人中心tabBar显示小圆点
    
    // 2. 个人中心界面"我发布的"显示小圆点
    
    // 3. 后台图标上显示未读数
    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    
}

+(void)registerDeviceToken:(NSData *)deviceToken{
     [JPUSHService registerDeviceToken:deviceToken];
}

+(void)handleRemoteNotification:(NSDictionary *)userInfo{
    [JPUSHService handleRemoteNotification:userInfo];
    
}

+(void)handleRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"恭喜您收到来自魔颜网的消息:%@", [self logDic:userInfo]);
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {// 激活状态，用户正在使用App
        
          }
    else if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){//(不激活状态，用户切换到其他App、按Home键回到桌面、拉下通知中心,点击某条消息)
        
        }else{
            
        }
    
    // 1. 个人中心tabBar显示小圆点
    // 2. 个人中心界面"我的消息"显示小圆点
    
    completionHandler(UIBackgroundFetchResultNewData);
}

+ (void)handleLocalNotificationForRemotePush:(UILocalNotification *)notification{
    
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        

    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
    }

}

+ (void)setAlias:(NSString *)alias{

    [JPUSHService setAlias:alias
          callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                    object:self];
}

//  极光推送注册服务回掉函数
+ (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias{
    
    NSString *callbackString =
    [NSString stringWithFormat:@"%d, \ntags: %@, \nalias: %@\n", iResCode,
    [self logSet:tags], alias];
    NSLog(@"TagsAlias回调:%@", callbackString);

}

+ (NSString *)logSet:(NSSet *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    
    [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    
    return str;
}

+ (NSString *)logDic:(NSDictionary *)dic {
    
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

- (NSString *)modeString
{
#if DEBUG
    [JPUSHService setLogOFF];
    return @"Development (sandbox)";
#else
    return @"Production";
#endif
}


@end
