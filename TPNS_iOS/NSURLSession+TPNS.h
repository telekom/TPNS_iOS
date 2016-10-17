//
//  NSURLSession+TPNS.h
//  TPNS_iOS
//
//  Created by Carl Jahn on 17.10.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (TPNS)

- (void)TPNS_executeDataTaskWithRequest:(NSMutableURLRequest *)request
                             completion:(void(^)(NSDictionary *responseData, NSHTTPURLResponse *response, NSError *error))completion;

@end
