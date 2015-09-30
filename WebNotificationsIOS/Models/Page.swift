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

	private struct API {
		static let GET = "http://webupdatenotification.com/users/"
		static let ADD = "http://webupdatenotification.com/pages"
		static let UPDATE = "http://webupdatenotification.com/pages/"
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
		do {
			let realm = try Realm()
			let predicate = NSPredicate(format: "url = %@", url!)
			let pages = realm.objects(Page).filter(predicate)
			return pages.first
		} catch {
			return nil
		}
	}

	static func serverStopFetch(id: Int, url: String?, channel: String?) {
		if url == nil || channel == nil || id <= 0 {
			return
		}
		let updateURL = API.UPDATE + "\(id)"
		if let page = getByURL(url) {
			let parameters = [
				"page": [
					"url": url!,
					"sec": page.sec,
					"push_channel": channel!,
					"stop_fetch": true
				]
			]
			Alamofire.request(.PUT, updateURL, parameters: parameters)
		}
	}

	static func serverUpdate() {
		let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
		let queue = dispatch_get_global_queue(qos, 0)
		dispatch_async(queue) {
			if let user = User.currentUser() {
				if user.id > 0 {
					let getURL = API.GET + "\(user.id)" + "/pages"
					Alamofire.request(.GET, getURL).responseJSON { response in
						switch response.2 {
						case .Success:
							if let arr = response.2.value as? Array<Dictionary<String, AnyObject>> {
								for item in arr {
									let url = item["url"] as? String
									let page = getByURL(url)
									if page != nil {
										continue
									}
									if let stopFetch = item["stop_fetch"] as? Bool {
										if stopFetch {
											continue
										}
										if let sec = item["sec"] as? Int {
											addURL(url, second: sec, stopFetch: false)
										}
									}
								}
							}
						case .Failure(let error):
							print(error)
						}
					}
				}
			}
		}
	}

	static func serverCreate(url: String?, second: Int, stopFetch: Bool) {
		if url == nil || !User.isOpenNotification() {
			return
		}

		let uuid = User.getUUID()
		if uuid == nil {
			return
		}
		let parameters = [
			"page": [
				"url": url!,
				"sec": second,
				"push_channel": uuid!,
				"stop_fetch": stopFetch
			]
		]
		Alamofire.request(.POST, API.ADD, parameters: parameters).responseJSON { response in
			switch response.2 {
			case .Success:
				if let dic = response.2.value as? Dictionary<String, AnyObject> {
					if let id = dic["id"] as? Int {
						do {
							let realm = try Realm()
							realm.write {
								if let page = Page.getByURL(url) {
									page.id = id
								}
							}
						} catch {
							print("database error")
						}
					}
				}
			case .Failure(let error):
				print(error)
			}
		}
	}

	static func deleteByURL(url: String?) -> Bool {
		if let page = getByURL(url) {
			if page.id > 0 {
				serverStopFetch(page.id, url: page.url, channel: page.pushChannel)
			}
			do {
				let realm = try Realm()
				realm.write {
					realm.delete(page)
				}
				return true
			} catch {
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
			do {
				let realm = try Realm()
				realm.write {
					realm.add(page, update: true)
				}
			} catch {
				return false
			}
			return true
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
			} catch {
				print("database error")
			}
			closure(result)
		}
	}
}