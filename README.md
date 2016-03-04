TPNS_iOS is a library to simplify the device registration and unregistration with Telekom Push Notification Service (TPNS).

## Installation

TPNS_iOS supports multiple methods for installing the library in a project.

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like AFNetworking in your projects. See the ["Getting Started" guide for more information](https://github.com/AFNetworking/AFNetworking/wiki/Getting-Started-with-AFNetworking). You can install it with the following command:

```bash
$ gem install cocoapods
```
#### Podfile

To integrate TPNS_iOS into your Xcode project using CocoaPods, specify it in your `Podfile`:

TODO: URL To Specs Repo

```ruby
source 'https:// INSERT SPEC REPO'
pod 'TPNS_iOS', '~> 1.0'
```

Then, run the following command:

```bash
$ pod install
```

### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate TPNS_iOS_ into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
git "https://group-innovation-hub.wesp.telekom.net/gitlab/TPNS/TPNS_iOS.git" ~> 1.0
```

Run `carthage` to build the framework and drag the built `TPNS_iOS.framework` into your Xcode project.

## Usage

### Registering a Device with TPNS

To register a device with TPNS start by calling the corresponding `UIApplication` methods:

```objective-c
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [application registerUserNotificationSettings:mySettings];
    [application registerForRemoteNotifications];
```

After the application gathered all the required information your AppDelegates `didRegisterForRemoteNotificationsWithDeviceToken` method will be called with a generated device token. Use is to register the device with TPNS:

```objective-c
 NSDictionary *params = @{@"key" : @"SomeAdditionalID", @"value" : @4711};

 DTPushNotification *tpns = [DTPushNotification sharedInstance];
    [tpns registerWithURL:[NSURL URLWithString:@"TPNS Endpoint"]
                   appKey:@"APPKEY"
                pushToken:token
     additionalParameters:@[params]
                  sandbox:YES
               completion:^(NSString * _Nullable deviceID, NSError * _Nullable error) {
                if (error) {
                  //handle error
                  return;
                }
                //save the deviceID
    }];
```

If your app needs the returned ``deviceID``, you must take care of storing it yourself.

### Unregistering a Device

To unregister the device, simple call:

```objective-c
[[DTPushNotification sharedInstance] unregisterWithCompletion:^(NSError * _Nullable error) {
        if (error) {
              //handle error
        }
     }];
```
