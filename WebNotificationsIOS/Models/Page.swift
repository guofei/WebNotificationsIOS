//
//  Url.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/20/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import RealmSwift


// pushChannel is equal User::uuid
class Page: Object {
	dynamic var id = 0
    dynamic var url = ""
	dynamic var sec = 0
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

	func formatedUpdateTime() -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.timeStyle = .ShortStyle
		dateFormatter.dateStyle = .ShortStyle
		return dateFormatter.stringFromDate(updatedAt)
	}

	private static func getByURL(url: String?) -> Page? {
		if url == nil {
			return nil
		}
		if let realm = getDB() {
			let predicate = NSPredicate(format: "url = %@", url!)
			let pages = realm.objects(Page).filter(predicate)
			return pages.first
		} else {
			return nil
		}
	}

	private static func serverStopFetch(page: Page) {
		API.Page.update(page.id, url: page.url, second: page.sec, uuid: User.getUUID(), stopFetch: true)
	}

	static func sync() {
		if let user = User.currentUser() {
			API.Page.all(user.id) { id, url, sec, stopFetch in
				if (id != nil && url != nil && sec != nil && stopFetch != nil) {
					let page = getByURL(url)
					if page == nil {
						addURL(id, url: url, second: sec!, stopFetch: stopFetch!)
					}
				}
			}
		}
	}

	private static func updateID(url: String?, second: Int, stopFetch: Bool) {
		API.Page.create(url, uuid: User.getUUID(), second: second, stopFetch: stopFetch) { id in
			if let id = id {
				if let realm = getDB() {
					realm.write {
						if let page = Page.getByURL(url) {
							page.id = id
						}
					}
				}
			}
		}
	}

	static func deleteByURL(url: String?) -> Bool {
		if let page = getByURL(url) {
			if page.id > 0 {
				serverStopFetch(page)
			}
			if let realm = getDB() {
				realm.write {
					realm.delete(page)
				}
				return true
			} else {
				return false
			}
		}
		return false
	}

	private static func addURL(id: Int?, url: String?, second: Int, stopFetch: Bool) -> Bool {
		if let url = url {
			let page = Page()
			if let id = id {
				page.id = id
			}
			page.url = url
			page.sec = second
			page.stopFetch = stopFetch
			let res = parse(url)
			if let title = res.title {
				page.title = title
			}
			if let content = res.content {
				page.content = content
			}
			if let channel = User.getUUID() {
				page.pushChannel = channel
			}
			if let realm = getDB() {
				realm.write {
					realm.add(page, update: true)
				}
				return true
			} else {
				return false
			}
		} else {
			return false
		}
	}

	static func add(url: String?, second: Int, stopFetch: Bool, closure: (Bool) -> Void) {
		let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
		let queue = dispatch_get_global_queue(qos, 0)
		dispatch_async(queue) {
			if addURL(nil, url: url, second: second, stopFetch: stopFetch) {
				updateID(url, second: second, stopFetch: stopFetch)
				closure(true)
			} else {
				closure(false)
			}
		}
	}

	static func updateAll(closure: (Dictionary<String, Bool>) -> Void) {
		let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
		let queue = dispatch_get_global_queue(qos, 0)
		dispatch_async(queue) {
			var result = [String: Bool]()
			if let realm = getDB() {
				let pages = realm.objects(Page)
				for	page in pages {
					let res = parse(page.url)
					if let content = res.content {
						if content == page.content {
							continue
						}
					}
					let url = page.url
					realm.write {
						if let _ = Page.getByURL(url) {
							if let title = res.title {
								page.title = title
							}
							if let content = res.content {
								page.content = content
							}
							page.updatedAt = NSDate()
						}
					}
					result[page.url] = true
					if page.id <= 0 {
						updateID(page.url, second: page.sec, stopFetch: page.stopFetch)
					}
				}
			}
			closure(result)
		}
	}
}