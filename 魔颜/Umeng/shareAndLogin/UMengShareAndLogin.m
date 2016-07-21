//
//  UMengLogin.m
//  魔颜
//
//  Created by Meiyue on 16/7/6.
//  Copyright © 2016年 Meiyue. All rights reserved.
//

#import "UMengShareAndLogin.h"
#import "AppHeader.h"

@implementation UMengShareAndLogin

+(void)shareVC:(UIViewController *)vc  socalSnsType:(UMSocialSnsType)socalSnsType shareText:(NSString *)text shareImage:(UIImage *)image{
    
    [[UMSocialControllerService defaultControllerService] setShareText:text shareImage:image socialUIDelegate:nil];
   //分享平台
    if ((socalSnsType == UMSocialSnsTypeWechatTimeline) ||
        (socalSnsType == UMSocialSnsTypeWechatSession) ||
        (socalSnsType == UMSocialSnsTypeMobileQQ) ||
        (socalSnsType == UMSocialSnsTypeQzone)) {

        if ((text != nil) && (image != nil)) {
            
            [UMSocialData defaultData].extConfig.wechatSessionData.title = UmengShareTitle;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithFormat:@"www.baidu.com"];
            [UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithFormat:@"www.baidu.com"];

            [UMSocialData defaultData].extConfig.qqData.title = UmengShareTitle;
            [UMSocialData defaultData].extConfig.qqData.url = @"www.baidu.com";
            [UMSocialData defaultData].extConfig.qzoneData.url = @"www.baidu.com";

        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"抱歉" message:@"分享失败" delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
            [alertView show];

          }
        
    }
    
    UMSocialSnsPlatform *platform = [UMSocialSnsPlatformManager getSocialPlatformWithName:[UMSocialSnsPlatformManager getSnsPlatformString:(socalSnsType)]];
    platform.snsClickHandler(vc,[UMSocialControllerService defaultControllerService],YES);

}

+(void)login:(UMengLoginType)loginType vc:(UIViewController *)vc resBlock:(void(^)(UMSocialAccountEntity *snsAccount,UMengLoginType loginType))resBlock{
    
    if(loginType == UMengLoginTypeSina){//新浪
        
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
        
        snsPlatform.loginClickHandler(vc,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            
            if (response.responseCode == UMSResponseCodeSuccess) {
                
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
                
                if(resBlock != nil) resBlock(snsAccount,loginType);
            }
        });
        
    }else if (loginType == UMengLoginTypeQQ){//QQ
        
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
        
        snsPlatform.loginClickHandler(vc,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            
            if (response.responseCode == UMSResponseCodeSuccess) {
                
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
                
                if(resBlock != nil) resBlock(snsAccount,loginType);
                
            }
        });
        
    }else if (loginType == UMengLoginTypeWeiXin){//微信
        
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
        
        snsPlatform.loginClickHandler(vc,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            
            if (response.responseCode == UMSResponseCodeSuccess) {
                
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
                
                if(resBlock != nil) resBlock(snsAccount,loginType);
                
            }
         });
    }
    
}

+(void)authorLogin:(UMengLoginType)loginType resBlock:(void(^)(UMSocialResponseEntity *response))resBlock{
    
    //得到的数据在回调Block对象形参respone的data属性
    [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
        
        if(resBlock != nil) resBlock(response);

    }];

}


@end
