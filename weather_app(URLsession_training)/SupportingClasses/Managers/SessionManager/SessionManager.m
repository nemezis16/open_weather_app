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
        [self setSharedCache];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)fetchDataFromURL:(NSURL *)url completion:(ComplitionBlock)completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache]cachedResponseForRequest:request];
    if (cachedResponse.data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(cachedResponse.data,nil);
        });
    } else {
        [[self.session dataTaskWithRequest:request] resume];
        self.complitionBlock = completion;
    }
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

#pragma mark - Private

- (void)setSharedCache
{
    static NSURLCache *cache = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSInteger memoryCapacity = 5 * 1024 * 1024;
        NSInteger diskCapacity = 20 * 1024 * 1024;
        cache = [[NSURLCache alloc]initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:nil];
        [NSURLCache setSharedURLCache:cache];
    });
}

@end
