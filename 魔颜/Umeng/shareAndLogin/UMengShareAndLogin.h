//
//  UMengLogin.h
//  魔颜
//
//  Created by Meiyue on 16/7/6.
//  Copyright © 2016年 Meiyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UMSocial.h"

typedef enum {
    
    UMengLoginTypeSina,
    UMengLoginTypeQQ,
    UMengLoginTypeWeiXin
    
}UMengLoginType;


@interface UMengShareAndLogin : NSObject

@property (assign, nonatomic) UMSocialSnsType socalSnsType;

/** 分享图片和文字 */
+(void)shareVC:(UIViewController *)vc  socalSnsType:(UMSocialSnsType)socalSnsType shareText:(NSString *)text shareImage:(UIImage *)image;


/** 登陆前的授权 */
+(void)authorLogin:(UMengLoginType)loginType resBlock:(void(^)(UMSocialResponseEntity *response))resBlock;


/** 点击登录 */
+(void)login:(UMengLoginType)loginType vc:(UIViewController *)vc resBlock:(void(^)(UMSocialAccountEntity *snsAccount,UMengLoginType loginType))resBlock;


@end
