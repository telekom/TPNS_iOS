//
//  NSError+TPNS.m
//  TPNS_iOS
//
//  Created by Carl Jahn on 17.10.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "NSError+TPNS.h"
#import "TPNS_iOS.h"

@implementation NSError (TPNS)

+ (instancetype)TPNS_errorWithCode:(NSInteger)code description:(NSString *)description {
    NSParameterAssert(description.length > 0);
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description};
    NSError *customError = [NSError errorWithDomain:DTPNSErrorDomain
                                               code:code
                                           userInfo:userInfo];
    return customError;
}

+ (instancetype)TPNS_errorWithCode:(NSInteger)code {

    NSString *description;
    switch (code) {
        case TPNSErrorCodeDeviceNotRegistered:
            description = @"Unable to unregister device - No AppID, DeviceID found. You need to register this device first.";
            break;
        case TPNSErrorCodeRegistrationIsAlreadyInProgress:
            description = @"There is already a registration in progress. Ignoring addional request.";
            break;
        case TPNSErrorCodeUnregisterBeforeYouRegisterAgain:
            description = @"Please unregister before you register again.";
            break;
        default:
            description = @"Unknown error";
            break;
    }
    
    return [self TPNS_errorWithCode:code description:description];
}

+ (instancetype)TPNS_httpErrorWithCode:(NSInteger)code originalErrorMessage:(NSString *)message {

    NSString *description;
    switch (code) {
        case 422:
            description = [NSString stringWithFormat:@"Appkey, DeviceId or Application Type empty / invalid (original error:%@)", message];
            break;
        case 500:
            description = [NSString stringWithFormat:@"Internal Server Error (original error:%@)", message];
            break;
        case 400:
            description = [NSString stringWithFormat:@"Bad Request (original error:%@)", message];
            break;
        case 403:
            description = [NSString stringWithFormat:@"ApiKey invalid / not authorized (original error:%@)", message];
            break;
        default:
            message = message.length > 0 ? message : @"No error description was provided";
            description = [NSString stringWithFormat:@"Request failed (original error:%@)", message];
            break;
    }

    return [self TPNS_errorWithCode:code description:description];
}

@end
