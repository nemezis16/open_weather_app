//
//  Utils.h
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 10.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

@interface Utils : NSObject

+ (void)presentAlertControllerWithController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message;

+ (void)prepareShadowForView:(UIView *)view;

@end
