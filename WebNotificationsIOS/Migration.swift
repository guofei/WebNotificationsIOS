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
			schemaVersion: 2,

			migrationBlock: { migration, oldSchemaVersion in
				if (oldSchemaVersion < 2) {
					// Page.contentDiff wil be automatically added in v1
					// Page.changed will be automatically added in v2
					// Page.cellIndex will be automatically added in v2
				}
		})

		Realm.Configuration.defaultConfiguration = config

		_ = try! Realm()
	}
}