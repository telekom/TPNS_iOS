//
//  NSMutableURLRequest+TPNS.m
//  TPNS_iOS
//
//  Created by Carl Jahn on 17.10.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "NSMutableURLRequest+TPNS.h"

@implementation NSMutableURLRequest (TPNS)

+ (NSMutableURLRequest *)TPNS_JSONRequestWithURL:(NSURL *)url bodyParameters:(NSDictionary *)bodyParameters
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
        
        if (nil == error) {
            request.HTTPBody = bodyData;
        }
    }
    
    return request;
}

@end
