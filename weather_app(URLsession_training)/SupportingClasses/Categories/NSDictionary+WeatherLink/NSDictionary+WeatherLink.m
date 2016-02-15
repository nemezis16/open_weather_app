//
//  NSDictionary+WeatherLink.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 15.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "NSDictionary+WeatherLink.h"

@implementation NSDictionary (WeatherLink)

- (NSURL *)linkForDictionaryWithLinkPart:(NSString *)linkPart arrangementKeys:(NSArray *)keys
{
    NSString *keyPart = @"?";
    for (NSString *key in keys) {
        if ([keys.lastObject isEqualToString:key]) {
             keyPart = [keyPart stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,[self objectForKey:key]]];
            break;
        }
        keyPart = [keyPart stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,[self objectForKey:key]]];
    }
    NSString *fullLinkString =[linkPart stringByAppendingString:keyPart];
    NSURL *link = [NSURL URLWithString:fullLinkString];
    
    return link;
}

@end
