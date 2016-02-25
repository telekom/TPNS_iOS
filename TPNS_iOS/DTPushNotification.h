//
//  DTPushNotification.h
//  DTPushNotification
//
//  Created by Björn Richter on 12.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTPushNotification : NSObject

//TODO: Documentation
+ (DTPushNotification *)sharedInstance;

//TODO: Documentation
- (void)registerWithServerURL:(NSString *)serverURLString
                       appKey:(NSString *)appKey
                    pushToken:(NSData *)pushToken
         additionalParameters:(nullable NSArray *)additionalParameters
                    isSandbox:(BOOL)isSandbox
                   completion:(void(^)(NSString *deviceID, NSError *error))completion;

//TODO: Documentation
- (void)unregisterWithCompletion:(void(^)(NSError * _Nullable error)) completion;

NS_ASSUME_NONNULL_END

@end
