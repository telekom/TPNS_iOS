//
//  NSMutableURLRequest+TPNS.h
//  TPNS_iOS
//
//  Created by Carl Jahn on 17.10.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (TPNS)

+ (NSMutableURLRequest *)TPNS_JSONRequestWithURL:(NSURL *)url bodyParameters:(NSDictionary *)bodyParameters;

@end
