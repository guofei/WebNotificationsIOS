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
      static let PAGEGET = "http://webupdatenotification.com/pages/"
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

    static func get(pageID: Int?, fun: (id: Int?, url: String?, second: Int?, stopFetch: Bool?, diff: String?) -> Void) {
      if pageID == nil {
        return
      }
      if pageID! <= 0 {
        return
      }

      let getURL = URL.PAGEGET + "\(pageID!)"
      Alamofire.request(.GET, getURL).responseJSON { response in
        switch response.result {
        case .Success:
          if let item = response.result.value as? Dictionary<String, AnyObject> {
            let id = item["id"] as? Int
            let url = item["url"] as? String
            let stopFetch = item["stop_fetch"] as? Bool
            let sec = item["sec"] as? Int
            let diff = item["content_diff"] as? String
            fun(id: id, url: url, second: sec, stopFetch: stopFetch, diff: diff)
          }
        case .Failure(let error):
          print(error)
        }
      }
    }

    static func all(userID: Int?, each: (id: Int?, url: String?, second: Int?, stopFetch: Bool?) -> Void) {
      if userID == nil {
        return
      }
      if userID! <= 0 {
        return
      }

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
              // let diff = item["content_diff"] as? String
              each(id: id, url: url, second: sec, stopFetch: stopFetch)
            }
          }
        case .Failure(let error):
          print(error)
        }
      }
    }
  }

  class User {
    private struct URL {
      static let ADD = "http://webupdatenotification.com/users"
      static let TOUCH = "http://webupdatenotification.com/users/touch"
    }

    static func create(uuid: String?, token: String?, type: String?, locale: String?, zone: String?, result: (userID: Int?, deviceToken: String) -> Void) {
      if uuid == nil || token == nil || type == nil || locale == nil || zone == nil || (uuid?.isEmpty)! {
        return
      }

      let parameters = [
        "user": [
          "channel": uuid!,
          "device_token": token!,
          "device_type": type!,
          "locale_identifier": locale!,
          "time_zone": zone!
        ]
      ]
      Alamofire.request(.POST, URL.ADD, parameters: parameters).responseJSON { response in
        switch response.result {
        case .Success:
          if let dic = response.result.value as? Dictionary<String, AnyObject> {
            if let id = dic["id"] as? Int {
              if let deviceToken = dic["device_token"] as? String {
                result(userID: id, deviceToken: deviceToken)
              }
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