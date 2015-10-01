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

	func formatedUpdate() -> String {
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
		API.PageAPI.update(page.id, url: page.url, second: page.sec, uuid: User.getUUID(), stopFetch: true)
	}

	static func sync() {
		if let user = User.currentUser() {
			API.PageAPI.all(user.id) { id, url, sec, stopFetch in
				if (id != nil && url != nil && sec != nil && stopFetch != nil) {
					let page = getByURL(url)
					if page == nil {
						addURL(url, second: sec!, stopFetch: stopFetch!)
					}
				}
			}
		}
	}

	private static func serverCreate(url: String?, second: Int, stopFetch: Bool) {
		API.PageAPI.create(url, uuid: User.getUUID(), second: second, stopFetch: stopFetch) { id in
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

	static func addURL(url: String?, second: Int, stopFetch: Bool) -> Bool {
		if let url = url {
			let page = Page()
			page.url = url
			page.sec = second
			page.stopFetch = stopFetch
			let jiDoc = Ji(htmlURL: NSURL(string: url)!)
			if let title = jiDoc?.xPath("//title")?.first?.content {
				page.title = title
			}
			let body = jiDoc?.xPath("//body")?.first?.content
			if let content = body == nil ? jiDoc?.rootNode?.content : body {
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
			if addURL(url, second: second, stopFetch: stopFetch) {
				serverCreate(url, second: second, stopFetch: stopFetch)
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
					let jiDoc = Ji(htmlURL: NSURL(string: page.url)!)
					if jiDoc == nil {
						continue
					}
					let title = jiDoc?.xPath("//title")?.first?.content
					let body = jiDoc?.xPath("//body")?.first?.content
					let content = body == nil ? jiDoc?.rootNode?.content : body
					if let checkContent = content {
						if checkContent == page.content {
							continue
						}
					}
					let url = page.url
					realm.write {
						if let _ = Page.getByURL(url) {
							if let tt = title {
								page.title = tt
							}
							if let ct = content {
								page.content = ct
							}
							page.updatedAt = NSDate()
						}
					}
					result[page.url] = true
					if page.id <= 0 {
						serverCreate(page.url, second: page.sec, stopFetch: page.stopFetch)
					}
				}
			}
			closure(result)
		}
	}
}