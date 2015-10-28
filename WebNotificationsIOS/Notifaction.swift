//
//  Notifaction.swift
//  WebNotificationsIOS
//
//  Created by kaku on 10/28/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation

enum Notifaction: String {
	case UNKNOWN = "notifactionUnknown"
	case ON = "notifactionOn"
	case OFF = "notifactionOff"
	static func toString() -> String {
		return "NotificationType"
	}

	static func type() -> Notifaction {
		let ud = NSUserDefaults.standardUserDefaults()
		if let str = ud.objectForKey(Notifaction.toString()) as? String {
			if let type = Notifaction(rawValue: str) {
				return type;
			}
			return UNKNOWN
		} else {
			return UNKNOWN
		}
	}

	static func open(open: Bool) {
		let ud = NSUserDefaults.standardUserDefaults()
		if open {
			ud.setObject(ON.rawValue, forKey: toString())
		} else {
			ud.setObject(OFF.rawValue, forKey: toString())
		}
		ud.synchronize()
	}
}

