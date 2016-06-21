//
//  LocationViewController.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 28.01.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "LocationViewController.h"
#import "DetailAnnotation.h"
#import "LocationManager.h"

typedef void (^CompletionBlock)(CLLocationCoordinate2D sdsdsdfdf);

static NSString *const PinIdentifier = @"pin_identifier";

@interface LocationViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) CompletionBlock completionBlock;

@property (strong, nonatomic) MKLocalSearch *localSearch;

@end

@implementation LocationViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Choose coordinate";
    self.searchBar.tintColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.completionBlock(self.coordinate);
}

#pragma mark - Public

- (void)pushControllerFromController:(UIViewController *)controller withCoordinate:(CLLocationCoordinate2D)coordinate completion:(void (^)(CLLocationCoordinate2D))completion
{
    [controller.navigationController pushViewController:self animated:YES];
    self.coordinate = coordinate;
    self.completionBlock = completion;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
    
    if (pin) {
        pin.annotation = annotation;
    } else {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
        pin.pinTintColor = [UIColor purpleColor];
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
    }
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if(newState == MKAnnotationViewDragStateEnding) {
        self.coordinate = view.annotation.coordinate;
        [self setLocationInformationWithAnnotation:view.annotation];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self startSearch:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Private

- (void)startSearch:(NSString *)searchString
{
    if (self.localSearch.searching) {
        [self.localSearch cancel];
    }
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(MKMapRectWorld);
    
    MKLocalSearchRequest *searchRequest = [MKLocalSearchRequest new];
    searchRequest.naturalLanguageQuery = searchString;
    searchRequest.region = region;
    
    self.localSearch = nil;
    
    self.localSearch = [[MKLocalSearch alloc]initWithRequest:searchRequest];
    
    __weak typeof(self) weakSelf = self;
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
                [strongSelf presentAlertControllerWithTitle:@"Could not find places" message:errorStr];
            });
        } else {
            [strongSelf.mapView removeAnnotations:strongSelf.mapView.annotations];
           
            MKMapItem *mapItem = [response mapItems].firstObject;
            strongSelf.coordinate = mapItem.placemark.coordinate;
            [strongSelf.mapView setCenterCoordinate:strongSelf.coordinate animated:YES];
            
            DetailAnnotation *annotation = [DetailAnnotation new];
            annotation.coordinate = mapItem.placemark.location.coordinate;
            annotation.title = mapItem.name;
            
            [strongSelf.mapView addAnnotation:annotation];
            [strongSelf.mapView selectAnnotation:[strongSelf.mapView.annotations objectAtIndex:0] animated:YES];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)setLocation
{
    DetailAnnotation *annotation = [[DetailAnnotation alloc] init];
    annotation.coordinate = self.coordinate;
    
    MKCoordinateSpan span =  MKCoordinateSpanMake(10.f, 10.f);
    MKCoordinateRegion region = {self.coordinate, span};
    self.mapView.region = region;
    [self setLocationInformationWithAnnotation:annotation];
    [self.mapView addAnnotation:annotation];
}

- (void)setLocationInformationWithAnnotation:(id <MKAnnotation>)annotation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        
        ((DetailAnnotation *)annotation).title = [NSString stringWithFormat:@"%@ %@ %@",placemark.country ?:@"", placemark.locality ?:@"", placemark.name ?:@""];
    }];
}

- (void)presentAlertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
