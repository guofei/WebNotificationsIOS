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
			schemaVersion: 1,

			migrationBlock: { migration, oldSchemaVersion in
				if (oldSchemaVersion < 1) {
					migration.enumerate(Page.className()) { oldObject, newObject in
						newObject!["contentDiff"] = ""
					}
				}
		})

		Realm.Configuration.defaultConfiguration = config

		_ = try! Realm()
	}
}