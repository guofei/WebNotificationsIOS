//
//  Notifaction.swift
//  WebNotificationsIOS
//
//  Created by kaku on 10/28/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
import UIKit

enum Notifaction: String {
	case UNKNOWN = "notifactionUnknown"
	case ON = "notifactionOn"
	case OFF = "notifactionOff"

	static func type() -> Notifaction {
		let ud = NSUserDefaults.standardUserDefaults()
		if let _ = ud.objectForKey(Notifaction.toString()) as? String {
			if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
				return ON
			} else {
				return OFF
			}
		} else {
			return UNKNOWN
		}
	}

	static func setFirstTime() {
		if type() == Notifaction.UNKNOWN {
			let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
			UIApplication.sharedApplication().registerUserNotificationSettings(settings)
			UIApplication.sharedApplication().registerForRemoteNotifications()
			setOpen(true)
			print("first")
		}
	}

	static func setAfterFirstTime() {
		if type() != Notifaction.UNKNOWN {
			let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
			UIApplication.sharedApplication().registerUserNotificationSettings(settings)
			UIApplication.sharedApplication().registerForRemoteNotifications()
			setOpen(true)
			print("second")
		}
	}

	private static func setOpen(isOpen: Bool) {
		let ud = NSUserDefaults.standardUserDefaults()
		if isOpen {
			ud.setObject(ON.rawValue, forKey: toString())
		} else {
			ud.setObject(OFF.rawValue, forKey: toString())
		}
		ud.synchronize()
	}


	private static func toString() -> String {
		return "NotificationType"
	}
}

