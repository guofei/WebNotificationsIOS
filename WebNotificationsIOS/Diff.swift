//
//  Diff.swift
//  WebNotificationsIOS
//
//  Created by kaku on 11/20/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import Dwifft

class Diff {
	static func get(s1: String?, s2: String?) -> String {
		if (s1 == nil || s2 == nil) {
			return ""
		}
		if (s1?.characters.count <= 0 || s2?.characters.count <= 0) {
			return ""
		}

		let a = s1!.characters.split { $0 == "\n" || $0 == "\t" }.map(String.init)
		let b = s2!.characters.split { $0 == "\n" || $0 == "\t" }.map(String.init)
		let diff = a.diff(b)
		let printableDiff = diff.results.map({ $0.debugDescription }).joinWithSeparator("\n")
		return printableDiff
	}
}