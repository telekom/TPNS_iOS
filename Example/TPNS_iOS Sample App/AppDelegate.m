//
//  AppDelegate.m
//  TPNS_iOS Sample App
//
//  Created by Deutsche Telekom AG on 15.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "AppDelegate.h"
#import <TPNS_iOS/DTPushNotification.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    #import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
<UNUserNotificationCenterDelegate>
#endif

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_x_Max) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
    }
#endif
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%s %@", __FUNCTION__, deviceToken);
    
    if (self.registeredForRemoteNotificationsCallback) {
        self.registeredForRemoteNotificationsCallback(self, deviceToken);
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"%s %@", __FUNCTION__, error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
    
    NSLog(@"%s %@", __FUNCTION__, userInfo);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler  {
    
    
    NSLog(@"%s %@", __FUNCTION__, notification);
    
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    
    NSLog(@"%s %@", __FUNCTION__, response.notification);
    completionHandler();
}
#endif

@end
