//
//  Url.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/20/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import RealmSwift


class Url: Object {
    dynamic var url = ""
	dynamic var sec = 3 * 60 * 60
	dynamic var pushChannel = ""
	dynamic var stop_fetch = false

	override static func primaryKey() -> String? {
		return "url"
	}
}