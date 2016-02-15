//
//  NSDictionary+WeatherLink.h
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 15.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

@interface NSDictionary (WeatherLink)

- (NSURL *)linkForDictionaryWithLinkPart:(NSString *)linkPart arrangementKeys:(NSArray *)keys;

@end
