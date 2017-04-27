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


@interface ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *deviceIdTextfield;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.deviceIdTextfield.delegate = self;
    self.deviceIdTextfield.text = [DTPushNotification sharedInstance].deviceId;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)copyTextFieldContent:(id)sender {
    
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    pb.string = self.deviceIdTextfield.text;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyTextFieldContent:)];
        
        menuController.menuItems = @[copyItem];
        
        CGRect selectionRect = textField.frame;
        
        [menuController setTargetRect:selectionRect inView:self.view];
        [menuController setMenuVisible:YES animated:YES];
    });
    
    return NO;
}

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
    
#ifdef DEBUG
    BOOL sandbox = YES;
#else
    BOOL sandbox = NO;
#endif
    
    DTPushNotification *tpns = [DTPushNotification sharedInstance];
    [tpns registerWithURL:[NSURL URLWithString:DTPNSURLStringPreProduction]
                   appKey:@"YOUR APP KEY"
                pushToken:deviceToken
     additionalParameters:nil
                  sandbox:sandbox
               completion:^(NSString * _Nullable deviceID, NSError * _Nullable error) {
                   
                   NSString *title = @"Success";
                   NSString *message = [NSString stringWithFormat:@"The device was successfully registered with TPNS."];
                   
                   if (error == nil) {
                        self.deviceIdTextfield.text = deviceID;
                   }
                   
                   if (error) {
                       title = @"Error";
                       message = [NSString stringWithFormat:@"The device could not be registered with TPNS. Errormessage was \"%@\"", error.localizedDescription];
                   }
                   
                   [self showAlertWithTitle:title message:message];
               }];
}

- (IBAction)unregisterAction:(id)sender {
    
    self.deviceIdTextfield.text = nil;
    
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
