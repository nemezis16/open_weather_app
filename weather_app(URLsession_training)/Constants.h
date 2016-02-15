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


