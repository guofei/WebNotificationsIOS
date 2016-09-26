//
//  Migration.swift
//  WebNotificationsIOS
//
//  Created by kaku on 11/18/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import RealmSwift

class Migration {
  static func run() {
    let config = Realm.Configuration(
      schemaVersion: 3,

      migrationBlock: { migration, oldSchemaVersion in
        if (oldSchemaVersion < 3) {
          // Page.contentDiff wil be automatically added in v1
          // Page.changed will be automatically added in v2
          // Page.cellIndex will be automatically added in v2
          // User.deviceToken will be automatically added in v3
          // User.deviceType will be automatically added in v3
          // User.localeIdentifier will be automatically added in v3
          // User.timeZone will be automatically added in v3
        }
    })

    Realm.Configuration.defaultConfiguration = config
    
    _ = try! Realm()
  }
}