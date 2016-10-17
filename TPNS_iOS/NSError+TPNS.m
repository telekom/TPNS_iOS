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

+ (instancetype)TPNS_errorWithCode:(NSUInteger)code description:(NSString *)description {
    NSParameterAssert(description.length > 0);
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description};
    NSError *customError = [NSError errorWithDomain:DTPNSErrorDomain
                                               code:code
                                           userInfo:userInfo];

    return customError;
}

+ (instancetype)TPNS_errorWithCode:(NSUInteger)code originalErrorMessage:(NSString *)message {

    NSString *description = message.length > 0 ? message : @"No error description was provided";
    switch (code) {
        case 422:
            description = [NSString stringWithFormat:@"Appkey, DeviceId or Application Type empty / ivalid (original error:%@)", message];
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
            description = [NSString stringWithFormat:@"Request failed (original error:%@)", message];
            break;
    }

    NSError *customError = [NSError TPNS_errorWithCode:code description:description];
    return customError;
}

@end
