//
//  Parse.swift
//  WebNotificationsIOS
//
//  Created by kaku on 10/3/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import Ji

func parse(url: String?) -> (title: String?, content: String?) {
	if url == nil {
		return (nil, nil)
	}

	let jiDoc = Ji(htmlURL: NSURL(string: url!)!)
	if jiDoc == nil {
		return (nil, nil)
	}

	let title = jiDoc?.xPath("//title")?.first?.content
	var content = jiDoc?.rootNode?.content

	if content != nil {
		if let scripts = jiDoc?.xPath("//script") {
			for item in scripts {
				if let replace = item.content {
					content = content?.stringByReplacingOccurrencesOfString(replace, withString: "")
				}
			}
		}
		if let style = jiDoc?.xPath("//style") {
			for item in style {
				if let replace = item.content {
					content = content?.stringByReplacingOccurrencesOfString(replace, withString: "")
				}
			}
		}
	}

	return (title, content)
 }