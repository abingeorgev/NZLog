//
//  NZLog.m
//  NZlog
//
//  Created by Abin on 07/05/16.
//  Copyright © 2016 Nubicz. All rights reserved.
//

#import "NZLog.h"

@implementation NZLog

+ (instancetype)instance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    deviceName = [[UIDevice currentDevice] name];
    model = [[UIDevice currentDevice] model];
    version = [[UIDevice currentDevice] systemVersion];
    return self;
}

#pragma mark - Logging

+ (BOOL)isProduction {
#ifdef DEBUG // Only log on the app store if the debug setting is enabled in settings
    return NO;
#else
    return YES;
#endif
}

-(void)projectId:(NSString*)projctId
{
    projectId = projctId;
}

-(void)log:(NSString*)message tag:(NSString*)tag
{
    [self log:message tag:tag type:NZLogTypeInfo];
}

-(void)log:(NSString*)message tag:(NSString*)tag type:(NZLogType)logType
{
    
    if ([NZLog isProduction]){
        return;
    }
    if ( !self.shouldLog) {
        NSLog(@"%@",message);
    }
        
    if (projectId.length < 5) {
        NSLog(@"NZProjectId Id is not set");
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://172.16.0.30:8000/%@/",projectId];
    int timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *string = [NSString stringWithFormat:@"%d",timeStamp];
    NSString *extra = [NSString stringWithFormat:@"name: %@,  OS Version: %@,  model:%@",deviceName,version,model];
    NSDictionary *dic = @{ @"type":@"DEBUG",@"tag":tag,@"message":message,@"timestamp":string,@"clientId":deviceId,@"extra":extra};
    
    [self postRequest:url parameters:dic];
}

-(void)addNotifications
{
    NSArray *notifications = [NSArray arrayWithObjects:UIApplicationDidFinishLaunchingNotification, UIApplicationDidEnterBackgroundNotification, UIApplicationDidBecomeActiveNotification, UIApplicationDidReceiveMemoryWarningNotification,UIApplicationDidChangeStatusBarOrientationNotification, nil];
    
    for(NSString *notification in notifications)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:notification object:nil];
}

-(void)notificationReceived:(NSNotification*)notification
{
    [self log:notification.name tag:@"Notification" type:NZLogTypeInfo];
}

-(void)postRequest:(NSString*)url parameters:(NSDictionary*)parameters
{
    
    NSError *error;    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
             NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",returnString);
        }
    }];
    
    [postDataTask resume];
}

@end
