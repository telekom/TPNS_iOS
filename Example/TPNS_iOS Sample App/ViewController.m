//
//  ViewController.m
//  TPNS_iOS Sample App
//
//  Created by Deutsche Telekom AG on 15.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "ViewController.h"
#import <TPNS_iOS/TPNS_iOS.h>
#import <UserNotifications/UserNotifications.h>
#import "AppDelegate.h"


@interface ViewController ()

@end

@implementation ViewController

- (IBAction)registerForRemoteNotifications:(id)sender {
    
    // Register the supported interaction types.
    UIApplication *application = [UIApplication sharedApplication];
    
    AppDelegate *appDelegate = (AppDelegate *)application.delegate;
    appDelegate.registeredForRemoteNotificationsCallback = ^(AppDelegate *appdelegate, NSData *deviceToken){
        
        if (deviceToken.length) {
            [self startRegisterCallWithDeviceToken:deviceToken];
        }
    };
    
    
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_9_x_Max) {
        
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:mySettings];
    
        [application registerForRemoteNotifications];
    
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    else {
    
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  
                                  if (nil == error) {
                                      
                                      [[UIApplication sharedApplication] registerForRemoteNotifications];
                                  }
                                  
                              }];
        
    }
#endif

    
    

}

- (void)startRegisterCallWithDeviceToken:(NSData *)deviceToken {
    
    NSArray *params = @[@{@"key" : @"SomeAdditionalID", @"value" : @4711},
                        @{@"key" : @"OtherID", @"value" : @"randomValue"}];
    
    DTPushNotification *tpns = [DTPushNotification sharedInstance];
    [tpns registerWithURL:[NSURL URLWithString:DTPNSURLStringPreProduction]
                   appKey:@"LoadTestApp3"
                pushToken:deviceToken
     additionalParameters:params
                  sandbox:YES
               completion:^(NSString * _Nullable deviceID, NSError * _Nullable error) {
                   
                   NSString *title = @"Success";
                   NSString *message = [NSString stringWithFormat:@"The device was successfully registered with TPNS. TPNS deviceID is \"%@\"", deviceID];
                   
                   if (error) {
                       title = @"Error";
                       message = [NSString stringWithFormat:@"The device could not be registered with TPNS. Errormessage was \"%@\"", error.localizedDescription];
                   }
                   
                   [self showAlertWithTitle:title message:message];
               }];
}

- (IBAction)unregisterAction:(id)sender {
    
    [[DTPushNotification sharedInstance] unregisterWithCompletion:^(NSError * _Nullable error) {
        
        NSString *title = @"Success";
        NSString *message = @"The device was successfully unregistered with TPNS";
        
        if (error) {
            title = @"Error";
            message = [NSString stringWithFormat:@"The device could not be unregistered with TPNS. Errormessage was \"%@\"", error.localizedDescription];
        }
        
        [self showAlertWithTitle:title message:message];
    }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
