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

@end
