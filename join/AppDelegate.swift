//
//  AppDelegate.swift
//  join
//
//  Created by 連亮涵 on 2020/5/14.
//  Copyright © 2020 gmpsykr. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import FirebaseInstanceID
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDynamicLinks
import AppsFlyerLib
import UserNotifications
import SwiftyStoreKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //AppFlyerLib
        AppsFlyerLib.shared().appsFlyerDevKey = "N63DeRmtesiH6X5AG5Cj2R"
        AppsFlyerLib.shared().appleAppID = "1516436708"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = true
        // Override point for customization after application launch.
        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            // 在程式一啟動即詢問使用者是否接受圖文(alert)、聲音(sound)、數字(badge)三種類型的通知
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in }
            application.registerForRemoteNotifications()
        }
        else
        {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    
        //App內購
        setupIAP()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(" user info \(userInfo)")
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: restorationHandler)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            return true
        }
        
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        var handled = true
        
        if Auth.auth().canHandle(url) {
            handled = true
        }
        else if (url.absoluteString.range(of: "com.gmpsykr.join://") != nil){
            handled = application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: "")
        }
        
        AppsFlyerLib.shared().handleOpen(url, options: options)
        
        return handled
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
        // ...
        }
        
        return true
    }
       
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                globalData.fcmToken = result.token
                globalData.fcmReady = true
                if globalData.loginReady && globalData.fcmReady {
                    NotificationCenter.default.post(name: Notifications.autoLogin, object: nil)
                }
            }
        }
    }

    func setupIAP() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    print("Fatal Error")
                }
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//       // show the notification alert (banner), and with sound
//       completionHandler([.alert, .sound])
//     }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo as! [String: Any]
    
        if let callapi = userInfo["callapi"] as? String, let notify_memo = userInfo["notify_memo_json"] as? String
        {
            let jsonMemo = JsonMemo()
            let data = notify_memo.data(using: .utf8)!
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options : []) as? [String: Any] {
                    parseJsonMemo(jsonMemo: jsonMemo, memo: json)
                    
                }
            } catch let error as NSError {
                print(error)
            }

            globalData.callapi = callapi
            globalData.jasonMemo = jsonMemo
            
            //scroll: 1 true 0 false
            switch callapi {
            case "queryuser_mypage":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPostVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPartyVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
                NotificationCenter.default.post(name: userNotifications.queryuser, object: nil, userInfo: ["uid": jsonMemo.uid, "otherReason": jsonMemo.otherReason])
            case "getpost":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPostVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPartyVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
                NotificationCenter.default.post(name: userNotifications.getpost, object: nil, userInfo: ["uid": jsonMemo.uid, "pid": jsonMemo.pid])
            case "getPostComtDetail":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPostVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPartyVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
                NotificationCenter.default.post(name: userNotifications.getpost, object: nil, userInfo: ["cmtid": jsonMemo.cmtid, "pid": jsonMemo.pid, "scroll": "1"])
            case "getparty":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPostVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPartyVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
                NotificationCenter.default.post(name: userNotifications.getparty, object: nil, userInfo: ["uid": jsonMemo.ptid, "ptid": jsonMemo.uid])
            case "getPartyComtDetail":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPostVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPartyVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
                NotificationCenter.default.post(name: userNotifications.getparty, object: nil, userInfo: ["cmtid": jsonMemo.cmtid, "ptid": jsonMemo.ptid, "isPublic": jsonMemo.isPublic, "username": jsonMemo.username, "userIcon": jsonMemo.userIcon, "uid": jsonMemo.uid, "scroll": "1", "myUid": jsonMemo.myUid])
            case "getUnreviewedList":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPostVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPartyVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
                NotificationCenter.default.post(name: userNotifications.getUnreviewedList, object: nil, userInfo: ["uid": jsonMemo.uid, "ptid": jsonMemo.ptid])
            case "getAttendanceList":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPostVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPartyVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectNoty"), object: nil)
                NotificationCenter.default.post(name: userNotifications.getAttendanceList, object: nil, userInfo: ["ptid": jsonMemo.ptid])
            case "getphoto":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPostVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPartyVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectHome"), object: nil)
            case "openchat":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPostVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closePresentedPartyVC"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectChat"), object: nil)
                NotificationCenter.default.post(name: userNotifications.openChat, object: nil, userInfo: ["chtid": jsonMemo.chtid, "senduid": jsonMemo.senduid, "username": jsonMemo.username, "userIcon": jsonMemo.userIcon, "shortid": jsonMemo.shortid])
            default:
                break
            }
           
        }
        // tell the app that we have finished processing the user’s action / response
        completionHandler()
      }
}

extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
            if let nav = viewController as? UINavigationController {
                return topViewController(viewController: nav.visibleViewController)
            }
            if let tab = viewController as? UITabBarController {
                if let selected = tab.selectedViewController {
                    return topViewController(viewController: selected)
                }
            }
            if let presented = viewController?.presentedViewController {
                return topViewController(viewController: presented)
            }
            return viewController
        }
}

//MARK: AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate{
    // Handle Organic/Non-organic installation
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        print("onConversionDataSuccess data:")
        for (key, value) in installData {
            print(key, ":", value)
        }
        if let status = installData["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                    let campaign = installData["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = installData["is_first_launch"] as? Bool,
                is_first_launch {
                print("First Launch")
            } else {
                print("Not First Launch")
            }
        }
    }
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    //Handle Deep Link
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        //Handle Deep Link Data
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
}
