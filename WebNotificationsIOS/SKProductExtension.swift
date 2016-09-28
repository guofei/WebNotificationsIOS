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
    let numberFormatter = NumberFormatter()
    numberFormatter.formatterBehavior = .behavior10_4
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = priceLocale
    return numberFormatter.string(from: price)!
  }
}
