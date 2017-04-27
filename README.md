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

```ruby
pod 'TPNS_iOS', :git => 'https://github.com/dtag-dbu/TPNS_iOS.git'
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
git "https://github.com/dtag-dbu/TPNS_iOS.git" ~> 1.0
```

Run `carthage` to build the framework and drag the built `TPNS_iOS.framework` into your Xcode project.

## Usage

### Registering a Device with TPNS

To register a device with TPNS start by calling the corresponding `UIApplication` methods:

iOS 9 and prior:
```objective-c
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [application registerUserNotificationSettings:mySettings];
    [application registerForRemoteNotifications];
```

iOS 10+:
```objective-c
UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
center.delegate = self;

UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
[center requestAuthorizationWithOptions:types
                      completionHandler:^(BOOL granted, NSError * _Nullable error) {

                          if (nil == error) {
                              [application registerForRemoteNotifications];
                          }

                      }];
```

After the application gathered all the required information your AppDelegates `didRegisterForRemoteNotificationsWithDeviceToken` method will be called with a generated device token. Use is to register the device with TPNS:

```objective-c
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    NSArray *params = @[@{@"key" : @"SomeAdditionalID", @"value" : @4711},
                            @{@"key" : @"OtherID", @"value" : @"randomValue"}];

    DTPushNotification *tpns = [DTPushNotification sharedInstance];
    if(tpns.isRegistered) {
    	//Already registered no need to register again
    	return;
    }
    
    [tpns registerWithURL:[NSURL URLWithString:@"TPNS Endpoint"] //The different endpoints are defined in the TPNS_iOS.h file
                   appKey:@"APPKEY"
                pushToken:token
     additionalParameters:params
                  sandbox:YES
               completion:^(NSString * _Nullable deviceID, NSError * _Nullable error) {
                       if (error) {
                           //handle error
                           return;
                       }
                       //save the deviceID
                   }];
}
```

If your app needs the returned ``deviceID``, you can call the related property
```objective-c
[DTPushNotification sharedInstance].deviceId
```

To check if you already registered you just need to call ```registered``` method
```objective-c
[DTPushNotification sharedInstance].isRegistered
```

### Unregistering a Device

To unregister the device, simple call:

```objective-c


DTPushNotification *tpns = [DTPushNotification sharedInstance];
if(!tpns.isRegistered) {
    //Not registered yet no need to unregister
    return;
}

[tpns unregisterWithCompletion:^(NSError * _Nullable error) {
        if (error) {
              //handle error
        }
     }];
```

### Error Codes

Beside the standard HTTP error codes there a more error codes in the ```NSError+TPNS.h``` file defined
```objective-c
typedef NS_ENUM(NSInteger, TPNSErrorCode)
{
    // General
    TPNSErrorCodeDeviceNotRegistered                = -1000,
    TPNSErrorCodeRegistrationIsAlreadyInProgress    = -1001,
    TPNSErrorCodeUnregisterBeforeYouRegisterAgain   = -1002,
};
```

## Testing
To test if everything is working you can run the following curl command in the terminal
```
curl -X POST -H "Accept: application/json" -H "Accept-Encoding: gzip" -H "Content-Type: application/json" -H "Cache-Control: no-cache"  -d '[{"message" : "Test","handlingLevel" : 1,"applicationKey" : "APPKEY","applicationTypes" : ["IOS_SAND"], "deviceIds" : ["YOUR SAVED DEVICE ID"]}]' "'TPNS Endpoint'/api/pushnotifications"
```

JSON Payload:
```
[{
	"message": "Test",
	"handlingLevel": 1, //1, 2 or 3, depends on your configuration
	"applicationKey": "APP Key",
	"applicationTypes": ["IOS_SAND"], // 'IOS_SAND' for Sandbox otherwise 'IOS'
	"deviceIds": ["YOUR SAVED DEVICE ID"] // deviceID or null for every device
}]
```

### Available Endpoints
* Production: https://tpns.molutions.de/TPNS/
* Pre-Production: https://tpns-preprod.molutions.de/TPNS/


