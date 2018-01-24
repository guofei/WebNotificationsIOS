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
    if let schemed = addScheme(targetURL: url) {
      if valid(targetURL: schemed) != nil {
        return schemed
      } else {
        return encode(targetURL: addScheme(targetURL: url)).flatMap { valid(targetURL: $0) }
      }
    }
    return nil
  }

  private static func valid(targetURL: String) -> String? {
    if URL(string: targetURL) != nil {
      return targetURL
    } else {
      return nil
    }
  }

  private static func encode(targetURL: String?) -> String? {
    return targetURL.flatMap { $0.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) }
  }

  private static func addScheme(targetURL: String?) -> String? {
    return targetURL.flatMap {
      if $0.count <= 0 {
        return $0
      }
      if $0.hasPrefix("http") {
        return $0
      }
      return "http://" + $0
    }
  }
}
