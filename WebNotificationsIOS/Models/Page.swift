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
					let content = jiDoc?.description
					if page.title != title || page.content != content {
						if title != nil {
							page.title = title!
						}
						if content != nil {
							page.content = content!
						}

						try realm.write {
							realm.add(page, update: true)
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