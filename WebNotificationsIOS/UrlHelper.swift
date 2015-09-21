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
	func replace(string:String, replacement:String) -> String {
		return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
	}

	func removeWhitespace() -> String {
		return self.replace(" ", replacement: "")
	}
}


class UrlHelper {
	static func getURL (url: String?) -> String? {
		if let url = url {
			if url.hasPrefix("http") {
				return url.removeWhitespace()
			} else {
				let s = "http://" + url
				return s.removeWhitespace()
			}
		} else {
			return nil
		}
	}

	static func verifyUrl (urlString: String?) -> Bool {
		//Check for nil
		if let urlString = urlString {
			// create NSURL instance
			if let url = NSURL(string: urlString) {
				// check if your application can open the NSURL instance
				return UIApplication.sharedApplication().canOpenURL(url)
			}
		}
		return false
	}
}