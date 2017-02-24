//
//  AppDelegate.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/17/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import SwiftyStoreKit
import AWSSNS
import Flurry_iOS_SDK

func urlFromUserInfo(_ userInfo: [AnyHashable: Any]) -> String? {
  guard let aps = userInfo["aps"] as? NSDictionary else {
    return nil
  }
  guard let url = aps["url"] as? String else {
    return nil
  }
  return UrlHelper.getURL(url)
}

func urlFromOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> String? {
  if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable : Any] {
    return urlFromUserInfo(userInfo)
  }
  return nil
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Fabric.with([Crashlytics.self])

    Migration.run()

    Flurry.startSession(SecretKey.FlurryKey)
    Flurry.logEvent("Started Application")

    Notifaction.setAfterFirstTime()

    SwiftyStoreKit.completeTransactions(atomically: true) { products in
      for product in products {
        if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
          User.setProUser()
          Flurry.logEvent("Buy or Restore Pro Successed")
        }
      }
    }

    if let url = urlFromOptions(launchOptions) {
      if Page.getByURL(url) != nil {
        if let root = self.window?.rootViewController as? UINavigationController {
          if let tableVC = root.topViewController as? URLsTableViewController {
            tableVC.showPageOnce = url
          }
        }
      }
    }

    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    print(deviceTokenString)
    _ = User.createUser(deviceTokenString)
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    if error._code == 3010 {
      print("Push notifications are not supported in the iOS Simulator.")
    } else {
      print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
    }
  }

  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    guard let url = urlFromUserInfo(userInfo) else {
      return
    }
    if Page.getByURL(url) == nil {
      return
    }
    Page.update(url, done: {_ in })

    /*
    if (application.applicationState == UIApplicationState.active) {
      if let root = self.window?.rootViewController as? UINavigationController {
        if let tableVC = root.topViewController as? URLsTableViewController {
          tableVC.reloadData()
        }
      }
    } else if (application.applicationState == UIApplicationState.inactive) {
      Page.update(url, done: {_ in })
    } else {
      // background
      Page.update(url, done: {_ in })
    }
    */
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. 
    // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
    // or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough application state information to restore your application to
    // its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    /*
    if let root = self.window?.rootViewController as? UINavigationController {
      if let tableVC = root.topViewController as? URLsTableViewController {
        tableVC.reloadData()
      }
    }
    */
    User.sync()
    Page.syncRemoteToLoacle()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}
