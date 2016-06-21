//
//  SessionManager.h
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 27.01.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

@interface SessionManager : NSObject <NSURLSessionDelegate>

- (void)fetchDataFromURL:(NSURL *)url completion:(void(^)(NSData * data, NSError *error))completion;

@end
