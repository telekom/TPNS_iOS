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
    
    // Register the supported interaction types.
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [application registerUserNotificationSettings:mySettings];
    
    [application registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSDictionary *params = @{@"key":@"SomeAdditionalID", @"value":@4711};
    
    DTPushNotification *tpns = [DTPushNotification sharedInstance];
    [tpns registerWithServerURL:@"https://tpns-preprod.molutions.de/TPNS"
                         appKey:@"LoadTestApp3"
                      pushToken:deviceToken
           additionalParameters:@[params]
                      isSandbox:YES
                     completion:^(NSString * _Nullable deviceID, NSError * _Nullable error) {
                         
                         NSString *title = @"Success";
                         NSString *message = [NSString stringWithFormat:@"The device was successfully registered with TPNS. TPNS deviceID is is \"%@\"", deviceID];
                         
                         if (error) {
                             title = @"Error";
                             message = [NSString stringWithFormat:@"The device could not be registered with TPNS. Errormessage was \"%@\"", error.localizedDescription];
                         }
                         
                         UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                                        message:message
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                         
                         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:nil];
                         
                         [alert addAction:okAction];
                         
                         UIViewController *rootViewController = self.window.rootViewController;
                         [rootViewController presentViewController:alert animated:YES completion:nil];
                     }];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
    
    NSLog(@"%s %@", __FUNCTION__, userInfo);
}

@end
