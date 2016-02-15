//
//  WeatherDescription.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 11.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "WeatherDescription.h"
#import "NSDictionary+NoNull.h"

@interface WeatherDescription ()

@property (strong, nonatomic) NSDictionary *rawDictionary;

@end

@implementation WeatherDescription

#pragma mark - Public

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.rawDictionary = dictionary;
        [self prepareObject];
    }
    return self;
}

#pragma mark - Private

- (void)prepareObject
{
    NSDictionary *dictionary = self.rawDictionary;
    dictionary = [dictionary replaceNullValues];
    self.place = dictionary[@"city"][@"name"];
    
    NSArray *rawForecastArray =  dictionary[@"list"];
    [self fillForecastForTimePeriod:rawForecastArray.firstObject];
    [self fillForecastListWithRawForecastArray:rawForecastArray];
}

- (void)fillForecastListWithRawForecastArray:(NSArray *)rawForecastArray
{
    self.forecastList = [NSMutableArray new];
    
    __weak typeof(self) weakSelf = self;
    [rawForecastArray enumerateObjectsUsingBlock: ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            WeatherDescription *weatherDescription = [WeatherDescription new];
            [weatherDescription fillForecastForTimePeriod:(NSDictionary *)obj];
            [strongSelf.forecastList addObject:weatherDescription];
        }
    }];
}

- (void)fillForecastForTimePeriod:(NSDictionary *)timePeriod
{
    self.windSpeed = [NSString stringWithFormat:@"%.2fm/s",[timePeriod[@"wind"][@"speed"] floatValue]];
    self.date = timePeriod[@"dt_txt"];
    self.humidity = [NSString stringWithFormat:@"%.f%%",[timePeriod[@"main"][@"humidity"] floatValue]];
    self.temperature = [NSString stringWithFormat:@"%.f\u00B0",[timePeriod[@"main"][@"temp"] floatValue] - 273.15f];
    
    NSDictionary *weatherDict = ((NSArray *)timePeriod[@"weather"]).firstObject;
    self.weather = weatherDict[@"description"];
    self.imageLink = weatherDict[@"icon"];
}

- (NSString *)description
{
    NSString *preparedString = [NSString stringWithFormat:@"Place: %@\nDate: %@\nWeather: %@\nTemperature: %@\u00B0C\nHumidity: %@ %%\nWind speed: %@ m/s",self.place,self.date,self.weather,self.temperature,self.humidity,self.windSpeed];
    
    return preparedString;
}

@end
