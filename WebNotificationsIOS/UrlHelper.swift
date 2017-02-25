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
  func replace(_ string: String, replacement: String) -> String {
    return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
  }

  func removeWhitespace() -> String {
    return self.replace(" ", replacement: "")
  }
}

class UrlHelper {
  static func getURL(_ url: String?) -> String? {
    if let newURL = encode(targetURL: addScheme(targetURL: url)) {
      if valid(targetURL: newURL) {
        return newURL
      }
    }
    return nil
  }

  static func verifyUrl(targetURL: String?) -> Bool {
    if let urlString = targetURL {
      if let url = URL(string: urlString) {
        return UIApplication.shared.canOpenURL(url)
      }
    }
    return false
  }

  private static func valid(targetURL: String) -> Bool {
    if URL(string: targetURL) != nil {
      return true
    } else {
      return false
    }
  }

  private static func encode(targetURL: String?) -> String? {
    return targetURL.flatMap { $0.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) }
  }

  private static func addScheme(targetURL: String?) -> String? {
    return targetURL.flatMap {
      if $0.characters.count <= 0 {
        return $0
      }
      if $0.hasPrefix("http") {
        return $0
      }
      return "http://" + $0
    }
  }
}
