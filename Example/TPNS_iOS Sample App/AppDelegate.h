//
//  AppDelegate.h
//  TPNS_iOS Sample App
//
//  Created by Deutsche Telekom AG on 15.02.16.
//  Copyright © 2016 Deutsche Telekom AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
typedef void(^AppDelegateRegisteredRemoteNotifications)(AppDelegate *appdelegate, NSData *token);
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) AppDelegateRegisteredRemoteNotifications registeredForRemoteNotificationsCallback;

@end

