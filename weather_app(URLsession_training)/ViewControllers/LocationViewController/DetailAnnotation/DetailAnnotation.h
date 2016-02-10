//
//  DetailAnnotation.h
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 29.01.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//



@interface DetailAnnotation : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;

@end
