//
//  ViewController.m
//  TPNS_iOS Sample App
//
//  Created by Deutsche Telekom AG on 15.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "ViewController.h"
#import <TPNS_iOS/DTPushNotification.h>

@interface ViewController ()

@end

@implementation ViewController


- (IBAction)unregisterAction:(id)sender
{
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
