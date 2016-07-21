//
//  UITableView+Extension.m
//  魔颜
//
//  Created by Meiyue on 16/4/9.
//  Copyright © 2016年 Meiyue. All rights reserved.
//

#import "UITableView+Extension.h"

@implementation UITableView (Extension)
/** 默认 */
+ (UITableView *)initWithTableView:(CGRect)frame withDelegate:(id)delegate
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.delegate = delegate;
    tableView.dataSource = delegate;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //将系统的Separator左边不留间隙
    tableView.separatorInset = UIEdgeInsetsZero;
    return tableView;
}

+ (UITableView *)initWithGroupTableView:(CGRect)frame withDelegate:(id)delegate
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.delegate = delegate;
    tableView.dataSource = delegate;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //将系统的Separator左边不留间隙
    tableView.separatorInset = UIEdgeInsetsZero;
    return tableView;
}

@end
