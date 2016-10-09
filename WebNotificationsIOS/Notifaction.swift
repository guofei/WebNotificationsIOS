//
//  Notifaction.swift
//  WebNotificationsIOS
//
//  Created by kaku on 10/28/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

enum Notifaction: String {
  case UNKNOWN = "notifactionUnknown"
  case ON = "notifactionOn"
  case OFF = "notifactionOff"

  static func type() -> Notifaction {
    let ud = UserDefaults.standard
    if let _ = ud.object(forKey: Notifaction.toString()) as? String {
      if UIApplication.shared.isRegisteredForRemoteNotifications {
        return ON
      } else {
        return OFF
      }
    } else {
      return UNKNOWN
    }
  }

  static func setFirstTime() {
    if type() == Notifaction.UNKNOWN {
      let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      UIApplication.shared.registerUserNotificationSettings(settings)
      UIApplication.shared.registerForRemoteNotifications()
      setOpen(true)
    }
  }

  static func setAfterFirstTime() {
    if type() != Notifaction.UNKNOWN {
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert , .sound]) { (greanted, error) in
          if greanted {
            UIApplication.shared.registerForRemoteNotifications();
          }
        }
      } else {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
      }
      setOpen(true)
    }
  }

  fileprivate static func setOpen(_ isOpen: Bool) {
    let ud = UserDefaults.standard
    if isOpen {
      ud.set(ON.rawValue, forKey: toString())
    } else {
      ud.set(OFF.rawValue, forKey: toString())
    }
    ud.synchronize()
  }
  
  
  fileprivate static func toString() -> String {
    return "NotificationType"
  }
}

