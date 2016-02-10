//
//  Constants.h
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 28.01.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#pragma mark - DLog

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

static NSString *const LINK_COORDINATE_SEARCH_WEATHER = @"http://api.openweathermap.org/data/2.5/forecast?lat={}&lon={}&appid=802605eed9934b3c4e0a133a7953fd76";

static NSString *const LINK_IMAGE_WEATHER = @"http://openweathermap.org/img/w/";

