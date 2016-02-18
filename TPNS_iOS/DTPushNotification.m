//
//  DTPushNotification.m
//  DTPushNotification
//
//  Created by Björn Richter on 12.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "DTPushNotification.h"

//String constants
static NSString *DTPNSApplicationTypeiOS = @"IOS";
static NSString *DTPNSApplicationTypeiOSSandbox = @"IOS_SAND";
static NSString *DTPNSErrorDomain = @"de.telekom.TPNS";

//Defaults
static NSString *DTPNSUserDefaultsServerURLString    = @"DTPNSUserDefaultsServerURLString";
static NSString *DTPNSUserDefaultsAppKey             = @"DTPNSUserDefaultsAppKey";
static NSString *DTPNSUserDefaultsDeviceID           = @"DTPNSUserDefaultsDeviceID";


@interface DTPushNotification (/*privat*/)

@property (strong) NSURLSession *session;
@property (strong) NSString *serverURLString;
@property (strong) NSString *appKey;
@property (strong) NSString *deviceId;
@property (assign) BOOL registrationInProgress;


@end


@implementation DTPushNotification


- (id)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
        config.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        self.session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
        self.registrationInProgress = NO;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.serverURLString = [defaults objectForKey:DTPNSUserDefaultsServerURLString];
        self.appKey = [defaults objectForKey:DTPNSUserDefaultsAppKey];
        self.deviceId = [defaults objectForKey:DTPNSUserDefaultsDeviceID];
        
    }
    return self;
}

#pragma mark - Public methods
+ (DTPushNotification*)sharedInstance
{
    static dispatch_once_t pred;
    static DTPushNotification *instance = nil;
    
    dispatch_once(&pred, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void)registerWithServerURL:(NSString *) serverURLString
                       appKey:(NSString *) appKey
                    pushToken:(NSData *) pushToken
         additionalParameters:(nullable NSArray *) additionalParameters
                    isSandbox:(BOOL)isSandbox
                   completion:(void(^)(NSString *deviceID, NSError* error)) completion
{
    /*
     POST {SERVER_URL}/api/device/register
     
     {
        "deviceId":"deviceId", 
        "deviceRegistrationId":"regId", 
        "applicationKey":"appKey", 
        "applicationType":"IOS", 
        "additionalParameters":[
        {
            "key":"location", 
            "value":"darmstadt"
        }, {
            "key":"example",
            "value":"house" }
        ] 
     }
     */
    
    NSParameterAssert(serverURLString != nil);
    NSParameterAssert(appKey != nil);
    NSParameterAssert(pushToken != nil);
    
    if (self.registrationInProgress) {
        NSLog(@"WARN: There is already a registration in progress. Ignoring addional request.");
        return;
    }
    
    self.registrationInProgress = YES;
    
    if (self.deviceId != nil || self.appKey != nil || self.serverURLString != nil) {
        NSLog(@"WARN: Potential use of unbalanced register/unregister");
    }
    
    NSCharacterSet * trimSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *pushTokenString = [[[pushToken description] stringByTrimmingCharactersInSet:trimSet] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.serverURLString = serverURLString;
    self.appKey = appKey;
    
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString *deviceID = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    CFRelease(uuidObject);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:serverURLString forKey:DTPNSUserDefaultsServerURLString];
    [defaults setObject:appKey forKey:DTPNSUserDefaultsAppKey];
    [defaults setObject:deviceID forKey:DTPNSUserDefaultsDeviceID];
    [defaults synchronize];
    
    NSString *applicationType = isSandbox ? DTPNSApplicationTypeiOSSandbox : DTPNSApplicationTypeiOS;
    
    NSDictionary *bodyParams = @{@"deviceId":deviceID,
                                 @"deviceRegistrationId":pushTokenString,
                                 @"applicationKey": appKey,
                                 @"applicationType": applicationType,
                                 @"additionalParameters": additionalParameters};
    
    NSURL *reqURL = [NSURL URLWithString:self.serverURLString];
    reqURL = [reqURL URLByAppendingPathComponent:@"/api/device/register"];
    
    NSMutableURLRequest *req = [self baseJSONRequestWithURL:reqURL
                                             bodyParameters:bodyParams];
    
    [req setHTTPMethod:@"POST"];
    
    [self executeDataTaskWithURL:reqURL
                           request:req
                         inSession:self.session
                   queryParameters:nil
                        completion:^(NSDictionary *responseData, NSHTTPURLResponse *response, NSError *error) {
                            
                            if (error == nil && response.statusCode == 200) {
                                //Success
                                completion(deviceID,nil);
                            } else {
                                //TODO: Impl.
                                /*
                                 
                                 {
                                    errors =     (
                                        {
                                            errorCode = "UNKNOWN_ERROR";
                                            field = "<null>";
                                            message = "[Source: org.apache.cxf.transport.http.AbstractHTTPDestination$1@5c007091; line: 1, column: 112]";
                                        }
                                    );
                                    message = "Registration Failed";
                                    success = 0;
                                 }
                                 
                                 */
                                
                                
                                completion(nil, error);
                            }
                            
                            self.registrationInProgress = NO;
                
    }];
    
}

- (void)unregisterWithCompletion:(void(^)(NSError* error)) completion
{
    /*
     PUT {SERVER_URL}/api/application/{application_key}/device/{device_id}/unregister
    */
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.serverURLString == nil) {
        self.serverURLString = [defaults objectForKey:DTPNSUserDefaultsServerURLString];
    }
    
    if (self.appKey == nil) {
        self.appKey = [defaults objectForKey:DTPNSUserDefaultsAppKey];
    }
    
    if (self.deviceId) {
        self.deviceId = [defaults objectForKey:DTPNSUserDefaultsDeviceID];
    }
    
    if (self.serverURLString == nil|| self.appKey == nil || self.deviceId == nil) {
        //TODO: Fail with error and abort
    }
    
    NSURL *reqURL = [NSURL URLWithString:self.serverURLString];
    NSString *pathFormat = [NSString stringWithFormat:@"/api/application/%@/device/%@/unregister",self.appKey, self.deviceId];
    reqURL = [reqURL URLByAppendingPathComponent:pathFormat];
    
    NSMutableURLRequest *req = [self baseJSONRequestWithURL:reqURL
                                             bodyParameters:nil];
    
    [req setHTTPMethod:@"PUT"];
    
    [self executeDataTaskWithURL:reqURL
                         request:req
                       inSession:self.session
                 queryParameters:nil
                      completion:^(NSDictionary *responseData, NSHTTPURLResponse *response, NSError *error) {
                         
                          if (error == nil && response.statusCode == 200) {
                              //Success
                              
                              self.serverURLString = nil;
                              self.deviceId = nil;
                              self.registrationInProgress = nil;
                              self.registrationInProgress = NO;
                              
                              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                              [defaults removeObjectForKey:DTPNSUserDefaultsDeviceID];
                              [defaults removeObjectForKey:DTPNSUserDefaultsAppKey];
                              [defaults removeObjectForKey:DTPNSUserDefaultsServerURLString];
                              [defaults synchronize];
                              
                              completion(nil);
                          } else {
                              //TODO: Impl. error case
                              completion(error);
                          }
  
    }];
    
    
}

#pragma mark - Base Request
- (NSMutableURLRequest*)baseJSONRequestWithURL:(NSURL *) url
                                bodyParameters:(NSDictionary *)bodyParameters
{
    
    NSMutableURLRequest *request =  [[NSMutableURLRequest alloc] init];
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:60];

    [request setURL:url];
    
    if (bodyParameters != nil) {
        //TODO: Handle Error
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyParameters
                                                           options:0
                                                             error:nil];
        [request setHTTPBody:bodyData];
    }
    
    return request;
}

#pragma mark - Data Task
- (void)executeDataTaskWithURL:(NSURL *)url
                         request:(NSMutableURLRequest *)request
                       inSession:(NSURLSession *)session
                 queryParameters:(NSDictionary *)queryParameters
                completion:(void(^)(NSDictionary *responseData, NSHTTPURLResponse *response, NSError *error))completion
{
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                
                                                NSDictionary *responseDict = nil;
                                                
                                                if (data) {
                                                    responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                }
                                                
                                                completion(responseDict, (NSHTTPURLResponse *) response, error);
    }];
    
    
    [task resume];
}




@end
