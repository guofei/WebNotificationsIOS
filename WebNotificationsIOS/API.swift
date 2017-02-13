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
    fileprivate struct URL
    {
      static let USERGET = "http://webupdatenotification.com/users/"
      static let PAGEGET = "http://webupdatenotification.com/pages/"
      static let PAGEADD = "http://webupdatenotification.com/pages"
      static let PAGEUPDATE = "http://webupdatenotification.com/pages/"
    }

    static func create(_ url: String?, uuid: String?, second: Int?, stopFetch: Bool?, clourse: @escaping (_ id: Int?) -> Void)
    {
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
      Alamofire.request(URL.PAGEADD, method: .post, parameters: parameters).responseJSON { response in
        switch response.result {
        case .success:
          if let dic = response.result.value as? Dictionary<String, AnyObject> {
            if let id = dic["id"] as? Int {
              clourse(id)
            }
          }
        case .failure(let error):
          print(error)
        }
      }
    }

    static func update(_ id: Int?, url: String?, second: Int?, uuid: String?, stopFetch: Bool?) {
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
      _ = Alamofire.request(updateURL, method: .put, parameters: parameters)
    }

    static func get(_ pageID: Int?, fun: @escaping (_ id: Int?, _ url: String?, _ second: Int?, _ stopFetch: Bool?, _ diff: String?) -> Void)
    {
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
          if let item = response.result.value as? Dictionary<String, AnyObject> {
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

    static func all(_ userID: Int?, each: @escaping (_ id: Int?, _ url: String?, _ second: Int?, _ stopFetch: Bool?) -> Void)
    {
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
          if let arr = response.result.value as? Array<Dictionary<String, AnyObject>> {
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

  class User {
    fileprivate struct URL
    {
      static let ADD = "http://webupdatenotification.com/users"
      static let TOUCH = "http://webupdatenotification.com/users/touch"
    }

    static func create(_ uuid: String?, token: String?, type: String?, locale: String?, zone: String?, result: @escaping (_ userID: Int?, _ deviceToken: String) -> Void)
    {
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
      Alamofire.request(URL.ADD, method: .post, parameters: parameters).responseJSON { response in
        switch response.result {
        case .success:
          if let dic = response.result.value as? Dictionary<String, AnyObject> {
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
