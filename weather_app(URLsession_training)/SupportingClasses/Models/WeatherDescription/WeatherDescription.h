//
//  WeatherDescription.h
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 11.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

@interface WeatherDescription : NSObject

@property (copy, nonatomic) NSString *imageLink;

@property (copy, nonatomic) NSString *place;
@property (copy, nonatomic) NSString *date;
@property (copy, nonatomic) NSString *weather;
@property (copy, nonatomic) NSString *humidity;
@property (copy, nonatomic) NSString *windSpeed;
@property (copy, nonatomic) NSString *temperature;

@property (strong, nonatomic) NSMutableArray <WeatherDescription *> *forecastList;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
