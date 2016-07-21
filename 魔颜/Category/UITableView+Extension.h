//
//  UITableView+Extension.h
//  魔颜
//
//  Created by Meiyue on 16/4/9.
//  Copyright © 2016年 Meiyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Extension)

/**
 *  快速创建tableView
 *
 *  @param frame    tableView的frame
 *  @param delegate 代理
 *
 *  @return 返回一个自定义的tableView
 */
+ (UITableView *)initWithTableView:(CGRect)frame withDelegate:(id)delegate;
+ (UITableView *)initWithGroupTableView:(CGRect)frame withDelegate:(id)delegate;

@end
