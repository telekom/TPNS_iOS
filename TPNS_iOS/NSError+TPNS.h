//
//  NSError+TPNS.h
//  TPNS_iOS
//
//  Created by Carl Jahn on 17.10.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TPNSErrorCode)
{
    // General
    TPNSErrorCodeDeviceNotRegistered                = -1000,
    TPNSErrorCodeRegistrationIsAlreadyInProgress    = -1001,
    TPNSErrorCodeUnregisterBeforeYouRegisterAgain   = -1002,
};

@interface NSError (TPNS)

+ (instancetype)TPNS_errorWithCode:(NSInteger)code;

+ (instancetype)TPNS_httpErrorWithCode:(NSInteger)code originalErrorMessage:(NSString *)message;

@end
