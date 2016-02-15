//
//  NSString+NSMutableString.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 12.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "NSString+NSMutableAttributedString.h"

@implementation NSString (NSMutableString)

- (NSMutableAttributedString *)titleStringAppendToString:(NSString *)dataString
{
    if (!dataString) {
        dataString = @" - ";
    }
    
    NSString *fullString = [NSString stringWithFormat:@"%@%@",self,dataString];
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc]initWithString:fullString];
    
    UIColor *titleColor = [UIColor colorWithWhite:0.9f alpha:0.8f];
    UIFont *titleFont = [UIFont boldSystemFontOfSize:15.f];
    
    UIColor *dataColor = [UIColor colorWithWhite:1.f alpha:1.f];
    UIFont *dataFont = [UIFont systemFontOfSize:19.f];
    
    NSDictionary *attributesTitle = @{NSForegroundColorAttributeName: titleColor,
                                      NSFontAttributeName : titleFont};
    NSDictionary *attributesData = @{NSForegroundColorAttributeName: dataColor,
                                     NSFontAttributeName : dataFont};
    
    [mutableString addAttributes:attributesTitle range:[fullString rangeOfString:self]];
    [mutableString addAttributes:attributesData range:[fullString rangeOfString:dataString]];
    
    return mutableString;
}

@end
