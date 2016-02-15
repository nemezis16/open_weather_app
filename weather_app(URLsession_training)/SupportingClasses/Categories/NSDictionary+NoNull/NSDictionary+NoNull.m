//
//  NSDictionary+NoNull.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 11.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "NSDictionary+NoNull.h"

@implementation NSDictionary (NoNull)

- (NSDictionary *)replaceNullValues
{
    NSMutableDictionary *mutableDictionary = [self mutableCopy];
    NSMutableArray *keysToDelete = [NSMutableArray array];
    [mutableDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass: [NSNull class]]) {
            [keysToDelete addObject:key];
        }
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [obj replaceNullValues];
        }
    }];
    [mutableDictionary removeObjectsForKeys:keysToDelete];
    
    return [mutableDictionary copy];
}

@end
