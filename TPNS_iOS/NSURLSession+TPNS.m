//
//  NSURLSession+TPNS.m
//  TPNS_iOS
//
//  Created by Carl Jahn on 17.10.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "NSURLSession+TPNS.h"

@implementation NSURLSession (TPNS)

- (void)TPNS_executeDataTaskWithRequest:(NSMutableURLRequest *)request
                             completion:(void(^)(NSDictionary *responseData, NSHTTPURLResponse *response, NSError *error))completion
{
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request
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
