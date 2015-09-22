//
//  Url.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/20/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import RealmSwift
import Ji


class Page: Object {
    dynamic var url = ""
	dynamic var sec = 3 * 60 * 60
	dynamic var pushChannel = ""
	dynamic var stopFetch = false
	dynamic var title = ""
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

	static func add(url: String?) -> Bool {
		if let url = url {
			let page = Page()
			page.url = url
			do {
				let realm = try Realm()
				try realm.write {
					realm.add(page)
				}
			} catch {
				return false
			}
			return true
		} else {
			return false
		}
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
					let title = jiDoc?.xPath("//head/title")?.first?.content
					let body = jiDoc?.xPath("//body")
					let content = body == nil ? jiDoc?.description : body?.first?.content
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