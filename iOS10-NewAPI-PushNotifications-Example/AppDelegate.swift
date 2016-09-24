//
//  AppDelegate.swift
//  iOS10-NewAPI-PushNotifications-Example
//
//  Created by Wlad Dicario on 24/09/2016.
//  Copyright © 2016 Sweefties. All rights reserved.
//

import UIKit
import UserNotifications


// ********************************
//
// MARK: - Typealias
//
// ********************************
typealias PushNotifications         = AppDelegate
typealias UserNotificationsExtended = AppDelegate



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    // ********************************
    //
    // MARK: - Properties
    //
    // ********************************
    var window: UIWindow?


    
    // ********************************
    //
    // MARK: - Delegates
    //
    // ********************************
    
    
    /// Tells the delegate that the launch process is almost done and the app is almost ready to run.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Clear badge when app did finish launching
        application.applicationIconBadgeNumber = 0
        
        // get notifications settings.
        getNotificationsSettings()
        
        // set user notifications.
        setUserNotifications()
        
        return true
    }

    
    /// Tells the delegate that the app is about to become inactive.
    func applicationWillResignActive(_ application: UIApplication) {
        //..
    }

    
    /// Tells the delegate that the app is now in the background.
    func applicationDidEnterBackground(_ application: UIApplication) {
        //..
    }

    
    /// Tells the delegate that the app is about to enter the foreground.
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Clear badge when app is or resumed
        application.applicationIconBadgeNumber = 0
    }

    
    /// Tells the delegate that the app has become active.
    func applicationDidBecomeActive(_ application: UIApplication) {
        //..
    }

    
    /// Tells the delegate when the app is about to terminate.
    func applicationWillTerminate(_ application: UIApplication) {
        //..
    }

    
}


extension PushNotifications {
    
    
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
}


extension UserNotificationsExtended {
    
    /// Get Notifications Settings
    ///
    /// Requests the notification settings for this app.
    ///
    func getNotificationsSettings() {
        // Requests the notification settings for this app.
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            switch settings.authorizationStatus {
            case .authorized:
                print(settings.notificationCenterSetting)
                break
            case .denied:
                print(settings.authorizationStatus)
                // alert user, it's required for this application.
                break
            case .notDetermined:
                print(settings.authorizationStatus)
                // alert user to authorize
                break
            }
        }
    }
    
    
    /// Set User Notifications
    ///
    /// to init User Notifications Center and manage actions, categories, requests and others..
    ///
    func setUserNotifications() {
        
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
    }
    
    
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
}
