//
//  UIColor+AppColor.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 14.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "UIColor+AppColor.h"

@implementation UIColor (AppColor)

+ (UIColor *)applicationLightGreenColor
{
    return [UIColor colorWithRed:118.f/255.f green:200.f/255.f blue:182.f/255.f alpha:1.0f];
}

+ (UIColor *)applicationMildGreenColor
{
    return [UIColor colorWithRed:107.f/255.f green:186.f/255.f blue:190.f/255.f alpha:1.0f];
}

+ (UIColor *)applicatioRegularGreenColor
{
    return [UIColor colorWithRed:62.f/255.f green:185.f/255.f blue:190.f/255.f alpha:1.0f];
}

+ (UIColor *)applicationSaturatedGreenColor
{
    return [UIColor colorWithRed:61.f/255.f green:172.f/255.f blue:167.f/255.f alpha:1.0f];
}

@end
