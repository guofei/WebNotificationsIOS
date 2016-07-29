//
//  SKProductExtension.swift
//  WebNotificationsIOS
//
//  Created by kaku on 7/29/16.
//  Copyright © 2016 kaku. All rights reserved.
//

import Foundation
import StoreKit

extension SKProduct {
  func localizedPrice() -> String {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.formatterBehavior = .Behavior10_4
    numberFormatter.numberStyle = .CurrencyStyle
    numberFormatter.locale = priceLocale
    return numberFormatter.stringFromNumber(price)!
  }
}