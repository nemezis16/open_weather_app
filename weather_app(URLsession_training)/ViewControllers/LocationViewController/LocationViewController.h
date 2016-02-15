//
//  LocationViewController.h
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 28.01.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

@interface LocationViewController : UIViewController <UISearchBarDelegate>

- (void)pushControllerFromController:(UIViewController *)controller withCoordinate:(CLLocationCoordinate2D)coordinate completion:(void(^)(CLLocationCoordinate2D))completion;

@end
