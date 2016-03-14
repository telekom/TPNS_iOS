//
//  ViewController.m
//  TPNS_iOS Sample App
//
//  Created by Deutsche Telekom AG on 15.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "ViewController.h"
#import <TPNS_iOS/DTPushNotification.h>
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
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [application registerUserNotificationSettings:mySettings];
    
    [application registerForRemoteNotifications];
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
                   
                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                                  message:message
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                   
                   UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:nil];
                   
                   [alert addAction:okAction];
                   
                   [self presentViewController:alert animated:YES completion:nil];
               }];
}

- (IBAction)unregisterAction:(id)sender {
    
    [[DTPushNotification sharedInstance] unregisterWithCompletion:^(NSError * _Nullable error) {
        
        NSString *title = @"Success";
        NSString *message = @"The device was successfully unregistered with TPNS";;
        
        if (error) {
            title = @"Error";
            message = [NSString stringWithFormat:@"The device could not be unregistered with TPNS. Errormessage was \"%@\"", error.localizedDescription];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

@end
