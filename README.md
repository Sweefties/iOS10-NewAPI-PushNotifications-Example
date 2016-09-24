![](https://img.shields.io/badge/build-pass-brightgreen.svg?style=flat-square)
![](https://img.shields.io/badge/platform-iOS%2010+-ff69b4.svg?style=flat-square)
![](https://img.shields.io/badge/Require-XCode%208-lightgrey.svg?style=flat-square)


# iOS 10 - New API - Push Remote Notifications - Remote Example
iOS 10~ Experiments - New API Components - New Push Remote User Notifications with 3DTouch and iPhone 7.

## Example

![](/source/iOS10-NewAPI-PushNotifications-Example.jpg)


## Requirements

- >= XCode 8.0
- >= Swift 3.
- >= iOS 10.0.
- >= 3D Touch Devices or iOS 10 supported.

Tested on iPhone SE, iPhone 6, iPhone 7 iOS 10.0 Simulators and physicals iPhone 7, iPhone 6, iPhone SE.

## Important

This is a Xcode 8+ / Swift 3+ project.
To run on physicals devices, change the team provisioning profile.

Go to `Project Settings` and select the `Capabilities` tab. Turn on `Push Notifications`

![](/source/xcode-push.png)

turn on `Background Modes` and check `remote notifications`

![](/source/xcode-backgroundmodes.png)


In your `Developer Account section` [Apple Developer](https://developer.apple.com/account/ios/identifier/bundle) select your `App ID`

![](/source/appleDev-1.png)

Click on  `Edit` button

![](/source/appleDev-2.png)

In Development SSL Certificate, click on  `Create Certificate...` button

![](/source/appleDev-3.png)

`Continue` and keep this webpage open.


Now create a certificate, open `Keychain Access` and select the `Keychain Access` -> `Certificate Assistant` -> `Request a Certificate from a Certificate Authority` menu item.

Fill in the form and click `Continue`. Make sure that you select `Saved to disk`

Return to the `Developer Account` webpage and click on `Choose File..` and choose your new certificate created with Keychain Access.

![](/source/appleDev-4.png)


A new webpage appear, download the `aps_development.cer` file and install it by double click.

#### Certificates = DONE!

Tool to send pushs with payloads, download and run [Pusher](https://github.com/noodlewerk/NWPusher)



## References

Read :

 [UNUserNotificationCenter](https://developer.apple.com/reference/usernotifications/unusernotificationcenter)

API Reference :

 [UserNotifications](https://developer.apple.com/reference/usernotifications)

[UserNotificationsUI](https://developer.apple.com/reference/usernotificationsui)



## Usage

To run the example project, download or clone the repo.


### Example Code!


 Import Framework :

```
import UserNotifications
```

Register `UNUserNotificationCenter`

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

  let center = UNUserNotificationCenter.current()

  // define actions
  let ac1 = setAction(id: UNIdentifiers.reply, title: "Reply")
  let ac2 = setAction(id: UNIdentifiers.share, title: "Share")
  let ac3 = setAction(id: UNIdentifiers.follow, title: "Follow")
  let ac4 = setAction(id: UNIdentifiers.destructive, title: "Cancel", options: .destructive)
  let ac5 = setAction(id: UNIdentifiers.direction, title: "Get Direction")

  // define categories
  let cat1 = setCategory(identifier: UNIdentifiers.category, action: [ac1, ac2, ac3, ac4], intentIdentifiers: [])
  let cat2 = setCategory(identifier: UNIdentifiers.customContent, action: [ac5, ac4], intentIdentifiers: [])
  let cat3 = setCategory(identifier: UNIdentifiers.image, action: [ac2], intentIdentifiers: [], options: .allowInCarPlay)
  let cat4 = setCategory(identifier: UNIdentifiers.video, action: [ac2, ac4], intentIdentifiers: [], options: .allowInCarPlay)

  // Registers your app’s notification types and the custom actions that they support.
  center.setNotificationCategories([cat1, cat2, cat3, cat4])

  // Requests authorization to interact with the user when local and remote notifications arrive.
  center.requestAuthorization(options: [.badge, .alert , .sound]) { (granted, error) in
    if error == nil {
      if granted {
        print("do something..")
      }
      }else{
        // show error
        print("request authorization error : \(error?.localizedDescription)")
      }
    }
    // register for remote notifications
    UIApplication.shared.registerForRemoteNotifications()

    return true
  }
```

Set Actions and Categories :

```swift
/// Set User Notifications Action.
///
/// - Parameter id:             `String` identifier string value
/// - Parameter title:          `String` title string value
/// - Parameter options:        `UNNotificationActionOptions` bevavior to the action as `OptionSet`
///
/// - Returns:                  `UNNotificationAction`
///
private func setAction(id: String, title: String, options: UNNotificationActionOptions = []) -> UNNotificationAction {

  let action = UNNotificationAction(identifier: id, title: title, options: options)

  return action
}


/// Set User Notifications Category.
///
/// - Parameter identifier:         `String`
/// - Parameter action:             `[UNNotificationAction]` ask to perform in response to
///                                 a delivered notification
/// - Parameter intentIdentifiers:  `[String]` array of `String`
/// - Parameter options:            `[UNNotificationCategoryOptions]` handle notifications,
///                                 associated with this category `OptionSet`
///
/// - Returns:                      `UNNotificationCategory`
///
private func setCategory(identifier: String, action:[UNNotificationAction],  intentIdentifiers: [String], options: UNNotificationCategoryOptions = []) -> UNNotificationCategory {

  let category = UNNotificationCategory(identifier: identifier, actions: action, intentIdentifiers: intentIdentifiers, options: options)

  return category
}
```

Remote Notifications Delegates

```swift
/// Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
  let token = convertDeviceTokenToString(deviceToken: deviceToken as NSData)

  print("Registration succeeded!")
  print("Token: ", token)
}


/// Sent to the delegate when Apple Push Notification service cannot successfully complete the registration process
func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
  print("Registration failed : \(error.localizedDescription)")
}


/// Tells the app that a remote notification arrived that indicates there is data to be fetched.
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
  //..
  print("userInfo: \(userInfo.debugDescription)")
  reveivedNotification(notification: userInfo as! [String : AnyObject])
}


/// Convert Device Token To String.
///
/// - Parameter deviceToken:    `NSData`
///
/// - Returns:                  `String`
///
func convertDeviceTokenToString(deviceToken: NSData) -> String {

  // Convert binary Device Token to a String (and remove the <,> and white space characters).
  // Our API returns token in all uppercase, regardless how it was originally sent.
  // To make the two consistent, I am uppercasing the token string here.
  let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )

  let deviceTokenString: String = (deviceToken.description as NSString)
  .trimmingCharacters(in: characterSet as CharacterSet)
  .replacingOccurrences(of: " ", with: "")
  .uppercased()

  return deviceTokenString
}


/// Received Notification
///
/// - Parameter notification: `[String:AnyObject]`
///
func reveivedNotification(notification: [String:AnyObject]) {
  let vc = window?.rootViewController
  let view = vc as? MainVC

  view?.addNotificationModel(
    data: getDataFromNotification(notification: notification)
    )
  }


  /// Get Apns Data From Remote Notification
  ///
  /// - Parameter notification: `[String: AnyObject]`
  ///
  /// - Returns: `UNContent` model collection as `UNMutableNotificationContent`
  ///
  func getDataFromNotification(notification: [String: AnyObject]) -> UNContent {
    guard
    let aps     = notification["aps"]   as? [String:AnyObject],
    let alert   = aps["alert"]          as? [String:AnyObject]
    else { fatalError("something went wrong") }

    let title       = alert["title"]    as? String ?? "-"
    let subTitle    = alert["subtitle"] as? String ?? "-"
    let body        = alert["body"]     as? String ?? "-"

    let content = UNContent.init(title: title, subTitle: subTitle, body: body)

    return content
  }
```

`UNNotificationContentExtension` Content Extension - Add Target to your project

![](/source/xcode-targetContent.png)

update `Info.plist` file

![](/source/xcode-contentPlist.png)

example code for custom content

```swift
/// Called when a notification arrives for your app.
///
/// - Parameter notification: `UNNotification`
///
func didReceive(_ notification: UNNotification) {

  // render map view
  self.renderedMap("\(notification.request.content.title)", subtitle: "\(notification.request.content.body)", latitude: 41.404499, longitude: 2.174290000000042)

  // set attributed text for label
  let mainStr  = "  \(notification.request.content.body)\n  \(notification.request.content.subtitle)"
  let colorStr = "iOS 10 - New API"

  let range = (mainStr as NSString).range(of: colorStr)
  let attribute = NSMutableAttributedString.init(string: mainStr)
  attribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.black , range: range)
  attribute.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 17.0), range: range)

  self.placeLabel.attributedText = attribute

}
```

`UNNotificationServiceExtension` Service Extension - Add Target to your project

![](/source/xcode-targetService.png)

example code for download a file

```swift
override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
  self.contentHandler = contentHandler
  bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

  // Get the custom data from the notification payload
  if let data = request.content.userInfo["data"] as? [String: String] {
    // Grab the attachment
    if let urlString = data["attachment-url"], let fileUrl = URL(string: urlString) {
      // Download the attachment
      URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
        if let location = location {
          // Move temporary file to remove .tmp extension
          let tmpDirectory = NSTemporaryDirectory()
          let tmpFile = "file://".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
          let tmpUrl = URL(string: tmpFile)!
          try! FileManager.default.moveItem(at: location, to: tmpUrl)

          // Add the attachment to the notification content
          if let attachment = try? UNNotificationAttachment(identifier: "", url: tmpUrl) {
            self.bestAttemptContent?.attachments = [attachment]
          }
        }
        // Serve the notification content
        self.contentHandler!(self.bestAttemptContent!)
        }.resume()
      }
    }

  }
```

Et Voilà!

- Build and Run!

Now Send your Push with Pusher by select your certificate and token generated in xcode at build.

![](/source/pusher.png)



- By pressing lightly (`Peek`) and pressing a little more firmly to actually open content (`Pop`)
- Optimized for Devices : iPhone 6s and others 3D Touch devices!



Some Examples of `Payloads`

Simple Rich Notification

```json
{
 "aps" : {
    "alert" : {
        "title" : "Push Remote Rich Notifications",
        "subtitle" : "iOS 10 - New API",
        "body" : "Simple Rich notification"
        },
    },
}
```

Media Rich Notification - Image

```json
{
 "aps" : {
    "alert" : {
        "title" : "Push Remote Rich Notifications",
        "subtitle" : "iOS 10 - New API",
        "body" : "Media Image Rich notification"
        },
	"mutable-content" : 1,
	"category" : "imageIdentifier"
    },
    "data" : {
      "attachment-url": "https://raw.githubusercontent.com/Sweefties/iOS10-NewAPI-UserNotifications-Example/master/source/iOS10-NewAPI-UserNotifications-Example.jpg"
    }
}
```

Media Rich Notification - Video

```json
{
 "aps" : {
    "alert" : {
        "title" : "Push Remote Rich Notifications",
        "subtitle" : "iOS 10 - New API",
        "body" : "Media Video Rich notification"
        },
	"mutable-content" : 1,
	"category" : "videoIdentifier"
    },
    "data" : {
      "attachment-url": "https://github.com/Sweefties/WatchOS2-NewUI-Movie-Example/raw/master/WatchOS2-NewUI-Movie-Example%20WatchKit%20App/MoviePath/burningmanbyair.m4v"
    }
}
```

Actionable Rich Notification

```json
{
 "aps" : {
    "alert" : {
        "title" : "Push Remote Rich Notifications",
        "subtitle" : "iOS 10 - New API",
        "body" : "Actionable Rich notification"
        },
	"category" : "categoryIdentifier"
    },
}
```

Custom Content Rich Notification

```json
{
 "aps" : {
    "alert" : {
        "title" : "Push Remote Rich Notifications",
        "subtitle" : "iOS 10 - New API",
        "body" : "Custom Content Rich notification"
        },
	"category" : "customContentIdentifier"
    },
}
```
