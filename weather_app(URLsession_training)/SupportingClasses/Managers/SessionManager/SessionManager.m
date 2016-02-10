//
//  SessionManager.m
//  weather_app(URLsession_training)
//
//  Created by Roman Osadchuk on 27.01.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "SessionManager.h"

typedef void (^ComplitionBlock)(NSData *, NSError *);

@interface SessionManager ()

@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) NSURLSession *session;
@property (copy, nonatomic) ComplitionBlock complitionBlock;

@end

@implementation SessionManager

#pragma mark - Public

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)fetchDataFromURL:(NSURL *)url completion:(void (^)(NSData *, NSError *))completion
{
    [[self.session dataTaskWithURL:url] resume];
    self.complitionBlock = completion;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    self.data = [NSMutableData new];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    self.complitionBlock(self.data,error);
    [session finishTasksAndInvalidate];
}

@end
