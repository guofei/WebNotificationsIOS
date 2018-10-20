//
//  URLAddTableViewController.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/17/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import Flurry_iOS_SDK

class URLAddTableViewController: UITableViewController, UITextFieldDelegate {
  var stopFetch: Bool {
    if notification == nil {
      return false
    } else {
      return !notification.isOn
    }
  }

  var proPrice: String? = nil {
    didSet {
      updatePrice()
    }
  }

  var originURL: String?

  @IBOutlet weak var urlField: UITextField!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var notification: UISwitch!
  @IBOutlet weak var buyButton: UIButton!
  @IBOutlet weak var navi: UINavigationItem!

  @IBAction func cancel(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func notificationChanged(_ sender: UISwitch) {
    if sender.isOn {
      Notifaction.setFirstTime()
    }
  }

  @IBAction func save(_ sender: AnyObject) {
    spinner?.startAnimating()
    navi?.leftBarButtonItem?.isEnabled = false
    navi?.rightBarButtonItem?.isEnabled = false
    if changeURL() {
      _ = Page.deleteByURL(UrlHelper.getURL(originURL))
    }
    let sec = Int(datePicker.countDownDuration)
    Page.createOrUpdate(UrlHelper.getURL(urlField.text), second: sec, stopFetch: stopFetch) { (ok: Bool) -> Void in
      DispatchQueue.main.sync {
        self.spinner?.stopAnimating()
        self.navi?.leftBarButtonItem?.isEnabled = true
        self.navi?.rightBarButtonItem?.isEnabled = true
        if ok {
          self.dismiss(animated: true, completion: nil)
          Flurry.logEvent("Add URL")
        } else {
          self.alert("Error", message: NSLocalizedString("AccessError", comment: ""))
          if let url = UrlHelper.getURL(self.urlField.text) {
            Flurry.logEvent("Error URL", withParameters: ["url": url])
          }
        }
      }
    }
  }

  @IBAction func tap(_ sender: AnyObject) {
    view.endEditing(true)
  }

  @IBAction func restore(_ sender: AnyObject) {
    Flurry.logEvent("Restore Pro Clicked", withParameters: ["view": "diff"])
    spinner?.startAnimating()
    SwiftyStoreKit.restorePurchases(atomically: true) { results in
      if results.restoreFailedPurchases.count > 0 {
        print("Restore Failed: \(results.restoredPurchases)")
      } else if results.restoredPurchases.count > 0 {
        User.setProUser()
        self.setProUI()
        print("Restore Success: \(results.restoredPurchases)")
      } else {
        print("Nothing to Restore")
      }
      self.spinner?.stopAnimating()
    }
  }

  @IBAction func buyPro(_ sender: AnyObject) {
    Flurry.logEvent("Buy Pro Clicked", withParameters: ["view": "urladd"])
    spinner?.startAnimating()
    SwiftyStoreKit.purchaseProduct(Product.ID, atomically: true) { result in
      switch result {
      case .success(let purchase):
        User.setProUser()
        self.setProUI()
        Flurry.logEvent("Buy Pro OK", withParameters: ["view": "diff", "product": "\(purchase.productId)"])
      case .error(let error):
        Flurry.logEvent("Buy Pro Error", withParameters: ["view": "diff", "error": "\(error)"])
      }
      self.spinner?.stopAnimating()
    }
  }

  /*
  func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
  }

  func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
		for transaction:SKPaymentTransaction in queue.transactions {
  if transaction.payment.productIdentifier == Product.ID {
  alert("Success", message: "Restore successed")
  }
		}
  }

  func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
  }
  */

  fileprivate func alert(_ title: String?, message: String?) {
    if title != nil && message != nil {
      let alert = UIAlertController(title: title!, message: message!, preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }

  fileprivate func changeURL() -> Bool {
    if originURL == nil {
      return false
    }

    if let newURL = UrlHelper.getURL(urlField.text) {
      if newURL != originURL! {
        return true
      }
    }

    return false
  }

  fileprivate func setProUI() {
    if User.isProUser() {
      datePicker?.isUserInteractionEnabled = true
      if urlField?.isEnabled == false {
        urlField?.isEnabled = true
        urlField?.placeholder = "URL"
      }
    }
  }

  fileprivate func initUI() {
    if let price = proPrice {
      let text = NSLocalizedString("BuyProWithoutPrice", comment: "") + " (\(price))"
      buyButton?.setTitle(text, for: UIControlState())
    }
    if let url = UrlHelper.getURL(originURL) {
      if let page = Page.getByURL(url) {
        urlField?.text = page.url
        notification?.setOn(!page.stopFetch, animated: false)
        datePicker?.countDownDuration = Double(page.sec)
      }
    } else {
      datePicker?.countDownDuration = Double(PageConst.defaultSecond)
    }
    if User.isProUser() {
      setProUI()
    } else {
      if Page.count() >= Product.userNumUrlLimit {
        urlField?.isEnabled = false
        urlField?.placeholder = NSLocalizedString("UnlockAddLimit", comment: "")
      }
    }
    switch Notifaction.type() {
    case Notifaction.UNKNOWN:
      notification?.isEnabled = true
      notification?.setOn(false, animated: false)
    case Notifaction.ON:
      notification?.isEnabled = true
    case Notifaction.OFF:
      notification?.setOn(false, animated: false)
      notification?.isEnabled = false
    }
  }

  fileprivate func updatePrice() {
    if let price = proPrice {
      let text = NSLocalizedString("BuyProWithoutPrice", comment: "") + " (\(price))"
      buyButton?.setTitle(text, for: UIControlState())
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    urlField?.delegate = self
    initUI()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    SwiftyStoreKit.retrieveProductsInfo([Product.ID]) { result in
      if let product = result.retrievedProducts.first {
        self.proPrice = product.localizedPrice()
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    urlField?.resignFirstResponder()
    return true
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    if User.isProUser() {
      return 3
    } else {
      return 4
    }
  }
}
