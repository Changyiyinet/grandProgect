//
//  ImagePicker.m
//  DWImagePicker
//
//  Created by dwang_sui on 16/6/20.
//  Copyright © 2016年 dwang_sui. All rights reserved.
//

#import "ImagePicker.h"

//如果有Debug这个宏的话,就允许log输出...可变参数
#ifdef DEBUG
#define DWLog(...) NSLog(__VA_ARGS__)
#else
#define DWLog(...)
#endif


@implementation ImagePicker

static ImagePicker *sharedManager = nil;

+ (ImagePicker *)sharedManager {
    
    @synchronized (self) {
        
        if (!sharedManager) {
            
            sharedManager = [[[self class] alloc] init];
          }
    }
    
    return sharedManager;
}

#pragma mark ---设置根控制器 弹框添加视图位置 所需图片样式 默认为UIImagePickerControllerEditedImage
- (void)dwSetPresentDelegateVC:(id)vc SheetShowInView:(UIView *)view InfoDictionaryKeys:(NSInteger)integer {
    
    picker = [[UIImagePickerController alloc]init];
    
    picker.delegate = self;
    
    self.integer = integer;
    
    /**
     
     与导航栏类似，操作表单也支持三种风格 ：
     UIActionSheetStyleDefault              //默认风格：灰色背景上显示白色文字
     UIActionSheetStyleBlackTranslucent     //透明黑色背景，白色文字
     UIActionSheetStyleBlackOpaque          //纯黑背景，白色文字
     
     */
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消"  destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择",nil];

    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sheet showInView:view];
    
    picker.allowsEditing = YES;
    
    self.allowsEditing = picker.allowsEditing;
    
    self.vc = vc;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        self.typeStr = @"支持相机";
        
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        
        self.typeStr = @"支持图库";
        
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        
        self.typeStr = @"支持相片库";
        
    }
}

#pragma mark ---获取设备支持的类型与选中之后的图片
- (void)dwGetpickerTypeStr:(pickerTypeStr)pickerTypeStr pickerImagePic:(pickerImagePic)pickerImagePic {
    
    if (pickerTypeStr) {
        
        pickerTypeStr(self.typeStr);
        
    }
    
    self.pickerImagePic = ^(UIImage *image) {
        
        pickerImagePic(image);
        
    };
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
        UIImage *image = [[UIImage alloc] init];
        
        NSArray *array = @[@"UIImagePickerControllerMediaType",
                           @"UIImagePickerControllerOriginalImage",
                           @"UIImagePickerControllerEditedImage",
                           @"UIImagePickerControllerCropRect",
                           @"UIImagePickerControllerMediaURL",
                           @"UIImagePickerControllerReferenceURL",
                           @"UIImagePickerControllerMediaMetadata",
                           @"UIImagePickerControllerLivePhoto"];
        
        if (self.integer) {
            
            image = [info objectForKey:array[self.integer]];
            
        }else {
            
            image = [info objectForKey:array[2]];
            
        }
        
        if (self.pickerImagePic) {
            
            self.pickerImagePic(image);
            
        }
        
        [self.vc dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self.vc dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunicode-whitespace"
        
        [self.vc presentViewController:picker animated:YES completion:nil];
        
#pragma clang diagnostic pop
        
        
    }else if (buttonIndex == 1) {
        
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunicode-whitespace"
        
        [self.vc presentViewController:picker animated:YES completion:nil];
        
#pragma clang diagnostic pop
        
    }
    
}


@end
