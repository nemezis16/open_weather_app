//
//  LoaderViewController.m
//  Loader_test
//
//  Created by Roman Osadchuk on 25.01.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "LoaderViewController.h"

const CGFloat sizeForLabel = 15.f;

@interface LoaderViewController ()

@property (strong, nonatomic) UIView *loaderHolderView;
@property (strong, nonatomic) UILabel *labelMessage;
@property (strong, nonatomic) UIColor *dotColor;
@property (assign, nonatomic) CGFloat sizeForLoader;
@property (assign, nonatomic) CGFloat speed;
@property (assign, nonatomic) NSInteger countOfDots;
@property (assign, nonatomic) BOOL animationAdded;

@end

@implementation LoaderViewController
@synthesize  backgroundColor = _backgroundColor, messageFont = _messageFont, textColor = _textColor;

#pragma mark - LifeCycle

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self chooseRectForLoader];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addLoaderHolderView];
    [self addDotTriangleAnimationToView:self.loaderHolderView];
}

#pragma mark - Accessors

- (CGFloat)speed
{
    return _speed ? _speed : 0.8f;
}

- (CGFloat)sizeForLoader
{
    return _sizeForLoader ? _sizeForLoader : 150.f;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.loaderHolderView.backgroundColor = _backgroundColor;
}

- (UIColor *)backgroundColor
{
    UIColor *defaultColor = [UIColor colorWithRed:255.f/255.f green:241.f/255.f blue:247.f/255.f alpha:0.7f];
    
    return _backgroundColor ? _backgroundColor : defaultColor;
}

- (UIColor *)dotColor
{
    return _dotColor ? _dotColor : [UIColor yellowColor];
}

- (NSInteger)countOfDots
{
    return _countOfDots ? _countOfDots : 3;
}

- (void)setMessageFont:(UIFont *)messageFont
{
    _messageFont = messageFont;
    self.labelMessage.font = _messageFont;
}

- (UIFont *)messageFont
{
    UIFont *defaultFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:sizeForLabel];
    
    return _messageFont ? _messageFont : defaultFont;
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    [self chooseRectForLoader];
    self.labelMessage.text ? (self.labelMessage.text = message) : [self configureLabel];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.labelMessage.textColor = _textColor;
}

- (UIColor *)textColor
{
    UIColor *defaultColor = [UIColor colorWithRed:74.f/255.f green:64.f/255.f blue:107.f/255.f alpha:0.9f];
    
    return _textColor ? _textColor : defaultColor;
}

#pragma mark - Public

+ (LoaderViewController *)presentLoaderFromController:(UIViewController *)controller animated:(BOOL)animated complition:(void (^)(void))complition
{
    LoaderViewController *loaderController = [LoaderViewController new];
    
    if (animated) {
        loaderController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        loaderController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    [controller presentViewController:loaderController animated:animated completion:complition];
    
    return loaderController;
}

+ (void)dismissLoaderViewControllerFromController:(UIViewController *)controller animated:(BOOL)animated complition:(void (^)(void))complition
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [controller dismissViewControllerAnimated:animated completion:complition];
    });
}

- (void)setSizeForLoader:(CGFloat)size animationSpeed:(CGFloat)speed countOfDots:(NSInteger)count dotColor:(UIColor *)color
{
    self.sizeForLoader = size;
    self.speed = speed;
    self.countOfDots = count;
    self.dotColor = color;
    
    [self recreateLoaderIfNeeded];
}

#pragma mark - Private

#pragma mark - LabelMethods

- (void)configureLabel
{
    CGRect labelFrame = CGRectMake(5, CGRectGetWidth(self.loaderHolderView.bounds) - sizeForLabel, CGRectGetWidth(self.loaderHolderView.bounds) - 5, sizeForLabel);
    
    self.labelMessage = [[UILabel alloc] initWithFrame:labelFrame];
    self.labelMessage.textAlignment = NSTextAlignmentCenter;
    self.labelMessage.adjustsFontSizeToFitWidth = YES;
    self.labelMessage.minimumScaleFactor = 0.5f;
    self.labelMessage.font = self.messageFont;
    self.labelMessage.textColor = self.textColor;
    self.labelMessage.text = self.message;
    
    [self.loaderHolderView addSubview:self.labelMessage];
}

#pragma mark - LoaderViewMethods

- (void)addLoaderHolderView
{
    self.loaderHolderView = [self loaderHolderViewWithSize:self.sizeForLoader];
    self.loaderHolderView.layer.cornerRadius = 20.f;
    [self.view addSubview:self.loaderHolderView];
    
    [self configureLabel];
}

- (UIView *)loaderHolderViewWithSize:(CGFloat)size
{
    self.loaderHolderView = [UIView new];
    [self chooseRectForLoader];
    self.loaderHolderView.backgroundColor = self.backgroundColor;
    
    return self.loaderHolderView;
}

- (void)recreateLoaderIfNeeded
{
    if (self.animationAdded) {
        [self.loaderHolderView removeFromSuperview];
        [self addLoaderHolderView];
        [self addDotTriangleAnimationToView:self.loaderHolderView];
    }
}

- (void)chooseRectForLoader
{
    CGRect defaultRect = [self loaderRectWithSize:self.sizeForLoader];
    CGRect rectWithMessage = [self loaderRectWithSize:self.sizeForLoader message:self.message];
    
    self.loaderHolderView.frame = self.message ? rectWithMessage : defaultRect;
}

- (CGRect)loaderRectWithSize:(CGFloat)size
{
    CGFloat screenCenterX = CGRectGetMidX([UIScreen mainScreen].bounds);
    CGFloat screenCenterY = CGRectGetMidY([UIScreen mainScreen].bounds);
    
    CGFloat loaderHolderX = screenCenterX - size / 2;
    CGFloat loaderHolderY = screenCenterY - size / 2;
    
    return CGRectMake(loaderHolderX, loaderHolderY, size, size);
}

- (CGRect)loaderRectWithSize:(CGFloat)size message:(NSString *)message
{
    CGRect rectForLoader = [self loaderRectWithSize:size];
    UIEdgeInsets insetsForLabel = UIEdgeInsetsMake(0.f, 0.f, -sizeForLabel, 0.f);
    
    return UIEdgeInsetsInsetRect(rectForLoader, insetsForLabel);
}

#pragma mark - Animations

- (void)addDotTriangleAnimationToView:(UIView *)view
{
    CGFloat size = view.bounds.size.width;
    CGRect frameForReplicator = CGRectMake(0, 0, size, size);
    
    CAShapeLayer *dot = [self dotWithFrame:CGRectMake(size * 0.15f, size * 0.15f, size * 0.2f, size * 0.2f)];
    CAReplicatorLayer *replicatorLayer = [self replicatorLayerWithFrame:frameForReplicator];
    [replicatorLayer addSublayer:dot];
    [view.layer addSublayer:replicatorLayer];
    
    NSArray *animations = @[[self scaleAnimation],[self translateAnimationWithTransform:size * 0.3f]];
    CAAnimationGroup *groupAnimation = [self groupAnimationWithAnimations:animations];
    [dot addAnimation:groupAnimation forKey:nil];
    [replicatorLayer addAnimation:[self rotationAnimation] forKey:nil];
    
    self.animationAdded = YES;
}

- (CAAnimationGroup *)groupAnimationWithAnimations:(NSArray *)animations
{
    CAAnimationGroup *groupAnimation = [CAAnimationGroup new];
    groupAnimation.animations = animations;
    groupAnimation.duration = self.speed;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.autoreverses = YES;
    groupAnimation.repeatCount = HUGE_VALF;
    
    return groupAnimation;
}

- (CABasicAnimation *)translateAnimationWithTransform:(CGFloat)transform
{
    CABasicAnimation *translateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D transformTranslate = CATransform3DTranslate(CATransform3DIdentity, transform, transform, 0.f);
    translateAnimation.toValue = [NSValue valueWithCATransform3D:transformTranslate];
    translateAnimation.removedOnCompletion = NO;
    translateAnimation.autoreverses = YES;
    translateAnimation.repeatCount = HUGE_VALF;
    translateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translateAnimation.duration = self.speed;
    
    return translateAnimation;
}

- (CABasicAnimation *)scaleAnimation
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    CATransform3D transform = CATransform3DScale(CATransform3DIdentity, 0.f, 0.f, 0.f);
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:transform];
    scaleAnimation.duration = 1.f;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.repeatCount = HUGE_VALF;
    
    return scaleAnimation;
}

- (CABasicAnimation *)rotationAnimation
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @(0);
    rotationAnimation.toValue = @(2 * M_PI);
    rotationAnimation.duration = 2.f;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    return rotationAnimation;
}

#pragma mark - LayersMethods

- (CAShapeLayer *)dotWithFrame:(CGRect)frame
{
    CAShapeLayer *dot = [CAShapeLayer new];
    dot.frame = frame;
    dot.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, frame.size.width, frame.size.width)].CGPath;
    dot.fillColor = self.dotColor.CGColor;
    dot.opacity = 0.8f;
    
    return dot;
}

- (CAReplicatorLayer *)replicatorLayerWithFrame:(CGRect)frame
{
    CGFloat angleToRotate = 2 * M_PI / self.countOfDots;
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer new];
    replicatorLayer.backgroundColor = [UIColor clearColor].CGColor;
    replicatorLayer.frame = frame;
    replicatorLayer.instanceCount = self.countOfDots;
    replicatorLayer.instanceTransform = CATransform3DMakeRotation(angleToRotate, 0.f, 0.f, 1.f);
    replicatorLayer.instanceColor = [UIColor redColor].CGColor;
    replicatorLayer.instanceBlueOffset = 1.5f / self.countOfDots;
    replicatorLayer.instanceRedOffset = 1.5f / self.countOfDots;
    replicatorLayer.instanceGreenOffset = 1.5f / self.countOfDots;
    
    return replicatorLayer;
}

@end
