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
				API.User.create(getUUID()) { userID in
					currentUserSetID(userID)
				}
			} else {
				API.User.touch(User.getUUID())
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

	static func isOpenNotifaction() -> Bool {
		if currentUser() == nil {
			return false
		} else {
			return true
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

	static func isProUser() -> Bool {
		let ud = NSUserDefaults.standardUserDefaults()
		if let pro = ud.objectForKey(Product.NSUserDefaultsKey) as? Bool {
			return pro
		} else {
			return false
		}
	}

	static func setProUser() {
		let ud = NSUserDefaults.standardUserDefaults()
		ud.setObject(true, forKey: Product.NSUserDefaultsKey)
		ud.synchronize()
	}
}
