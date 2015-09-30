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

class User: Object {
	dynamic var id = 0
    dynamic var uuid = ""
	dynamic var email = ""
	dynamic var password = ""


	override static func primaryKey() -> String? {
		return "uuid"
	}

	private struct API {
		static let ADD = "http://webupdatenotification.com/users"
		static let TOUCH = "http://webupdatenotification.com/users/touch"
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

	static func currentUserSetID(id: Int?) {
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

	static func createUserToServer(channel: String) {
		if !isOpenNotification() {
			return
		}
		let parameters = [
			"user": [ "channel": channel ]
		]
		Alamofire.request(.POST, API.ADD, parameters: parameters).responseJSON { response in
			switch response.2 {
			case .Success:
				if let dic = response.2.value as? Dictionary<String, AnyObject> {
					if let serverID = dic["id"] as? Int {
						currentUserSetID(serverID)
					}
				}
			case .Failure(let error):
				print(error)
			}
		}
	}

	static func touchServer() {
		if !isOpenNotification() {
			return
		}
		let uuid = getUUID()
		if uuid == nil {
			return
		}

		let parameters = [
			"user": [ "channel": uuid! ]
		]
		Alamofire.request(.POST, API.TOUCH, parameters: parameters)
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
				createUserToServer(uuid)
				return uuid
			}
		} else {
			return nil
		}
	}

	static func isOpenNotification() -> Bool {
		if getUUID() == nil {
			return false
		} else {
			return true;
		}
	}

	static func getUUID() -> String? {
		return currentUser()?.uuid
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
