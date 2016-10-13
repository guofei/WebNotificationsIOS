//
//  User.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/23/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire


// uuid is equal channel
class User: Object {
  dynamic var id = 0
  dynamic var uuid = ""
  dynamic var email = ""
  dynamic var password = ""

  // schemaVersion: 3
  dynamic var deviceToken = ""
  dynamic var deviceType = "iOS"
  dynamic var localeIdentifier = Locale.current.identifier
  dynamic var timeZone = TimeZone.autoupdatingCurrent.identifier


  override static func primaryKey() -> String? {
    return "uuid"
  }

  static func currentUser() -> User? {
    if let realm = getDB() {
      let users = realm.objects(User.self)
      if users.count > 0 {
        return users.first
      } else {
        return nil
      }
    } else {
      return nil
    }
  }

  static func getUUID() -> String? {
    return currentUser()?.uuid
  }

  static func sync() {
    if let user = currentUser() {
      API.User.create(user.uuid, token: user.deviceToken, type: user.deviceType, locale: user.localeIdentifier, zone: user.timeZone) { userID, deviceToken in
        currentUserSetIDAndDeviceToken(userID, deviceToken: deviceToken)
      }
    }
  }

  static func createUser(deviceToken: String) -> String? {
    if let realm = getDB() {
      let users = realm.objects(User.self)
      if users.count > 0 {
        let user = users.first
        try! realm.write {
          user?.deviceToken = deviceToken
        }
        return nil
      } else {
        let user = User()
        let uuid = "user_" + UUID().uuidString
        user.uuid = uuid
        user.email = uuid
        user.deviceToken = deviceToken
        try! realm.write {
          realm.add(user)
        }
        sync()
        return uuid
      }
    } else {
      return nil
    }
  }

  static func isOpenNotifaction() -> Bool {
    if currentUser() == nil {
      return false
    } else {
      return true
    }
  }

  fileprivate static func currentUserSetIDAndDeviceToken(_ id: Int?, deviceToken: String?) {
    if id == nil || deviceToken == nil {
      return
    }
    if let user = currentUser() {
      if let realm = getDB() {
        try! realm.write {
          user.id = id!
          if user.deviceToken.isEmpty {
            user.deviceToken = deviceToken!
          }
        }
      }
    }
  }

  static func isProUser() -> Bool {
    let ud = UserDefaults.standard
    if let pro = ud.object(forKey: Product.NSUserDefaultsKey) as? Bool {
      return pro
    } else {
      return false
    }
  }
  
  static func setProUser() {
    let ud = UserDefaults.standard
    ud.set(true, forKey: Product.NSUserDefaultsKey)
    ud.synchronize()
  }
}
