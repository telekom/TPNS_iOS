//
//  DTPushNotification.m
//  DTPushNotification
//
//  Created by Deutsche Telekom AG on 12.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "DTPushNotification.h"
#import "TPNS_iOS.h"

//Defaults
static NSString *DTPNSUserDefaultsServerURLString = @"DTPNSUserDefaultsServerURLString";
static NSString *DTPNSUserDefaultsAppKey          = @"DTPNSUserDefaultsAppKey";
static NSString *DTPNSUserDefaultsDeviceID        = @"DTPNSUserDefaultsDeviceID";


@interface DTPushNotification (/*privat*/)

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURL *serverURL;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, assign) BOOL registrationInProgress;

@end


@implementation DTPushNotification
@synthesize serverURL = _serverURL;
@synthesize appKey    = _appKey;

- (id)init {
    
    self = [super init];
    if (self) {
        
        self.session = [NSURLSession TPNS_defaultSession];
        self.registrationInProgress = NO;        
    }
    return self;
}

- (BOOL)isRegistered {

    return (self.deviceId.length > 0);
}

#pragma mark - Class Helper Methods
+ (NSString *)userDefaultsValueForKey:(NSString *)key {
    NSParameterAssert(key.length);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

+ (void)setUserDefaultsValue:(id)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (value != nil) {
        [defaults setObject:value forKey:key];
    } else {
        [defaults removeObjectForKey:key];
    }
    
    [defaults synchronize];
}

#pragma mark - Custom Setter and Getters
- (NSURL *)serverURL {
    if (nil == _serverURL) {
        
        NSString *serverURLString = [[self class] userDefaultsValueForKey:DTPNSUserDefaultsServerURLString];
        if (serverURLString.length) {
            _serverURL = [NSURL URLWithString:serverURLString];
        }
        
    }
    
    return _serverURL;
}

- (void)setServerURL:(NSURL *)serverURL {
    if (_serverURL == serverURL) {
        return;
    }
    
    _serverURL = serverURL;
    [[self class] setUserDefaultsValue:_serverURL.absoluteString forKey:DTPNSUserDefaultsServerURLString];
}

- (NSString *)appKey {
    if (nil == _appKey) {
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
    NSParameterAssert(url.absoluteString.length > 0);
    NSParameterAssert(!url.isFileURL);
    NSParameterAssert(appKey.length > 0);
    NSParameterAssert(pushToken.length > 0);
    
    if (self.registrationInProgress || self.isRegistered) {
        
        NSInteger errorCode = self.registrationInProgress ? TPNSErrorCodeRegistrationIsAlreadyInProgress : TPNSErrorCodeUnregisterBeforeYouRegisterAgain;
        NSError *customError = [NSError TPNS_errorWithCode:errorCode];
        
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
    
    if (nil != additionalParameters) {
        bodyParams[@"additionalParameters"] = additionalParameters;
    }

    NSURL *reqURL = [self.serverURL URLByAppendingPathComponent:@"/api/device/register"];
    NSMutableURLRequest *req = [NSMutableURLRequest TPNS_JSONRequestWithURL:reqURL bodyParameters:bodyParams];
    
    req.HTTPMethod = @"POST";
    
    [self.session TPNS_executeDataTaskWithRequest:req
                                       completion:^(NSDictionary *responseData, NSHTTPURLResponse *response, NSError *error) {
                                           
                            if (error == nil && 200 == response.statusCode) {
                                
                                [self callRegisterCompletion:completion deviceID:self.deviceId error:nil];

                            } else {
                                
                                self.serverURL = nil;
                                self.appKey = nil;
                                
                                
                                NSString *originalErrorMessage = responseData[@"message"];
                                NSError *customError = [NSError TPNS_httpErrorWithCode:response.statusCode originalErrorMessage:originalErrorMessage];
                                [self callRegisterCompletion:completion deviceID:nil error:customError];
                            }
                            
                            self.registrationInProgress = NO;
                
    }];
    
}

- (void)unregisterWithCompletion:(void(^)(NSError *error))completion {
    
    if (!self.serverURL.absoluteString.length || !self.appKey.length || !self.deviceId.length) {
        NSError *customError = [NSError TPNS_errorWithCode:TPNSErrorCodeDeviceNotRegistered];
        
        [self callUnregisterCompletion:completion error:customError];
        return;
    }
    
    NSString *pathFormat = [NSString stringWithFormat:@"/api/application/%@/device/%@/unregister", self.appKey, self.deviceId];
    NSURL *reqURL = [self.serverURL URLByAppendingPathComponent:pathFormat];
    NSMutableURLRequest *req = [NSMutableURLRequest TPNS_JSONRequestWithURL:reqURL bodyParameters:nil];

    req.HTTPMethod = @"PUT";
    
    [self.session TPNS_executeDataTaskWithRequest:req
                                       completion:^(NSDictionary *responseData, NSHTTPURLResponse *response, NSError *error) {
                         
                          if (error == nil && 200 == response.statusCode) {
                              self.serverURL = nil;
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

@end
