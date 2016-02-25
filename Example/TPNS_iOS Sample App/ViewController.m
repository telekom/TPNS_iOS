//
//  ViewController.m
//  TPNS_iOS Sample App
//
//  Created by Deutsche Telekom AG on 15.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import "ViewController.h"
@import TPNS_iOS;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unregisterAction:(id)sender
{
    [[DTPushNotification sharedInstance] unregisterWithCompletion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = nil;
            NSString *message = nil;
            
            if(error)
            {
                title = @"Error";
                message = [NSString stringWithFormat:@"The device could not be unregistered with TPNS. Errormessage was \"%@\"", error.localizedDescription];
            } else {
                title = @"Success";
                message = @"The device was successfully unregistered with TPNS";
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [alert removeFromParentViewController];
                                                             }];
            
            [alert addAction:okAction];
            
            [self showViewController:alert sender:self];
        });

    }];
}

@end
