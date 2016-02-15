//
//  WeatherAppNavigationController.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 11.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "WeatherAppNavigationController.h"

@implementation WeatherAppNavigationController

#pragma mark - LifeCycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureNavigationBarStyle];
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    [Utils prepareShadowForView:self.navigationBar];
}

#pragma mark - Private

- (void)configureNavigationBarStyle
{
    self.navigationBar.translucent = YES;
    [self setTintColors];
    [self setTitleTextAttributes];
}

- (void)setTintColors
{
    [UINavigationBar appearance].barTintColor = [UIColor applicatioRegularGreenColor];
    [UINavigationBar appearance].tintColor =[UIColor whiteColor];
}

- (void)setTitleTextAttributes
{
    UIColor *textColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:21.0];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
}

@end
