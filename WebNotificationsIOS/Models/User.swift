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


	override static func primaryKey() -> String? {
		return "uuid"
	}

	static func currentUser() -> User? {
		if let realm = getDB() {
			let users = realm.objects(User)
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
			if user.id <= 0 {
				API.UserAPI.create(getUUID()) { userID in
					currentUserSetID(userID)
				}
			} else {
				API.UserAPI.touch(User.getUUID())
			}
		}
	}

	static func createUUID() -> String? {
		if let realm = getDB() {
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
				sync()
				return uuid
			}
		} else {
			return nil
		}
	}

	private static func currentUserSetID(id: Int?) {
		if id == nil {
			return
		}
		if let user = currentUser() {
			if let realm = getDB() {
				realm.write {
					user.id = id!
				}
			}
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
