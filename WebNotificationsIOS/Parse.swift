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
	let body = jiDoc?.xPath("//body")?.first?.content
	let content = body == nil ? jiDoc?.rootNode?.content : body

	return (title, content)
 }