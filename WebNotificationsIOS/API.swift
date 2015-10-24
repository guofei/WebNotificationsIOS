//
//  API.swift
//  WebNotificationsIOS
//
//  Created by kaku on 10/1/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire


class API {
	class Page {
		private struct URL {
			static let USERGET = "http://webupdatenotification.com/users/"
			static let PAGEADD = "http://webupdatenotification.com/pages"
			static let PAGEUPDATE = "http://webupdatenotification.com/pages/"
		}
		static func create(url: String?, uuid: String?, second: Int?, stopFetch: Bool?, clourse: (id: Int?) -> Void) {
			if url == nil || uuid == nil || second == nil || stopFetch == nil {
				return
			}

			let parameters = [
				"page": [
					"url": url!,
					"sec": second!,
					"push_channel": uuid!,
					"stop_fetch": stopFetch!
				]
			]
			Alamofire.request(.POST, URL.PAGEADD, parameters: parameters).responseJSON { response in
				switch response.result {
				case .Success:
					if let dic = response.result.value as? Dictionary<String, AnyObject> {
						if let id = dic["id"] as? Int {
							clourse(id: id)
						}
					}
				case .Failure(let error):
					print(error)
				}
			}
		}

		static func update(id: Int?, url: String?, second: Int?, uuid: String?, stopFetch: Bool?) {
			if id == nil || url == nil || uuid == nil || second == nil || stopFetch == nil {
				return
			}
			if id! <= 0 {
				return
			}

			let updateURL = URL.PAGEUPDATE + "\(id!)"
			let parameters = [
				"page": [
					"url": url!,
					"sec": second!,
					"push_channel": uuid!,
					"stop_fetch": stopFetch!
				]
			]
			Alamofire.request(.PUT, updateURL, parameters: parameters)
		}

		static func all(userID: Int?, each: (id: Int?, url: String?, second: Int?, stopFetch: Bool?) -> Void) {
			if userID == nil {
				return
			}
			if userID! <= 0 {
				return
			}
			let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
			let queue = dispatch_get_global_queue(qos, 0)
			dispatch_async(queue) {
				let getURL = URL.USERGET + "\(userID!)" + "/pages"
				Alamofire.request(.GET, getURL).responseJSON { response in
					switch response.result {
					case .Success:
						if let arr = response.result.value as? Array<Dictionary<String, AnyObject>> {
							for item in arr {
								let id = item["id"] as? Int
								let url = item["url"] as? String
								let stopFetch = item["stop_fetch"] as? Bool
								let sec = item["sec"] as? Int
								each(id: id, url: url, second: sec, stopFetch: stopFetch)
							}
						}
					case .Failure(let error):
						print(error)
					}
				}
			}
		}
	}

	class User {
		private struct URL {
			static let ADD = "http://webupdatenotification.com/users"
			static let TOUCH = "http://webupdatenotification.com/users/touch"
		}

		static func create(uuid: String?, result: (userID: Int?) -> Void) {
			if uuid == nil || uuid?.characters.count <= 0 {
				return
			}

			let parameters = [
				"user": [ "channel": uuid! ]
			]
			Alamofire.request(.POST, URL.ADD, parameters: parameters).responseJSON { response in
				switch response.result {
				case .Success:
					if let dic = response.result.value as? Dictionary<String, AnyObject> {
						if let id = dic["id"] as? Int {
							result(userID: id)
						}
					}
				case .Failure(let error):
					print(error)
				}
			}
		}

		static func touch(uuid: String?) {
			if uuid == nil {
				return
			}

			let parameters = [
				"user": [ "channel": uuid! ]
			]
			Alamofire.request(.POST, URL.TOUCH, parameters: parameters)
		}
	}
}