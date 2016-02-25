//
//  AppDelegate.m
//  TPNS_iOS Sample App
//
//  Created by Deutsche Telekom AG on 15.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "AppDelegate.h"
#import <TPNS_iOS/DTPushNotification.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    if (self.registeredForRemoteNotificationsCallback) {
        self.registeredForRemoteNotificationsCallback(self, deviceToken);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
    
    NSLog(@"%s %@", __FUNCTION__, userInfo);
}

@end
