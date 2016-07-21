//
//  CustomShareView.m
//  CustomShareStyle
//
//  Created by ljw on 16/6/2.
//  Copyright © 2016年 ljw. All rights reserved.
//

#import "CustomShareView.h"

#define UIBounds [[UIScreen mainScreen] bounds] //window外框大小
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]


@implementation CustomShareView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        _huiseControl=[[UIControl alloc]initWithFrame:CGRectMake(0, 0, UIBounds.size.width, UIBounds.size.height)];
        _huiseControl.backgroundColor=RGBACOLOR(0, 0, 0, 0.4);
        [_huiseControl addTarget:self action:@selector(huiseControlClick) forControlEvents:UIControlEventTouchUpInside];
        _huiseControl.alpha=0;
        self.backgroundColor = [UIColor whiteColor];
        
        
        _shareListView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIBounds.size.width, 191)];
        _shareListView.backgroundColor = RGBACOLOR(255, 255, 255, 1);
        [self addSubview:_shareListView];
        
        
        
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, UIBounds.size.width, 20)];
        title.textColor = RGBACOLOR(0, 0, 0,1);
        title.font = [UIFont systemFontOfSize:20];
        title.textAlignment = NSTextAlignmentCenter;
        title.text = @"分享";
        [_shareListView addSubview:title];
        
        
        CGFloat leftPading = 24;
        CGFloat space = (UIBounds.size.width-24*2-48*4)/3;
        CGFloat width = 48;
        NSArray *titleArray = @[@"微信好友",@"朋友圈",@"QQ",@"QQ空间"];
        
        for (int i=0; i<4; i++) {
            
            UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
            shareButton.frame = CGRectMake(leftPading+(width+space)*i, title.frame.origin.y+title.frame.size.height+20, width, width);
            NSString *imageName = [NSString stringWithFormat:@"shareList%d",i+1];
            [shareButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            [_shareListView addSubview:shareButton];
            
            
            UILabel *shareLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftPading+(width+space)*i, shareButton.frame.origin.y+shareButton.frame.size.height+8, width, 14)];
            shareLabel.textColor = RGBACOLOR(0, 0, 0, 1);
            shareLabel.font = [UIFont systemFontOfSize:12];
            shareLabel.text = [titleArray objectAtIndex:i];
            shareLabel.textAlignment = NSTextAlignmentCenter;
            [_shareListView addSubview:shareLabel];
            
            
            CGFloat shareControlWidth = 90;
            if (i==0 || i==3) {
                
                shareControlWidth = leftPading+width+space/2;
                
            }else
            {
                shareControlWidth = width+space;
            }
            
            UIControl *shareControl = [[UIControl alloc]initWithFrame:CGRectMake(0+(leftPading+width+space/2)*i, shareButton.frame.origin.y-12, shareControlWidth, 12+48+8+14+12)];
            [_shareListView addSubview:shareControl];
            [shareControl addTarget:self action:@selector(shareControl:) forControlEvents:UIControlEventTouchUpInside];
            
            if (i == 0) {
                shareControl.tag = UMSocialSnsTypeWechatSession;
            }else if (i == 1){
                shareControl.tag = UMSocialSnsTypeWechatTimeline;
            }else if (i == 2){
                shareControl.tag = UMSocialSnsTypeMobileQQ;
            }else{
                shareControl.tag = UMSocialSnsTypeQzone;
            }
            
        }
        
        
    }
    return self;
}


- (void)showInView:(UIView *) view {
    if (self.isHidden) {
        self.hidden = NO;
        if (_huiseControl.superview==nil) {
            [view addSubview:_huiseControl];
        }
        [UIView animateWithDuration:0.2 animations:^{
            _huiseControl.alpha=1;
        }];
        CATransition *animation = [CATransition  animation];
        animation.delegate = self;
        animation.duration = 0.2f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromTop;
        [self.layer addAnimation:animation forKey:@"animation1"];
        self.frame = CGRectMake(0,view.frame.size.height - 155, UIBounds.size.width, 155);
        [view addSubview:self];
    }
}


- (void)hideInView {
    
    if (!self.isHidden) {
        self.hidden = YES;
        CATransition *animation = [CATransition  animation];
        animation.delegate = self;
        animation.duration = 0.2f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromBottom;
        [self.layer addAnimation:animation forKey:@"animtion2"];
        [UIView animateWithDuration:0.2 animations:^{
            _huiseControl.alpha=0;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据responseCode得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
    
}

- (void)shareControl:(UIControl *)sender
{
    if(self.shereBlock != nil) self.shereBlock((UMSocialSnsType )sender.tag);
    
    [self hideInView];

}

-(void)huiseControlClick{
    [self hideInView];
}


@end

