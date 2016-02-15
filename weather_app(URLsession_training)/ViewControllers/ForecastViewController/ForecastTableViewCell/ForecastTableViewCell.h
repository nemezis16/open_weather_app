//
//  ForecastTableViewCell.h
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 12.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "WeatherDescription.h"

@interface ForecastTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *windSpeedLabel;

@property (weak, nonatomic) IBOutlet UIImageView *weatherIconLabel;

@property (strong, nonatomic) WeatherDescription *weatherDescription;

@end
