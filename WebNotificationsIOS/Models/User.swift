//
//  User.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/23/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    dynamic var uuid = ""
	dynamic var email = ""
	dynamic var password = ""


	override static func primaryKey() -> String? {
		return "uuid"
	}

	static func createUUID() -> String? {
		do {
			let realm = try Realm()
			let users = realm.objects(User)
			if users.count > 0 {
				return nil
			} else {
				let user = User()
				let uuid = "user_" + NSUUID().UUIDString
				user.uuid = uuid
				user.email = uuid
				realm.write {
					realm.add(user)
				}
				return uuid
			}
		} catch {
			return nil
		}
	}

	static func getUUID() -> String? {
		do {
			let realm = try Realm()
			let users = realm.objects(User)
			if users.count > 0 {
				return users.first!.uuid
			} else {
				return nil
			}
		} catch {
			return nil
		}
	}

	private struct Key {
		static let pro = "proUser"
	}

	static func isProUser() -> Bool {
		let ud = NSUserDefaults.standardUserDefaults()
		if let pro = ud.objectForKey(Key.pro) as? Bool {
			return pro
		} else {
			return false
		}
	}

	static func setProUser() {
		let ud = NSUserDefaults.standardUserDefaults()
		ud.setObject(true, forKey: Key.pro)
		ud.synchronize()
	}
}
