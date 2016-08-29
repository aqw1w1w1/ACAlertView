//
//  ACAlertView.m
//  ACAlertView
//
//  Created by Archer on 16/8/5.
//  Copyright © 2016年 AVIC. All rights reserved.
//

#import "ACAlertView.h"

#define ScreenWidth     [UIScreen mainScreen].bounds.size.width
#define ScreenHeight    [UIScreen mainScreen].bounds.size.height

const static CGFloat kACAlertViewDefaultButtonHeight            = 50.f;   //按钮默认高度
const static CGFloat kACAlertViewDefaultButtonSpacing           = 2.f;    //内容视图和按钮/按钮之间的高度 的默认间隔
const static CGFloat kACAlertViewCornerRadius                   = 8.f;    //按钮的圆角边大小

@interface ACAlertView ()

@property (strong, nonatomic) UIView *containerView; //弹出框的容器view（包含内容视图和按钮）
@property (assign, nonatomic) CGFloat buttonHeight; //按钮高度
@property (assign, nonatomic) CGFloat buttonSpacing; //按钮与上边视图的间隔高度

@property (weak, nonatomic) id<ACAlertViewDelegate> delegate;

@end

@implementation ACAlertView

/**
 *  初始化方法
 *
 *  @param delegate 委托对象
 *
 *  @return 实例
 */
- (nullable id)initWithDelegate:(nullable id<ACAlertViewDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _delegate = delegate;
        
        //注册通知监听设备方向变化（注册通知前需要先调用beginGeneratingDeviceOrientationNotifications，当然结束时也需要调用endGeneratingDeviceOrientationNotifications）
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [self initView];
    }
    
    return self;
}

- (void)initView {
    [self setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    //当shouldRasterize = YES：layer渲染成bitmap，渲染引擎缓存此bitmap，下次就可以直接读取(如果我们更新已光栅化的layer,会造成大量的offscreen渲染,因此CALayer的光栅化选项的开启与否需要我们仔细衡量使用场景。只能用在图像内容不变的前提下。如：TableViewCell的重绘是很频繁的（因为Cell的复用）,如果Cell的内容不断变化,则Cell需要不断重绘,如果此时设置了cell.layer可光栅化。则会造成大量的offscreen渲染,降低图形性能。)
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    //添加手势（点击灰色处关闭弹出框）
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    [window addGestureRecognizer:tapGesture];
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 重写

- (void)setButtonTitles:(NSArray *)buttonTitles {
    _buttonTitles = buttonTitles;
    [self setButtonAttribute];
}

#pragma mark - 通知

- (void)orientationDidChange:(NSNotification *)notification {
    id s = notification.object;
    NSLog(@"%@", s);
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
}

#pragma mark - 外部调用

/**
 *  显示弹出框
 */
- (void)show {
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    [window addSubview:self];
    
    _containerView = [self createContainerView];
    [self addSubview:_containerView];
    
    //如果外部没有设置弹出框内容视图（按钮上边的内容）
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }
    [_containerView addSubview:_contentView];
    
    //添加按钮与内容视图的分隔线
    [_containerView addSubview:[self createSeparateLine]];
    //添加按钮
    [self createButton];
    
    _containerView.layer.opacity = 0.5f;
    _containerView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
        _containerView.layer.opacity = 1.0f;
        _containerView.layer.transform = CATransform3DMakeScale(1, 1, 1);
        
    } completion:^(BOOL finished) {
        
    }];
}

/**
 *  关闭弹出框
 */
- (void)dismiss {
    CATransform3D currentTransform = _containerView.layer.transform;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat startRotation = [[_containerView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
        _containerView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    }
    
    _containerView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionCurlUp
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         _containerView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         _containerView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         
                         [self removeFromSuperview];
                     }
     ];
}

#pragma mark - 逻辑处理

/**
 *  创建弹出框容器view(包括内容视图和按钮)
 *
 *  @return 创建好的view
 */
- (UIView *)createContainerView {
    CGSize screenSize = [self getScreenSize];
    CGSize containerSize = [self getContainerSize];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - containerSize.width) / 2, (screenSize.height - containerSize.height) / 2, containerSize.width, containerSize.height)];
    containerView.backgroundColor = [UIColor whiteColor];
    
//    containerView.layer.cornerRadius = kACAlertViewCornerRadius;
//    containerView.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
//    containerView.layer.borderWidth = 1;
//    containerView.layer.shadowRadius = kACAlertViewCornerRadius + 5;
//    containerView.layer.shadowOpacity = 0.1f;
//    containerView.layer.shadowOffset = CGSizeMake(0 - (kACAlertViewCornerRadius + 5) / 2, 0 - (kACAlertViewCornerRadius + 5) / 2);
//    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
//    containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:containerView.bounds cornerRadius:containerView.layer.cornerRadius].CGPath;
//    containerView.layer.shouldRasterize = YES;
//    containerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    return containerView;
}

/**
 *  创建内容视图和按钮之间的分割线
 */
- (UIView *)createSeparateLine {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _containerView.bounds.size.height - _buttonHeight - _buttonSpacing, _containerView.bounds.size.width, _buttonSpacing)];
    lineView.backgroundColor = [UIColor colorWithRed:198.0 / 255.0 green:198.0 / 255.0 blue:198.0 / 255.0 alpha:1.0f];
    return lineView;
}

/**
 *  创建按钮
 */
- (void)createButton {
    if (_buttonTitles == nil) {
        return;
    }
    
    CGFloat buttonWidth = (_containerView.bounds.size.width - _buttonSpacing * _buttonTitles.count) / _buttonTitles.count;
    
    for (int i = 0; i < _buttonTitles.count; i++) {
        //创建按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat x = i * (buttonWidth + _buttonSpacing);
        [button setFrame:CGRectMake(x, _containerView.bounds.size.height - _buttonHeight, buttonWidth, _buttonHeight)];
        [button setTag:i];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button.layer setCornerRadius:kACAlertViewCornerRadius];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:_buttonTitles[i] forState:UIControlStateNormal];
        [_containerView addSubview:button];
    }
    
    //创建按钮之间的间隔
    for (int i = 0; i < _buttonTitles.count - 1; i++) {
        CGRect separatorFrame = CGRectMake((i + 1) * buttonWidth + i * _buttonSpacing , _containerView.bounds.size.height - _buttonHeight, _buttonSpacing, _buttonHeight);
        UIView *separatorView = [[UIView alloc] initWithFrame:separatorFrame];
        separatorView.backgroundColor = [UIColor colorWithRed:198.0 / 255.0 green:198.0 / 255.0 blue:198.0 / 255.0 alpha:1.0f];
        [_containerView addSubview:separatorView];
    }
}

/**
 *  设置下边按钮的默认高度以及它与上边视图的间隔
 */
- (void)setButtonAttribute {
    if (_buttonTitles != nil && [_buttonTitles count] > 0) {
        _buttonHeight = kACAlertViewDefaultButtonHeight;
        _buttonSpacing = kACAlertViewDefaultButtonSpacing;
    }
    else {
        _buttonHeight = 0;
        _buttonSpacing = 0;
    }
}

/**
 *  获取屏幕大小（兼容横竖屏）
 *
 *  @return 屏幕大小
 */
- (CGSize)getScreenSize {
    CGFloat screenWidth = ScreenWidth;
    CGFloat screenHeight = ScreenHeight;
    
    // On iOS7, screen width and height doesn't automatically follow orientation
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            CGFloat tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
        }
    }
    
    return CGSizeMake(screenWidth, screenHeight);
}

/**
 *  获取弹出框容器view的大小
 *
 *  @return 实际大小
 */
- (CGSize)getContainerSize {
    CGFloat containerWidth = _contentView.frame.size.width;
    CGFloat containerHeight = _contentView.frame.size.height + _buttonHeight + _buttonSpacing;
    
    return CGSizeMake(containerWidth, containerHeight);
}

- (void)clickButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [_delegate alertView:self clickedButtonAtIndex:sender.tag];
    }
}

/**
 *  点击屏幕灰色处关闭弹出框
 *
 *  @param sender
 */
- (void)handletapPressGesture:(UITapGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
        //在window中的点击的坐标
        CGPoint locationInWindow = [sender locationInView:nil];
        //转换为_containerView坐标系
        CGPoint locationInContainer = [_containerView convertPoint:locationInWindow fromView:window];
        //当前点击的坐标是否在_containerView内
        BOOL flag = [_containerView pointInside:locationInContainer withEvent:nil];
        
        if (!flag) {
            [self dismiss];
            UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
            [window removeGestureRecognizer:sender];
        }
    }
}

@end
