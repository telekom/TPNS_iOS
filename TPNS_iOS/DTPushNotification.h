//
//  DTPushNotification.h
//  DTPushNotification
//
//  Created by Deutsche Telekom AG on 12.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTPushNotification : NSObject

/**
 Creates and returns an `DTPushNotification` object.
 */
+ (DTPushNotification *)sharedInstance;

/**
 Registers the device with TPNS
 
 @param serverURLString The URL string of the TPNS server
 @param appKey The app key used to connect to TPNS
 @param pushToken The pushToken genarted by UIApplication, when registering for remote notifications
 @param additionalParameters An array containing any additional parameters as NSDictionaries like @{@"key" : @"SomeAdditionalID", @"value" : @4711};
 @param isSandbox Defines wether or not to use the TPNS sandbox feature
 @param completion A block object to be executed when registration is completed. This block has no return value and takes two arguments: The deviceID returned by TPNS, if registration was successful and nil otherwise as well an an NSError object which is returned, if registration failed and nil otherwise.
 
 */
- (void)registerWithServerURL:(NSString *)serverURLString
                       appKey:(NSString *)appKey
                    pushToken:(NSData *)pushToken
         additionalParameters:(nullable NSArray *)additionalParameters
                    isSandbox:(BOOL)isSandbox
                   completion:(void(^)(NSString *deviceID, NSError * _Nullable error))completion;

/**
 Unregisters the device with TPNS
 
 @param A block object to be executed when deregistration is completed. This block has no return value and takes one arguments: An an NSError object which is returned, if deregistration failed and nil otherwise.
 
 */
- (void)unregisterWithCompletion:(void(^)(NSError * _Nullable error)) completion;

NS_ASSUME_NONNULL_END

@end
