//
//  DTPushNotification.m
//  DTPushNotification
//
//  Created by Deutsche Telekom AG on 12.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "DTPushNotification.h"

NSString *const DTPNSURLStringProduction    = @"https://tpns.molutions.de/TPNS";
NSString *const DTPNSURLStringPreProduction = @"https://tpns-preprod.molutions.de/TPNS";

//String constants
static NSString *DTPNSApplicationTypeiOS        = @"IOS";
static NSString *DTPNSApplicationTypeiOSSandbox = @"IOS_SAND";
static NSString *DTPNSErrorDomain               = @"de.telekom.TPNS";

//Defaults
static NSString *DTPNSUserDefaultsServerURLString = @"DTPNSUserDefaultsServerURLString";
static NSString *DTPNSUserDefaultsAppKey          = @"DTPNSUserDefaultsAppKey";
static NSString *DTPNSUserDefaultsDeviceID        = @"DTPNSUserDefaultsDeviceID";


@interface DTPushNotification (/*privat*/)

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURL *serverURL;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong, readonly) NSString *deviceId;
@property (nonatomic, assign) BOOL registrationInProgress;

@end


@implementation DTPushNotification
@synthesize serverURL = _serverURL;
@synthesize appKey    = _appKey;

- (id)init {
    
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
        config.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        self.session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
        self.registrationInProgress = NO;        
    }
    return self;
}

#pragma mark - Class Helper Methods
+ (NSString *)userDefaultsValueForKey:(NSString *)key {
    NSParameterAssert(key.length);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

+ (void)setUserDefaultsValue:(id)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (value) {
        [defaults setObject:value forKey:key];
    } else {
        [defaults removeObjectForKey:key];
    }
    
    [defaults synchronize];
}

#pragma mark - Custom Setter and Getters
- (NSURL *)serverURL {
    if (!_serverURL) {
        
        NSString *serverURLString = [[self class] userDefaultsValueForKey:DTPNSUserDefaultsServerURLString];
        if (serverURLString.length) {
            _serverURL = [NSURL URLWithString:serverURLString];
        }
        
    }
    
    return _serverURL;
}

- (void)setServerURLString:(NSURL *)serverURL {
    if (_serverURL == serverURL) {
        return;
    }
    
    _serverURL = serverURL;
    [[self class] setUserDefaultsValue:_serverURL.absoluteString forKey:DTPNSUserDefaultsServerURLString];
}

- (NSString *)appKey {
    if (!_appKey) {
        _appKey = [[self class] userDefaultsValueForKey:DTPNSUserDefaultsAppKey];
    }
    
    return _appKey;
}

- (void)setAppKey:(NSString *)appKey {
    if (_appKey == appKey) {
        return;
    }
    
    _appKey = appKey;
    [[self class] setUserDefaultsValue:_appKey forKey:DTPNSUserDefaultsAppKey];
}

- (NSString *)deviceId {
    
    NSString *deviceId = [[self class] userDefaultsValueForKey:DTPNSUserDefaultsDeviceID];
    
    if (!deviceId) {
        deviceId = [NSUUID UUID].UUIDString;
        [[self class] setUserDefaultsValue:deviceId forKey:DTPNSUserDefaultsDeviceID];
    }
    
    return deviceId;
}

#pragma mark - Block Callback Helper methods
- (void)callRegisterCompletion:(void(^)(NSString *deviceID, NSError * _Nullable error))completion deviceID:(NSString *)deviceID error:(NSError *)error {
    
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            completion(deviceID, error);
        });
    }
}

- (void)callUnregisterCompletion:(void(^)(NSError *error))completion error:(NSError *)error {

    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            completion(error);
        });
    }
}

#pragma mark - Public methods
+ (DTPushNotification*)sharedInstance {
    
    static dispatch_once_t pred;
    static DTPushNotification *instance = nil;
    
    dispatch_once(&pred, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void)registerWithURL:(NSURL *)url
                 appKey:(NSString *)appKey
              pushToken:(NSData *)pushToken
   additionalParameters:(nullable NSArray *)additionalParameters
                sandbox:(BOOL)sandbox
             completion:(void(^)(NSString *deviceID, NSError * _Nullable error))completion;

{
    NSParameterAssert(url.absoluteString.length);
    NSParameterAssert(!url.isFileURL);
    NSParameterAssert(appKey.length);
    NSParameterAssert(pushToken.length);
    
    if (self.registrationInProgress) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"There is already a registration in progress. Ignoring addional request."};
        NSError *customError = [NSError errorWithDomain:DTPNSErrorDomain code:500 userInfo:userInfo];
        
        if (completion) {
            completion(nil, customError);
        }
        return;
    }
    
    self.registrationInProgress = YES;
    
    NSCharacterSet *trimSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *pushTokenString = [[[pushToken description] stringByTrimmingCharactersInSet:trimSet] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.serverURL = url;
    self.appKey = appKey;
    
    NSString *applicationType = sandbox ? DTPNSApplicationTypeiOSSandbox : DTPNSApplicationTypeiOS;
    
    NSMutableDictionary *bodyParams = [@{@"deviceId" : self.deviceId,
                                 @"deviceRegistrationId" : pushTokenString,
                                 @"applicationKey" : self.appKey,
                                 @"applicationType" : applicationType} mutableCopy];
    
    if (additionalParameters) {
        bodyParams[@"additionalParameters"] = additionalParameters;
    }

    NSURL *reqURL = [self.serverURL URLByAppendingPathComponent:@"/api/device/register"];
    NSMutableURLRequest *req = [self baseJSONRequestWithURL:reqURL
                                             bodyParameters:bodyParams];
    req.HTTPMethod = @"POST";
    
    [self executeDataTaskWithURL:reqURL
                           request:req
                         inSession:self.session
                   queryParameters:nil
                        completion:^(NSDictionary *responseData, NSHTTPURLResponse *response, NSError *error) {
                            
                            if (!error && 200 == response.statusCode) {
                                
                                [self callRegisterCompletion:completion deviceID:self.deviceId error:nil];

                            } else {
                                NSString *originalErrorMessage = responseData[@"message"];
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
                                NSError *customError = [NSError errorWithDomain:DTPNSErrorDomain
                                                                           code:response.statusCode
                                                                       userInfo:userInfo];
                                
                                [self callRegisterCompletion:completion deviceID:nil error:customError];
                            }
                            
                            self.registrationInProgress = NO;
                
    }];
    
}

- (void)unregisterWithCompletion:(void(^)(NSError *error))completion {
    
    if (!self.serverURL.absoluteString.length || !self.appKey.length || !self.deviceId.length) {
        NSError *customError = [NSError errorWithDomain:DTPNSErrorDomain
                                                   code:500
                                               userInfo:@{NSLocalizedDescriptionKey:@"Unable to unregister device - No AppID, DeviceID found. You need to register this device first."}];

        [self callUnregisterCompletion:completion error:customError];
        return;
    }
    
    NSString *pathFormat = [NSString stringWithFormat:@"/api/application/%@/device/%@/unregister",self.appKey, self.deviceId];
    NSURL *reqURL = [self.serverURL URLByAppendingPathComponent:pathFormat];
    
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
                              self.appKey = nil;
                              self.registrationInProgress = NO;

                          } else {
                              //According to TPNS Backend Dev Team Server ALWAYS send a 200,
                              //even, if the device has never been registered, or the
                              //app sends a wrong appID. This path only handles
                              //underlying connection errors
                          }

                          [self callUnregisterCompletion:completion error:error];  
    }];
    
    
}

#pragma mark - Base Request
- (NSMutableURLRequest *)baseJSONRequestWithURL:(NSURL *)url
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
                                                
                                                NSDictionary *responseDict;
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
