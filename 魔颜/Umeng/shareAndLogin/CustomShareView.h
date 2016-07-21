//
//  CustomShareView.h
//  CustomShareStyle
//
//  Created by ljw on 16/6/2.
//  Copyright © 2016年 ljw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocial.h"

typedef void(^ShareBlock)(UMSocialSnsType shareType);

@interface CustomShareView : UIView

@property (copy, nonatomic) ShareBlock shereBlock;

@property(nonatomic,strong)UIView    *shareListView;
@property(nonatomic,strong)UIControl *huiseControl;

- (void)showInView:(UIView *) view;
- (void)hideInView;



@end
