//
//  AppDelegate.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/17/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import Parse
import AWSSNS
import Flurry_iOS_SDK


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var navigationController: UINavigationController?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Migration.run()

    Flurry.startSession(SecretKey.FlurryKey)
    Flurry.logEvent("Started Application")

    // Initialize Parse.
    Parse.setApplicationId(SecretKey.ParseID,
      clientKey: SecretKey.ParseKey)

    // Register for Push Notitications
    if application.applicationState != UIApplicationState.background {
      // Track an app open here if we launch with a push, unless
      // "content_available" was used to trigger a background push (introduced in iOS 7).
      // In that case, we skip tracking here to avoid double counting the app-open.

      let preBackgroundPush = !application.responds(to: #selector(getter: UIApplication.backgroundRefreshStatus))
      let oldPushHandlerOnly = !self.responds(to: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
      var pushPayload = false
      if let options = launchOptions {
        pushPayload = options[UIApplicationLaunchOptionsKey.remoteNotification] != nil
      }
      if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
      }
    }

    Notifaction.setAfterFirstTime()

    SwiftyStoreKit.completeTransactions() { completedTransactions in
      for completedTransaction in completedTransactions {
        if completedTransaction.transactionState == .purchased || completedTransaction.transactionState == .restored {
          User.setProUser()
          Flurry.logEvent("Buy or Restore Pro Successed")
        }
      }
    }

    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    self.navigationController = storyboard.instantiateInitialViewController() as? UINavigationController

    if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
      if let url = UrlHelper.getURL(notificationPayload["url"] as? String) , Page.getByURL(url) != nil {
        if let tableVC = navigationController?.topViewController as? URLsTableViewController {
          tableVC.showPageOnce = url
        }
      }
    }

    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.rootViewController = navigationController
    self.window?.makeKeyAndVisible()

    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let installation = PFInstallation.current()
    installation?.setDeviceTokenFrom(deviceToken)
    installation?.saveInBackground()

    let deviceTokenString = "\(deviceToken)"
      .trimmingCharacters(in: CharacterSet(charactersIn:"<>"))
      .replacingOccurrences(of: " ", with: "")

    if let uuid = User.createUser(deviceTokenString) {
      installation?.addUniqueObject(uuid, forKey: "channels")
      installation?.saveInBackground()
    }
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    if error._code == 3010 {
      print("Push notifications are not supported in the iOS Simulator.")
    } else {
      print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
    }
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    PFPush.handle(userInfo)
    if application.applicationState == UIApplicationState.inactive {
      PFAnalytics.trackAppOpened(withRemoteNotificationPayload: userInfo)
    }
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    let currentInstallation = PFInstallation.current()
    if currentInstallation?.badge != 0 {
      currentInstallation?.badge = 0
      currentInstallation?.saveEventually()
    }
    
    User.sync()
    Page.sync()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

