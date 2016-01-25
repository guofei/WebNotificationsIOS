//
//  DBHelper.swift
//  WebNotificationsIOS
//
//  Created by kaku on 10/1/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import RealmSwift

func getDB() -> Realm? {
  do {
    let realm = try Realm()
    return realm
  } catch {
    return nil
  }
}