//
//  NSError+TPNS.h
//  TPNS_iOS
//
//  Created by Carl Jahn on 17.10.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (TPNS)

+ (instancetype)TPNS_errorWithCode:(NSUInteger)code description:(NSString *)description;

+ (instancetype)TPNS_errorWithCode:(NSUInteger)code originalErrorMessage:(NSString *)message;

@end
