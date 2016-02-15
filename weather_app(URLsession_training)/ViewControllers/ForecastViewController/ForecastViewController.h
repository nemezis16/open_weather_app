//
//  ForecastViewController.h
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 12.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

@interface ForecastViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *forecastList;

@end
