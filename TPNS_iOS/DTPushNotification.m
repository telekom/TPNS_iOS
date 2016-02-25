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

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSString *serverURLString;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, assign) BOOL registrationInProgress;

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

- (void)registerWithServerURL:(NSString *)serverURLString
                       appKey:(NSString *)appKey
                    pushToken:(NSData *)pushToken
         additionalParameters:(nullable NSArray *)additionalParameters
                    isSandbox:(BOOL)isSandbox
                   completion:(void(^)(NSString *deviceID, NSError * _Nullable error))completion
{
    
    NSParameterAssert(serverURLString.length);
    NSParameterAssert(appKey.length);
    NSParameterAssert(pushToken.length);
    
    if (self.registrationInProgress) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"There is already a registration in progress. Ignoring addional request."};
        NSError *customError = [[NSError alloc] initWithDomain:DTPNSErrorDomain
                                                          code:500
                                                      userInfo:userInfo];
        
        if (completion) {
            completion(nil, customError);
        }
        return;
    }
    
    self.registrationInProgress = YES;
    
    if (self.deviceId != nil || self.appKey != nil || self.serverURLString != nil) {
    }
    
    NSCharacterSet *trimSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *pushTokenString = [[[pushToken description] stringByTrimmingCharactersInSet:trimSet] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.serverURLString = serverURLString;
    self.appKey = appKey;
    
    
    NSString *deviceID = [NSUUID UUID].UUIDString;
    
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
    req.HTTPMethod = @"POST";
    
    [self executeDataTaskWithURL:reqURL
                           request:req
                         inSession:self.session
                   queryParameters:nil
                        completion:^(NSDictionary *responseData, NSHTTPURLResponse *response, NSError *error) {
                            
                            if (!error && 200 == response.statusCode) {
                                
                                if (completion) {
                                    completion(deviceID, nil);
                                }

                            } else {
                                NSString *originalErrorMessage = [responseData objectForKey:@"message"];
                                NSString *description;
                                
                                switch (response.statusCode) {
                                    case 422:
                                        description = [NSString stringWithFormat:@"Appkey, DeviceId or Application Type empty / ivalid (original error:%@)", originalErrorMessage];
                                        break;
                                    case 500:
                                        description = [NSString stringWithFormat:@"Internal Server Error (original error:%@)", originalErrorMessage];
                                        break;
                                    case 400:
                                        description = [NSString stringWithFormat:@"Bad Request (original error:%@)", originalErrorMessage];
                                        break;
                                    case 403:
                                        description = [NSString stringWithFormat:@"ApiKey invalid / not authorized (original error:%@)", originalErrorMessage];
                                        break;
                                    default:
                                        description = [NSString stringWithFormat:@"Request failed (original error:%@)", originalErrorMessage];
                                        break;
                                }
                                
                                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description};
                                NSError *customError = [[NSError alloc] initWithDomain:DTPNSErrorDomain
                                                                                  code:response.statusCode
                                                                              userInfo:userInfo];
                                
                                if (completion) {
                                    completion(nil, customError);
                                }

                            }
                            
                            self.registrationInProgress = NO;
                
    }];
    
}

- (void)unregisterWithCompletion:(void(^)(NSError* error)) completion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!self.serverURLString.length) {
        self.serverURLString = [defaults objectForKey:DTPNSUserDefaultsServerURLString];
    }
    
    if (!self.appKey.length) {
        self.appKey = [defaults objectForKey:DTPNSUserDefaultsAppKey];
    }
    
    if (!self.deviceId.length) {
        self.deviceId = [defaults objectForKey:DTPNSUserDefaultsDeviceID];
    }
    
    if (!self.serverURLString.length || !self.appKey.length || !self.deviceId.length) {
        NSError *customError = [[NSError alloc] initWithDomain:DTPNSErrorDomain
                                                          code:0
                                                      userInfo:@{NSLocalizedDescriptionKey:@"Unable to unregister device - No AppID, DeviceID found. You need to register this device first."}];
        if (completion) {
            completion(customError);
        }

        return;
    }
    
    NSURL *reqURL = [NSURL URLWithString:self.serverURLString];
    NSString *pathFormat = [NSString stringWithFormat:@"/api/application/%@/device/%@/unregister",self.appKey, self.deviceId];
    reqURL = [reqURL URLByAppendingPathComponent:pathFormat];
    
    NSMutableURLRequest *req = [self baseJSONRequestWithURL:reqURL
                                             bodyParameters:nil];
    req.HTTPMethod = @"PUT";
    
    [self executeDataTaskWithURL:reqURL
                         request:req
                       inSession:self.session
                 queryParameters:nil
                      completion:^(NSDictionary *responseData, NSHTTPURLResponse *response, NSError *error) {
                         
                          if (!error && 200 == response.statusCode) {
                              self.serverURLString = nil;
                              self.deviceId = nil;
                              self.registrationInProgress = NO;
                              
                              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                              [defaults removeObjectForKey:DTPNSUserDefaultsDeviceID];
                              [defaults removeObjectForKey:DTPNSUserDefaultsAppKey];
                              [defaults removeObjectForKey:DTPNSUserDefaultsServerURLString];
                              [defaults synchronize];

                          } else {
                              //According to TPNS Backend Dev Team Server ALWAYS send a 200,
                              //even, if the device has never been registered, or the
                              //app sends a wrong appID. This path only handles
                              //underlying connection errors
                          }
                          
                          if (completion) {
                              completion(error);
                          }
  
    }];
    
    
}

#pragma mark - Base Request
- (NSMutableURLRequest*)baseJSONRequestWithURL:(NSURL *)url
                                bodyParameters:(NSDictionary *)bodyParameters
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:60.];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (bodyParameters) {
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyParameters
                                                           options:0
                                                             error:&error];
        
        if (!error) {
            request.HTTPBody = bodyData;
        }

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
                                                
                                                if (completion) {
                                                    completion(responseDict, (NSHTTPURLResponse *)response, error);
                                                }

    }];
    
    
    [task resume];
}




@end
