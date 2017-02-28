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
  fileprivate struct URL {
    static let USERGET = "http://webupdatenotification.com/users/"
    static let PAGEGET = "http://webupdatenotification.com/pages/"
    static let PAGEADD = "http://webupdatenotification.com/pages"
    static let PAGEUPDATE = "http://webupdatenotification.com/pages/"
    static let ADD = "http://webupdatenotification.com/users"
    static let TOUCH = "http://webupdatenotification.com/users/touch"
  }

  struct PageParam {
    var uuid: String?
    var url: String?
    var second: Int?
    var stopFetch: Bool?

    func invalid() -> Bool {
      if url == nil || uuid == nil || second == nil || stopFetch == nil {
        return true
      } else {
        return false
      }
    }
  }

  class Page {
    static func create(param: PageParam, clourse: @escaping (_ id: Int?) -> Void) {
      if param.invalid() {
        return
      }

      let parameters = [
        "page": [
          "url": param.url!,
          "sec": param.second!,
          "push_channel": param.uuid!,
          "stop_fetch": param.stopFetch!
        ]
      ]
      Alamofire.request(URL.PAGEADD, method: .post, parameters: parameters).responseJSON { response in
        switch response.result {
        case .success:
          if let dic = response.result.value as? [String: AnyObject] {
            if let id = dic["id"] as? Int {
              clourse(id)
            }
          }
        case .failure(let error):
          print(error)
        }
      }
    }

    static func update(id: Int?, param: PageParam) {
      if param.invalid() {
        return
      }
      if id == nil {
        return
      }
      if id! <= 0 {
        return
      }

      let updateURL = URL.PAGEUPDATE + "\(id!)"
      let parameters = [
        "page": [
          "url": param.url!,
          "sec": param.second!,
          "push_channel": param.uuid!,
          "stop_fetch": param.stopFetch!
        ]
      ]
      _ = Alamofire.request(updateURL, method: .put, parameters: parameters)
    }

    static func get(_ pageID: Int?, fun: @escaping (_ id: Int?, _ url: String?, _ second: Int?, _ stopFetch: Bool?, _ diff: String?) -> Void) {
      if pageID == nil {
        return
      }
      if pageID! <= 0 {
        return
      }

      let getURL = URL.PAGEGET + "\(pageID!)"
      Alamofire.request(getURL, method: .get).responseJSON { response in
        switch response.result {
        case .success:
          if let item = response.result.value as? [String: AnyObject] {
            let id = item["id"] as? Int
            let url = item["url"] as? String
            let stopFetch = item["stop_fetch"] as? Bool
            let sec = item["sec"] as? Int
            let diff = item["content_diff"] as? String
            fun(id, url, sec, stopFetch, diff)
          }
        case .failure(let error):
          print(error)
        }
      }
    }

    static func all(_ userID: Int?, each: @escaping (_ id: Int?, _ url: String?, _ second: Int?, _ stopFetch: Bool?) -> Void) {
      if userID == nil {
        return
      }
      if userID! <= 0 {
        return
      }

      let getURL = URL.USERGET + "\(userID!)" + "/pages"
      Alamofire.request(getURL, method: .get).responseJSON { response in
        switch response.result {
        case .success:
          if let arr = response.result.value as? [[String: AnyObject]] {
            for item in arr {
              let id = item["id"] as? Int
              let url = item["url"] as? String
              let stopFetch = item["stop_fetch"] as? Bool
              let sec = item["sec"] as? Int
              // let diff = item["content_diff"] as? String
              each(id, url, sec, stopFetch)
            }
          }
        case .failure(let error):
          print(error)
        }
      }
    }
  }

  struct UserParam {
    var uuid: String?
    var token: String?
    var type: String?
    var locale: String?
    var zone: String?

    func invalid() -> Bool {
      if uuid == nil || token == nil || type == nil || locale == nil || zone == nil || (uuid?.isEmpty)! {
        return true
      } else {
        return false
      }
    }
  }
  class User {
    static func create(param: UserParam, result: @escaping (_ userID: Int?, _ deviceToken: String) -> Void) {
      if param.invalid() {
        return
      }

      let parameters = [
        "user": [
          "channel": param.uuid!,
          "device_token": param.token!,
          "device_type": param.type!,
          "locale_identifier": param.locale!,
          "time_zone": param.zone!
        ]
      ]
      Alamofire.request(URL.ADD, method: .post, parameters: parameters).responseJSON { response in
        switch response.result {
        case .success:
          if let dic = response.result.value as? [String: AnyObject] {
            if let id = dic["id"] as? Int {
              if let deviceToken = dic["device_token"] as? String {
                result(id, deviceToken)
              }
            }
          }
        case .failure(let error):
          print(error)
        }
      }
    }

    static func touch(_ uuid: String?) {
      if uuid == nil {
        return
      }

      let parameters = [
        "user": [ "channel": uuid! ]
      ]
      _ = Alamofire.request(URL.TOUCH, method: .post, parameters: parameters)
    }
  }
}
