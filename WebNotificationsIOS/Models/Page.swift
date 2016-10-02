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
  static let defaultSecond = 4 * 60 * 60
}

// pushChannel is equal User::uuid
class Page: Object {
  dynamic var id = 0
  dynamic var cellIndex = 0
  dynamic var url = ""
  dynamic var sec = 0
  dynamic var pushChannel = ""
  dynamic var stopFetch = true
  dynamic var title = "unknown"
  dynamic var content = ""
  dynamic var contentDiff = ""
  dynamic var digest = ""
  dynamic var changed = false
  dynamic var createdAt = Date()
  dynamic var updatedAt = Date()

  override static func primaryKey() -> String? {
    return "url"
  }

  func formatedUpdateTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    dateFormatter.dateStyle = .short
    return dateFormatter.string(from: updatedAt)
  }

  static func count() -> Int {
    if let realm = getDB() {
      let pages = realm.objects(Page.self)
      return pages.count
    } else {
      return 0
    }
  }

  static func getByURL(_ url: String?) -> Page? {
    if url == nil {
      return nil
    }
    if let realm = getDB() {
      let predicate = NSPredicate(format: "url = %@", url!)
      let pages = realm.objects(Page.self).filter(predicate)
      return pages.first
    } else {
      return nil
    }
  }

  static func setChanged(_ url: String?, changed: Bool) {
    if let page = Page.getByURL(url) {
      if let realm = getDB() {
        try! realm.write {
          page.changed = changed
        }
      }
    }
  }

  static func getByCellIndex(_ index: Int) -> Page? {
    if let realm = getDB() {
      let predicate = NSPredicate(format: "cellIndex = %@", index)
      let pages = realm.objects(Page.self).filter(predicate)
      if pages.count == 1 {
        return pages.first
      } else {
        return nil
      }
    } else {
      return nil
    }
  }

  fileprivate static func resetCellIndex() {
    if let realm = getDB() {
      let pages = realm.objects(Page.self)
      for (index, page) in pages.enumerated() {
        try! realm.write {
          page.cellIndex = index
        }
      }
    }
  }

  fileprivate static func serverStopFetch(_ page: Page) {
    API.Page.update(page.id, url: page.url, second: page.sec, uuid: User.getUUID(), stopFetch: true)
  }

  static func sync() {
    if let user = User.currentUser() {
      API.Page.all(user.id) { id, url, sec, stopFetch in
        if (id != nil && url != nil && sec != nil && stopFetch != nil) {
          let page = getByURL(url)
          if page == nil {
            _ = addOrUpdateURLToLocal(id, url: url, second: sec!, stopFetch: stopFetch!)
          }
        }
      }
    }
  }

  fileprivate static func syncURL(_ url: String?, second: Int, stopFetch: Bool) {
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

  static func deleteByURL(_ url: String?) -> Bool {
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

  fileprivate static func addOrUpdateURLToLocal(_ id: Int?, url: String?, second: Int, stopFetch: Bool) -> Bool {
    if url == nil {
      return false
    }
    let res = parse(url!)
    /*
    if res.title == nil && res.content == nil {
    return false
    }*/
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

  static func addOrUpdate(_ url: String?, second: Int, stopFetch: Bool, closure: @escaping (Bool) -> Void) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
      if addOrUpdateURLToLocal(nil, url: url, second: second, stopFetch: stopFetch) {
        syncURL(url, second: second, stopFetch: stopFetch)
        closure(true)
      } else {
        closure(false)
      }
    }
  }

  fileprivate static func checkIsUpdate(_ page :Page?) -> Bool {
    if page == nil {
      return false
    }

    if let page = page {
      let res = parse(page.url)
      if let content = res.content , content != page.content {
        let contentDiff = User.isProUser() ? DiffHelper.get(page.content, newData: res.content) : ""
        let url = page.url
        try! getDB()?.write {
          if let _ = Page.getByURL(url) {
            if let title = res.title {
              page.title = title
            }
            if let content = res.content {
              page.contentDiff = contentDiff
              page.content = content
              page.changed = true
            }
            page.updatedAt = NSDate() as Date
          }
        }
        return true
      }
      if page.id <= 0 {
        syncURL(page.url, second: page.sec, stopFetch: page.stopFetch)
      }
    }
    return false
  }

  static func update(_ url :String?, done: @escaping (Bool) -> Void) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
      let page = Page.getByURL(url)
      let res = checkIsUpdate(page)
      done(res)
    }
  }
  
  static func updateAll(_ done: @escaping (Bool) -> Void) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
      if let realm = getDB() {
        let pages = realm.objects(Page.self)
        for	page in pages {
          _ = checkIsUpdate(page)
        }
      }
      done(true)
    }
  }
}
