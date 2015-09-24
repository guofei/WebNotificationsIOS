//
//  Url.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/20/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import Ji


class Page: Object {
	dynamic var id = 0
    dynamic var url = ""
	dynamic var sec = 3 * 60 * 60
	dynamic var pushChannel = ""
	dynamic var stopFetch = true
	dynamic var title = "unknown"
	dynamic var content = ""
	dynamic var digest = ""
	dynamic var createdAt = NSDate()
	dynamic var updatedAt = NSDate()

	override static func primaryKey() -> String? {
		return "url"
	}

	func formatedUpdate() -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.timeStyle = .ShortStyle
		dateFormatter.dateStyle = .ShortStyle
		return dateFormatter.stringFromDate(updatedAt)
	}

	static func deleteByURL(url: String?) -> Bool {
		if url != nil {
			do {
				let realm = try Realm()
				let predicate = NSPredicate(format: "url = %@", url!)
				let pages = realm.objects(Page).filter(predicate)
				for page in pages {
					try realm.write {
						realm.delete(page)
					}
				}
				return true
			} catch {
				return false
			}
		}

		return false
	}

	private struct API {
		static let URL = "http://webupdatenotification.com/pages"
	}

	static func add(url: String?, second: Int, stopFetch: Bool, closure: (Bool) -> Void) {
		let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
		let queue = dispatch_get_global_queue(qos, 0)
		dispatch_async(queue) {
			if let url = url {
				let jiDoc = Ji(htmlURL: NSURL(string: url)!)
				let title = jiDoc?.xPath("//title")?.first?.content
				let body = jiDoc?.xPath("//body")?.first?.content
				let content = body == nil ? jiDoc?.rootNode?.content : body
				let page = Page()
				page.url = url
				if let uuid = User.getUUID() {
					page.pushChannel = uuid
					let parameters = [
						"page": [
							"url": page.url,
							"sec": page.sec,
							"push_channel": page.pushChannel,
							"stop_fetch": page.stopFetch
						]
					]
					Alamofire.request(.POST, API.URL, parameters: parameters).responseJSON { response in
						switch response.2 {
						case .Success:
							if let dic = response.2.value as? Dictionary<String,AnyObject> {
								if let id = dic["id"] {
									print("JSON: \(id)")
								}
							}
						case .Failure(let error):
							print(error)
						}
					}
				}
				if title != nil {
					page.title = title!
				}
				if content != nil {
					page.content = content!
				}
				do {
					let realm = try Realm()
					try realm.write {
						realm.add(page)
					}
				} catch {
					print("database error")
				}
				closure(true)
			} else {
				closure(false)
			}
		}
	}

	// TODO remove when update
	static func updateAll(closure: (Dictionary<String, Bool>) -> Void) {
		let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
		let queue = dispatch_get_global_queue(qos, 0)
		dispatch_async(queue) {
			var result = [String: Bool]()
			do {
				let realm = try Realm()
				let pages = realm.objects(Page)
				for	page in pages {
					let jiDoc = Ji(htmlURL: NSURL(string: page.url)!)
					if jiDoc == nil {
						continue
					}
					let title = jiDoc?.xPath("//title")?.first?.content
					let body = jiDoc?.xPath("//body")?.first?.content
					let content = body == nil ? jiDoc?.rootNode?.content : body
					if page.title != title || page.content != content {
						try realm.write {
							if title != nil {
								page.title = title!
							}
							if content != nil {
								page.content = content!
							}
							page.updatedAt = NSDate()
						}
						result[page.url] = true
					}
				}
			} catch {
				print("database error")
			}
			closure(result)
		}
	}
}