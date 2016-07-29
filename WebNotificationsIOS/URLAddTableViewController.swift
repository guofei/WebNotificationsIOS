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
  var stopFetch : Bool {
    get {
      if notification == nil {
        return false
      } else {
        return !notification.on
      }
    }
  }

  var proPrice : String? = nil {
    didSet {
      updatePrice()
    }
  }

  var originURL: String?

  @IBOutlet weak var restoreCell: UITableViewCell!
  @IBOutlet weak var urlField: UITextField!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  @IBOutlet weak var buyTable: UITableViewCell!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var notification: UISwitch!
  @IBOutlet weak var buyButton: UIButton!

  @IBAction func cancel(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func notificationChanged(sender: UISwitch) {
    if sender.on {
      Notifaction.setFirstTime()
    }
  }

  @IBAction func save(sender: AnyObject) {
    spinner?.startAnimating()
    if changeURL() {
      Page.deleteByURL(UrlHelper.getURL(originURL))
    }
    let sec = Int(datePicker.countDownDuration)
    Page.addOrUpdate(UrlHelper.getURL(urlField.text), second: sec, stopFetch: stopFetch) { (ok: Bool) -> Void in
      dispatch_sync(dispatch_get_main_queue()) {
        self.spinner?.stopAnimating()
        if ok {
          self.dismissViewControllerAnimated(true, completion: nil)
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

  @IBAction func tap(sender: AnyObject) {
    view.endEditing(true)
  }

  @IBAction func restore(sender: AnyObject) {
    Flurry.logEvent("Restore Pro Clicked", withParameters: ["view": "diff"])
    spinner?.startAnimating()
    SwiftyStoreKit.restorePurchases() { results in
      self.spinner?.stopAnimating()
    }
  }

  @IBAction func buyPro(sender: AnyObject) {
    Flurry.logEvent("Buy Pro Clicked", withParameters: ["view": "urladd"])
    spinner?.startAnimating()
    SwiftyStoreKit.purchaseProduct(Product.ID) { result in
      switch result {
      case .Success(let productId):
        self.setProUI()
        Flurry.logEvent("Buy Pro OK", withParameters: ["view": "urladd", "product": "\(productId)"])
      case .Error(let error):
        Flurry.logEvent("Buy Pro Error", withParameters: ["view": "urladd", "error": "\(error)"])
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

  private func alert(title: String?, message: String?) {
    if (title != nil && message != nil) {
      let alert = UIAlertController(title: title!, message: message!, preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }

  private func changeURL() -> Bool {
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

  private func setProUI() {
    if (User.isProUser()) {
      buyTable?.hidden = true
      restoreCell?.hidden = true
      datePicker?.userInteractionEnabled = true
      if urlField?.enabled == false {
        urlField?.enabled = true
        urlField?.placeholder = "URL"
      }
    }
  }

  private func initUI() {
    if let price = proPrice {
      let text = NSLocalizedString("BuyProWithoutPrice", comment: "") + " (\(price))"
      buyButton?.setTitle(text, forState: UIControlState.Normal)
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
    if (User.isProUser()) {
      setProUI()
    } else {
      if Page.count() >= Product.userNumUrlLimit {
        urlField?.enabled = false
        urlField?.placeholder = NSLocalizedString("UnlockAddLimit", comment: "")
      }
    }
    switch (Notifaction.type()) {
    case Notifaction.UNKNOWN:
      notification?.enabled = true
      notification?.setOn(false, animated: false)
      break
    case Notifaction.ON:
      notification?.enabled = true
      break
    case Notifaction.OFF:
      notification?.setOn(false, animated: false)
      notification?.enabled = false
      break
    }
  }

  private func updatePrice() {
    if let price = proPrice {
      let text = NSLocalizedString("BuyProWithoutPrice", comment: "") + " (\(price))"
      buyButton?.setTitle(text, forState: UIControlState.Normal)
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

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    SwiftyStoreKit.retrieveProductsInfo([Product.ID]) { result in
      if let product = result.retrievedProducts.first {
        self.proPrice = product.localizedPrice()
      }
    }
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool{
    urlField?.resignFirstResponder()
    return true
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  /*
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
  // #warning Incomplete implementation, return the number of sections
  return 0
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  // #warning Incomplete implementation, return the number of rows
  return 0
  }
  */

  /*
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

  // Configure the cell...

  return cell
  }
  */

  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the specified item to be editable.
  return true
  }
  */

  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */

  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

  }
  */

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the item to be re-orderable.
  return true
  }
  */

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
