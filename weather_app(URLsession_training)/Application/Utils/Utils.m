//
//  Utils.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 10.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (void)presentAlertControllerWithController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:okButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [controller presentViewController:alert animated:YES completion:nil];
    });
}

+ (void)prepareShadowForView:(UIView *)view
{
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 10.f;
    view.layer.shadowOpacity = 0.3f;
    view.layer.masksToBounds = NO;
}

@end
