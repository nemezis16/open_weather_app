//
//  InfoWeatherViewController.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 27.01.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "InfoWeatherViewController.h"
#import "LocationViewController.h"
#import "SessionManager.h"

@interface InfoWeatherViewController () 

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *weatherDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *weatherIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) SessionManager *sessionManager;

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) CLLocationCoordinate2D userCoordinate;

@property (assign, nonatomic) BOOL isUserLocation;

@end

@implementation InfoWeatherViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self getUserLocation];
}

#pragma mark - Accessors

- (BOOL)isUserLocation
{
    if (self.coordinate.latitude != self.userCoordinate.latitude &&
        self.coordinate.longitude != self.userCoordinate.longitude) {
        [self.checkBoxButton setImage:[UIImage imageNamed:@"emptyCheckBox"] forState:UIControlStateNormal];
        return NO;
    } else {
          [self.checkBoxButton setImage:[UIImage imageNamed:@"checkBox"] forState:UIControlStateNormal];
        return YES;
    }
}

#pragma mark - IBActions

- (IBAction)mapViewTapped:(id)sender
{
    LocationViewController *locactionController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([LocationViewController class])];
    
    locactionController.willCloseMyController = ^(id data) {
        
    };
    
    __weak typeof(self) weakSelf = self;
    [locactionController pushControllerFromController:self withCoordinate:self.coordinate completion:^(CLLocationCoordinate2D returnedCoordinate) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf setNewCoordinate:returnedCoordinate];
        [strongSelf isUserLocation];
    }];
}

- (IBAction)userLocationButtonTapped:(id)sender
{
    if (!self.isUserLocation) {
        [self getUserLocation];
        [self setNewCoordinate:self.userCoordinate];
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *identifier = @"Identifier";
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (pin) {
        pin.annotation = annotation;
    } else {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        pin.pinTintColor = [UIColor redColor];
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
    }
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self setNewCoordinate:userLocation.coordinate];
    self.userCoordinate = userLocation.coordinate;
    [self isUserLocation];
    
    self.mapView.showsUserLocation = NO;
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    DLog(@"%@",[error localizedDescription]);
}

#pragma mark - Private

#pragma mark - LocationMethods

- (NSURL *)linkForCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *link = LINK_COORDINATE_SEARCH_WEATHER;
    
    CGFloat latitude = coordinate.latitude;
    CGFloat longitude = coordinate.longitude;
    NSString *latitudeString = [NSString stringWithFormat:@"%.2f",latitude];
    NSString *longitudeString = [NSString stringWithFormat:@"%.2f",longitude];
    
    NSInteger coordinateCounter = 0;
    for (int i = 0; i < link.length; i++) {
        NSString *character = [link substringWithRange:NSMakeRange(i, 1)];
        
        if ([character isEqualToString:@"}"]) {
            coordinateCounter++;
            switch (coordinateCounter) {
                case 1:
                    link = [link stringByReplacingCharactersInRange:NSMakeRange(i - 1, 2) withString:latitudeString];
                    break;
                case 2:
                    link = [link stringByReplacingCharactersInRange:NSMakeRange(i - 1, 2) withString:longitudeString];
                    break;
            }
        }
    }
    
    return [NSURL URLWithString:link];
}

- (void)getUserLocation
{
    self.mapView.showsUserLocation = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
//    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
//    }
}

- (void)setNewCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    MKCoordinateSpan span = {.latitudeDelta =  1.f, .longitudeDelta = 1.f};
    MKCoordinateRegion region = {coordinate, span};
    self.mapView.region = region;
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
    
    self.coordinate = coordinate;
    [self fetchDataWithCoordinate:coordinate];
}

#pragma mark - SessionMethods

- (void)fetchDataWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSURL *url = [self linkForCoordinate:coordinate];
    
    self.sessionManager = [SessionManager new];
    
    __weak typeof(self) weakSelf = self;
    [self.sessionManager fetchDataFromURL:url completion:^(NSData *data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (data) {
            NSDictionary *dictionary = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [strongSelf setValuesFromDictionary:dictionary];
        }
        if (error) {
            DLog(@"%@",[error localizedDescription]);
        }
    }];
}

#pragma mark - ParsingMethods

- (void)setValuesFromDictionary:(NSDictionary *)dictionary
{
    [self setInfoTextFromDictionary:dictionary];
    [self setImageFormDictionary:dictionary];
}

- (void)setInfoTextFromDictionary:(NSDictionary *)dictionary
{
    NSString *cityName = dictionary[@"city"][@"name"];
    NSDictionary *listDictionary = ((NSArray *)dictionary[@"list"]).firstObject;
    CGFloat windSpeed = [listDictionary[@"wind"][@"speed"] floatValue];
    NSString *date = listDictionary[@"dt_txt"];
    CGFloat humidity = [listDictionary[@"main"][@"humidity"] floatValue];
    CGFloat temperature = [listDictionary[@"main"][@"temp"] floatValue] - 273.15f;
    
    //[listDictionary valueForKey:@"main.temp"];
   //способ обратится -  listDictionary[@"main.temp"];
    
    NSDictionary *weatherDict = ((NSArray *)listDictionary[@"weather"]).firstObject;
    NSString *weatherDescrtiption = weatherDict[@"description"];
    
    NSString *preparedString = [NSString stringWithFormat:@"Place: %@\nDate: %@\nWeather: %@\nTemperature: %.2f\u00B0C\nHumidity: %.2f %%\nWind speed: %.2f m/s",cityName,date,weatherDescrtiption,temperature,humidity,windSpeed];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.weatherDescriptionTextView.text = preparedString;
    });
}

- (void)setImageFormDictionary:(NSDictionary *)dictionary
{
    NSDictionary *listDictionary = ((NSArray *)dictionary[@"list"]).firstObject;
    NSDictionary *weatherDict = ((NSArray *)listDictionary[@"weather"]).firstObject;
    NSString *weatherIcon = weatherDict[@"icon"];
    
    NSString *linkToImageString = [[LINK_IMAGE_WEATHER stringByAppendingString:weatherIcon]stringByAppendingString:@".png"];
    NSURL *imageURL = [NSURL URLWithString:linkToImageString];
    
    __weak typeof(self) weakSelf = self;
    [[SessionManager new] fetchDataFromURL:imageURL completion:^(NSData *data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.weatherIconImageView.image = [UIImage imageWithData:data];
            });
        } else {
            DLog(@"Image did not recieved");
        }
    }];
}

@end