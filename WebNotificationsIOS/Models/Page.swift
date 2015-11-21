//
//  Url.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/20/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import RealmSwift

struct PageConst {
	static let defaultSecond = 3 * 60 * 60
}

// pushChannel is equal User::uuid
class Page: Object {
	dynamic var id = 0
    dynamic var url = ""
	dynamic var sec = 0
	dynamic var pushChannel = ""
	dynamic var stopFetch = true
	dynamic var title = "unknown"
	dynamic var content = ""
	dynamic var contentDiff = ""
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

	static func getByURL(url: String?) -> Page? {
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
						addOrUpdateURLToLocal(id, url: url, second: sec!, stopFetch: stopFetch!)
					}
				}
			}
		}
	}

	private static func syncURL(url: String?, second: Int, stopFetch: Bool) {
		let newSecond = User.isProUser() ? second : PageConst.defaultSecond
		let newStop = Notifaction.type() == Notifaction.ON ? stopFetch : true
		API.Page.create(url, uuid: User.getUUID(), second: newSecond, stopFetch: newStop) { id in
			if let id = id {
				if let realm = getDB() {
					try! realm.write {
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
				try!realm.write {
					realm.delete(page)
				}
				return true
			} else {
				return false
			}
		}
		return false
	}

	private static func addOrUpdateURLToLocal(id: Int?, url: String?, second: Int, stopFetch: Bool) -> Bool {
		if url == nil {
			return false
		}
		let res = parse(url!)
		if res.title == nil && res.content == nil {
			return false
		}
		let page = Page()
		if let id = id {
			page.id = id
		} else {
			page.id = 0
		}
		page.url = url!
		page.sec = second
		page.stopFetch = stopFetch
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
			try! realm.write {
				realm.add(page, update: true)
			}
			return true
		} else {
			return false
		}
	}

	static func addOrUpdate(url: String?, second: Int, stopFetch: Bool, closure: (Bool) -> Void) {
		let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
		let queue = dispatch_get_global_queue(qos, 0)
		dispatch_async(queue) {
			if addOrUpdateURLToLocal(nil, url: url, second: second, stopFetch: stopFetch) {
				syncURL(url, second: second, stopFetch: stopFetch)
				closure(true)
			} else {
				closure(false)
			}
		}
	}

	private static func updatePageDiffContent(pageID: Int?) {
		API.Page.get(pageID, fun: { (id, url, second, stopFetch, diff) -> Void in
			if let db = getDB() {
				try! db.write {
					if let pg = Page.getByURL(url) {
						if let contentDiff = diff {
							pg.contentDiff = contentDiff
						}
					}
				}
			}
		})
	}

	static func updateAll(closure: (Dictionary<String, Bool>) -> Void) {
		let qos = Int(QOS_CLASS_UTILITY.rawValue)
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
					// TODO : Bug fix and replace API.Page.get
					// let contentDiff = Diff.get(res.content, s2: page.content)
					if User.isProUser() {
						updatePageDiffContent(page.id)
					}
					let url = page.url
					try! realm.write {
						if let _ = Page.getByURL(url) {
							if let title = res.title {
								page.title = title
							}
							if let content = res.content {
								// page.contentDiff = contentDiff
								page.content = content
							}
							page.updatedAt = NSDate()
						}
					}
					result[page.url] = true
					if page.id <= 0 {
						syncURL(page.url, second: page.sec, stopFetch: page.stopFetch)
					}
				}
			}
			closure(result)
		}
	}
}