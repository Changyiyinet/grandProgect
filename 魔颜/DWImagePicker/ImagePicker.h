//
//  ImagePicker.h
//  DWImagePicker
//
//  Created by dwang_sui on 16/6/20.
//  Copyright © 2016年 dwang_sui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//最终获取到的图片
typedef void(^pickerImagePic)(UIImage *pickerImagePic);

//当前可选择类型
typedef void(^pickerTypeStr)(NSString *pickerTypeStr);


@interface ImagePicker : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>{
    
    UIImagePickerController *picker;
    
}

+ (ImagePicker *) sharedManager;

/*!
 *  @author dwang_sui, 16-06-21 23:06:11
 *
 *  @brief <#Description#>
 *
 *  @param vc       设置代理
 *  @param view     sheetView所要添加的视图
 *  @param infoKeys 需要的图片模式,nil为默认
 *
 *  @since <#version number#>
 */
- (void)dwSetPresentDelegateVC:(id)vc SheetShowInView:(UIView *)view InfoDictionaryKeys:(NSInteger)integer;

- (void)dwGetpickerTypeStr:(pickerTypeStr)pickerTypeStr pickerImagePic:(pickerImagePic)pickerImagePic;

@property (weak, nonatomic) id vc;

@property (assign, nonatomic) NSInteger integer;

@property (copy, nonatomic) NSString *typeStr;

@property (assign, nonatomic) BOOL allowsEditing;

@property (copy, nonatomic) pickerTypeStr pickerTypeStr;

@property (copy, nonatomic) pickerImagePic pickerImagePic;


@end
