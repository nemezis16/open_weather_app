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
#import "LocationManager.h"
#import "WeatherDescription.h"
#import "ForecastViewController.h"
#import "NSString+NSMutableAttributedString.h"
#import "NSDictionary+WeatherLink.h"
#import "OpenWeatherConstants.h"

@interface InfoWeatherViewController () 

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *weatherDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *weatherIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;
@property (weak, nonatomic) IBOutlet UIButton *forecastButton;

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) CLLocationCoordinate2D userCoordinate;
@property (assign, nonatomic) BOOL isUserLocation;

@property (strong, nonatomic) SessionManager *sessionManager;
@property (strong, nonatomic) LoaderViewController *loaderViewController;
@property (strong, nonatomic) WeatherDescription *weatherDescription;

@end

@implementation InfoWeatherViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.coordinate = CLLocationCoordinate2DMake(1, 1);
    [self isUserLocation];
    [self prepareShadowForView:self.mapView];
    
    self.forecastButton.enabled = NO;
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
        [self updateUserLocation];
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
    [self dismissLoader];
    
    [self setNewCoordinate:userLocation.coordinate];
    self.userCoordinate = userLocation.coordinate;
    [self isUserLocation];
    
    self.mapView.showsUserLocation = NO;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [Utils presentAlertControllerWithController:self title:@"Error" message:[error localizedDescription]];
}

#pragma mark - Private

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *forecastControllerIdentifier = NSStringFromClass([ForecastViewController class]);
    if ([segue.identifier isEqualToString:forecastControllerIdentifier]) {
        ForecastViewController *forecastController = (ForecastViewController *)[segue destinationViewController];
        forecastController.title = self.weatherDescription.place;
        forecastController.forecastList = self.weatherDescription.forecastList;
    }
}

#pragma mark - Appearance

- (void)prepareShadowForView:(UIView *)view
{
    [Utils prepareShadowForView:view];
    
    view.layer.shadowOffset = CGSizeMake(0, -10);
}

#pragma mark - LocationMethods

- (void)updateUserLocation
{
    self.mapView.showsUserLocation = YES;
    
    [[LocationManager sharedManager] updateUserLocationWithCompletion:^(CLLocationCoordinate2D coordinate, NSError *error) {
        if (error) {
            [Utils presentAlertControllerWithController:self title:@"Error" message:[error localizedDescription]];
        } else {
            self.coordinate = coordinate;
            [self presentLoader];
        }
    }];
}

- (NSURL *)linkForCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *linkPart = LinkCoordinateSearchWeather;
    
    NSString *latKey = @"lat";
    NSString *lonKey = @"lon";
    NSString *appIdKey = @"appid";
    
    NSString *coordinateLatitudeString = [NSString stringWithFormat:@"%.2f",coordinate.latitude];
    NSString *coordinateLongitudeString = [NSString stringWithFormat:@"%.2f",coordinate.longitude];
    
    NSDictionary *linkDictionary = @{latKey : coordinateLatitudeString,
                                     lonKey : coordinateLongitudeString,
                                     appIdKey : AppID};
    
    NSURL *link = [linkDictionary linkForDictionaryWithLinkPart:linkPart arrangementKeys:@[latKey,lonKey,appIdKey]];
    
    return link;
}

- (void)setNewCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.forecastButton.enabled = YES;
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05f, 0.05f);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
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
            [Utils presentAlertControllerWithController:strongSelf title:@"Error" message:[error localizedDescription]];
        }
    }];
}

#pragma mark - ParsingMethods

- (void)setValuesFromDictionary:(NSDictionary *)dictionary
{
     self.weatherDescription = [[WeatherDescription alloc]initWithDictionary:dictionary];
    [self setWeatherDescription];
    [self setImage];
}

- (void)setWeatherDescription
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]init];
        NSMutableAttributedString *place = [@"Place: "titleStringAppendToString:self.weatherDescription.place];
        NSMutableAttributedString *weather = [@"\nWeather: "titleStringAppendToString:self.weatherDescription.weather];
        NSMutableAttributedString *date = [@"\nDate: "titleStringAppendToString:self.weatherDescription.date];
        NSMutableAttributedString *humidity = [@"\nHumidity: "titleStringAppendToString:[NSString stringWithFormat:@"%@", self.weatherDescription.humidity]];
        NSMutableAttributedString *windSpeed = [@"\nWindSpeed: "titleStringAppendToString:[NSString stringWithFormat:@"%@", self.weatherDescription.windSpeed]];
        NSMutableAttributedString *temperature = [@"\nTemperature: "titleStringAppendToString:[NSString stringWithFormat:@"%@", self.weatherDescription.temperature]];
        
        [attributedText appendAttributedString:place];
        [attributedText appendAttributedString:weather];
        [attributedText appendAttributedString:temperature];
        [attributedText appendAttributedString:date];
        [attributedText appendAttributedString:humidity];
        [attributedText appendAttributedString:windSpeed];
        
        strongSelf.weatherDescriptionTextView.attributedText = attributedText;
    });
}

- (void)setImage
{
    NSString *rawImageLink = self.weatherDescription.imageLink;
    if (rawImageLink) {
        NSString *linkToImageString = [[LinkImageWeather stringByAppendingString:rawImageLink]stringByAppendingString:@".png"];
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
}

#pragma mark - LoaderPresentation

- (void)presentLoader
{
    if (!self.loaderViewController) {
        self.loaderViewController = [LoaderViewController presentLoaderFromController:self animated:YES complition:nil];
        self.loaderViewController.message = @"Wait...Loading";
    }
}

- (void)dismissLoader
{
    [LoaderViewController dismissLoaderViewControllerFromController:self animated:YES complition:nil];
    self.loaderViewController = nil;
}

@end