//
//  ForecastTableViewCell.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 12.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "ForecastTableViewCell.h"

@implementation ForecastTableViewCell

#pragma mark - LifeCycle

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.timeLabel.text = @"";
    self.temperatureLabel.text = @"";
    self.weatherDescriptionLabel.text = @"";
    self.humidityLabel.text = @"";
    self.windSpeedLabel.text = @"";
    self.weatherIconLabel.image = [UIImage new];
}

@end
