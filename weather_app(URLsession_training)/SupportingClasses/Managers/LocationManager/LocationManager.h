//
//  LocationManager.h
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 10.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (assign,nonatomic) CLLocationCoordinate2D lastUserLocationCoordinate;

+ (instancetype)sharedManager;

- (void)updateUserLocationWithCompletion:(void(^)(CLLocationCoordinate2D coordinate, NSError *error))completion;

@end
