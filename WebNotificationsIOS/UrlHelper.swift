//
//  UrlHelper.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/21/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import UIKit


extension String {
  func replace(_ string:String, replacement:String) -> String {
    return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
  }

  func removeWhitespace() -> String {
    return self.replace(" ", replacement: "")
  }
}


class UrlHelper {
  static func getURL (_ url: String?) -> String? {
    if let url = url {
      let str = url.removeWhitespace()
      if (str.characters.count > 0) {
        if url.hasPrefix("http") {
          return str
        } else {
          return "http://" + str
        }
      } else {
        return nil
      }
    } else {
      return nil
    }
  }

  static func verifyUrl (_ urlString: String?) -> Bool {
    //Check for nil
    if let urlString = urlString {
      // create NSURL instance
      if let url = URL(string: urlString) {
        // check if your application can open the NSURL instance
        return UIApplication.shared.canOpenURL(url)
      }
    }
    return false
  }
}
