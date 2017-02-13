//
//  Parse.swift
//  WebNotificationsIOS
//
//  Created by kaku on 10/3/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import Ji

func parse(_ url: String?) -> (title: String?, content: String?) {
  if url == nil {
    return (nil, nil)
  }

  guard let url = URL(string: url!) else {
    return (nil, nil)
  }

  guard let jiDoc = Ji(htmlURL: url) else {
    return (nil, nil)
  }

  let title = jiDoc.xPath("//title")?.first?.content
  var content = jiDoc.rootNode?.content

  if content != nil {
    if let scripts = jiDoc.xPath("//script") {
      for item in scripts {
        if let replace = item.content {
          content = content?.replacingOccurrences(of: replace, with: "")
        }
      }
    }
    if let style = jiDoc.xPath("//style") {
      for item in style {
        if let replace = item.content {
          content = content?.replacingOccurrences(of: replace, with: "")
        }
      }
    }
  }

  return (title, content)
}
