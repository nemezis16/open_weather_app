//
//  LoaderViewController.h
//  Loader_test
//
//  Created by Roman Osadchuk on 25.01.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

@interface LoaderViewController : UIViewController

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) UIFont *messageFont;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *textColor;

+ (LoaderViewController *)presentLoaderFromController:(UIViewController *)controller animated:(BOOL)animated complition:(void(^)(void))complition;

+ (void)dismissLoaderViewControllerFromController:(UIViewController *)controller animated:(BOOL)animated complition:(void (^)(void))complition;

- (void)setSizeForLoader:(CGFloat)size animationSpeed:(CGFloat)speed countOfDots:(NSInteger)count dotColor:(UIColor *)color;

@end
