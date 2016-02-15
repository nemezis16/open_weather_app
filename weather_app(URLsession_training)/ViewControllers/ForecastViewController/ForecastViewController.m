//
//  ForecastViewController.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 12.02.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "ForecastViewController.h"
#import "ForecastTableViewCell.h"
#import "SessionManager.h"
#import "OpenWeatherConstants.h"

@interface ForecastViewController ()

@property (strong, nonatomic) NSMutableArray *imagesArray;

@end

@implementation ForecastViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.forecastList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ForecastTableViewCell *forecastCell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([ForecastTableViewCell class])];
    [self configureCell:forecastCell atIndexPath:indexPath];
    
    return forecastCell;
}

- (void)configureCell:(ForecastTableViewCell *)forecastCell atIndexPath:(NSIndexPath *)indexPath
{
    WeatherDescription *weatherDescription = self.forecastList[indexPath.row];
    forecastCell.timeLabel.text = weatherDescription.date;
    forecastCell.temperatureLabel.text = weatherDescription.temperature;
    forecastCell.weatherDescriptionLabel.text = weatherDescription.weather;
    forecastCell.humidityLabel.text = weatherDescription.humidity;
    forecastCell.windSpeedLabel.text = weatherDescription.windSpeed;
    
    UIColor *bacgroundColor = (indexPath.row % 2) ? [UIColor applicationLightGreenColor] : [UIColor applicationMildGreenColor];
    forecastCell.backgroundColor = bacgroundColor;
    
    [self loadImageFromLink:weatherDescription.imageLink toCell:forecastCell];
}

- (void)loadImageFromLink:(NSString *)link toCell:(ForecastTableViewCell *)cell
{
    if (link) {
        NSString *linkToImageString = [[LinkImageWeather stringByAppendingString:link]stringByAppendingString:@".png"];
        NSURL *imageURL = [NSURL URLWithString:linkToImageString];
        
        [[SessionManager new] fetchDataFromURL:imageURL completion:^(NSData *data, NSError *error) {
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.weatherIconLabel.image = [UIImage imageWithData:data];
                });
            } else {
                DLog(@"Image did not recieved");
            }
        }];
    }
}

@end
