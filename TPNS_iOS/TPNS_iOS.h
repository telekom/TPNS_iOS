//
//  TPNS.h
//  TPNS
//
//  Created by Carl Jahn on 17.03.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DTPushNotification.h"

//API Endpoints
FOUNDATION_EXPORT NSString *const DTPNSURLStringProduction;
FOUNDATION_EXPORT NSString *const DTPNSURLStringPreProduction;

//String constants
FOUNDATION_EXPORT NSString *const DTPNSApplicationTypeiOS;
FOUNDATION_EXPORT NSString *const DTPNSApplicationTypeiOSSandbox;

FOUNDATION_EXPORT NSString *const DTPNSErrorDomain;

//Helper Categories
#import "NSError+TPNS.h"
#import "NSMutableURLRequest+TPNS.h"
#import "NSURLSession+TPNS.h"
