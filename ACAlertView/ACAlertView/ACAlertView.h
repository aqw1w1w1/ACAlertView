//
//  ACAlertView.h
//  ACAlertView
//
//  Created by Archer on 16/8/5.
//  Copyright © 2016年 AVIC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACAlertView;

@protocol ACAlertViewDelegate <NSObject>
@optional

/**
 *  点击弹出框按钮的回调
 *
 *  @param alertView   弹出框
 *  @param buttonIndex 选中的按钮下标
 */
- (void)alertView:(nullable ACAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface ACAlertView : UIView

/**
 *  弹出框显示的内容视图
 */
@property (strong, nonatomic, nullable) UIView *contentView;
/**
 *  按钮标题数组
 */
@property (strong, nonatomic, nullable) NSArray *buttonTitles;

/**
 *  初始化方法
 *
 *  @param delegate 委托对象
 *
 *  @return 实例
 */
- (nullable id)initWithDelegate:(nullable id<ACAlertViewDelegate>)delegate;

/**
 *  显示弹出框
 */
- (void)show;

/**
 *  关闭弹出框
 */
- (void)dismiss;

@end
