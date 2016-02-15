//
//  LocationManager.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 10.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "LocationManager.h"

typedef void(^CompletionCoordinateBlock)(CLLocationCoordinate2D coordinate, NSError *error);

@interface LocationManager ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (copy, nonatomic) CompletionCoordinateBlock completionCoordinateBlock;

@end

@implementation LocationManager

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        self.locationManager.distanceFilter = 5000;
        [self.locationManager requestWhenInUseAuthorization];
    }
    return self;
}

- (void)dealloc
{
    self.locationManager = nil;
}

#pragma mark - Public

+ (instancetype)sharedManager
{
    static LocationManager *locationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [[LocationManager alloc]init];
    });
    
    return locationManager;
}

- (void)updateUserLocationWithCompletion:(void (^)(CLLocationCoordinate2D, NSError *))completion
{
    [self.locationManager startUpdatingLocation];
    self.completionCoordinateBlock = completion;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self.locationManager stopUpdatingLocation];
    
    CLLocation *location = [locations lastObject];
    self.lastUserLocationCoordinate = location.coordinate;
    
    if (location && self.completionCoordinateBlock) {
        self.completionCoordinateBlock(location.coordinate,nil);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    CLLocationCoordinate2D nullCoordinate = {0,0};
    if (error) {
        self.completionCoordinateBlock(nullCoordinate,error);
    }
    
    [self.locationManager stopUpdatingLocation];
}

@end
