//
//  ViewController.m
//  魔颜
//
//  Created by Meiyue on 16/7/6.
//  Copyright © 2016年 Meiyue. All rights reserved.
//

#import "ViewController.h"
#import "PaymentModel.h"
#import "UMengShareAndLogin.h"
#import "CLocationManager.h"
#import "ImagePicker.h"
#import "CustomShareView.h"
#import "UITableView+Extension.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 标题数组 */
@property (strong, nonatomic) NSArray *titles;

/** tableView */
@property (weak, nonatomic) UITableView *tableView;

@end

@implementation ViewController

- (NSArray *)titles{

    if (!_titles) {
        
        
        NSArray *first = @[@"分享"];
        NSArray *second = @[@"微博登陆",@"QQ登陆",@"WeChat登陆"];
        NSArray *third = @[@"微信支付",@"支付宝支付"];
        NSArray *fourth = @[@"定位",@"修改头像",@"web地图",@"百度地图"];
        
        _titles = @[first,second,third,fourth];
    }
    return _titles;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];

    
    UITableView *tableView = [UITableView initWithTableView:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height) withDelegate:self];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
    [[CLocationManager shareLocation] getAddress:^(NSString *addressString) {
        
        [self alert:addressString msg:@"当前详细地址"];
        
        self.title = addressString;

    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return self.titles.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.titles[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *str = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];

    }
    
    cell.textLabel.text = self.titles[indexPath.section][indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //分享
    if (indexPath.section == 0) {
        
        CustomShareView *customShareView = [[CustomShareView alloc]init];
        [self.view addSubview:customShareView];
        [customShareView showInView:self.view];
        
        customShareView.shereBlock = ^(UMSocialSnsType shareType){
            
            [UMengShareAndLogin shareVC:self socalSnsType:shareType shareText:self.title shareImage:[UIImage imageNamed:@"0708.jpg"]];
        
        };
        
    }
    //第三方登陆
    if (indexPath.section == 1) {
        
        [UMengShareAndLogin authorLogin:(int)indexPath.row resBlock:^(UMSocialResponseEntity *response) {
            
            NSLog(@"SnsInformation is %@",response.data);
            
        }];
        
        [UMengShareAndLogin login:(int)indexPath.row vc:self resBlock:^(UMSocialAccountEntity *snsAccount, UMengLoginType loginType) {
            
            NSLog(@"%@\n%u",snsAccount,loginType);
            
        }];

    }
    //移动支付
    if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            [[PaymentModel defaultPayInstance] weiXinPayWithMoney:@"998" productName:@"丰胸美白" productID:@"1467776973850_2"];
            
            [[PaymentModel defaultPayInstance] paySuccessWithBlock:^(NSString *string) {
                
                if ([string isEqualToString:@"2"]) {
                    NSLog(@"微信支付---");
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                
            }];

        }
        if (indexPath.row == 1) {
            
            [[PaymentModel defaultPayInstance]zhiFubaoPayWithMoney:@"0.01" productName:@"测试所用" productDesc:@"商品支付测试"];
            
            [[PaymentModel defaultPayInstance] paySuccessWithBlock:^(NSString *string) {
                if ([string isEqualToString:@"1"]) {
                    NSLog(@"支付宝支付---");
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];

        }
    }
    
    if (indexPath.section == 3) {
        //定位
        if (indexPath.row == 0) {
            //定位的城市
            [[CLocationManager shareLocation] getCity:^(NSString *cityString) {
                
                [self alert:cityString msg:@"当前定位的城市"];
                
            }];
            
        }
        //换头像
        if (indexPath.row == 1) {
            
            //设置主要参数
            [[ImagePicker sharedManager] dwSetPresentDelegateVC:self SheetShowInView:self.view InfoDictionaryKeys:(long)nil];
            
            //回调
            [[ImagePicker sharedManager] dwGetpickerTypeStr:^(NSString *pickerTypeStr) {
                
            } pickerImagePic:^(UIImage *pickerImagePic) {
               
                [tableView cellForRowAtIndexPath:indexPath].imageView.image = pickerImagePic;
                [tableView reloadData];
            
            }];

        }
        //以URI跳转的方式(URL Scheme)
        if (indexPath.row == 2) {
    

            NSString *searchStr = [@"s%26wd%3D" stringByAppendingString:self.title];
            NSString *urlString = [[NSString stringWithFormat:@"http://map.baidu.com/?newmap=1&ie=utf-8&s=%@",searchStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
        if (indexPath.row == 3) {
            
            
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 55;
}

#pragma mark -客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg{
    
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alter show];
}

/**
 *  这里最主要的代码,通过滑动,改变透明度
*/
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    self.navigationController.navigationBar.alpha = scrollView.contentOffset.y /70;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
