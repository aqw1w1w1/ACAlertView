//
//  ViewController.m
//  ACAlertView
//
//  Created by Archer on 16/8/5.
//  Copyright © 2016年 AVIC. All rights reserved.
//

#import "ViewController.h"
#import "ACAlertView.h"

@interface ViewController ()<ACAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Action

- (IBAction)alertViewAction:(UIButton *)sender {
    ACAlertView *alertView = [[ACAlertView alloc] initWithDelegate:self];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(950.0 / 3, 633.0 / 3)}];
    imageView.image = [UIImage imageNamed:@"T-ara.jpg"];
    alertView.contentView = imageView;
    
    alertView.buttonTitles = @[@"关闭", @"确定"];
    
    [alertView show];
    NSLog(@"主分支修改");
}

#pragma mark - ACAlertViewDelegate

- (void)alertView:(nullable ACAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex:%ld", (long)buttonIndex);
    [alertView dismiss];
}

@end
