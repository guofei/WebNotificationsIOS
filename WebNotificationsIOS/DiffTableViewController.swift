//
//  DiffTableViewController.swift
//  WebNotificationsIOS
//
//  Created by kaku on 11/22/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import Flurry_iOS_SDK

// http://stackoverflow.com/questions/18696706/large-text-being-cut-off-in-uitextview-that-is-inside-uiscrollview
func fixViewScroll(_ textView: UITextView?) {
  // textView?.layoutManager.allowsNonContiguousLayout = false
  textView?.isScrollEnabled = false
  textView?.isScrollEnabled = true
}

class DiffTableViewController: UITableViewController {
  var targetURL: String? {
    didSet {
      showDiff()
    }
  }
  var diffText: String? = NSLocalizedString("BuyToUseDiff", comment: "")

  var proPrice: String? = nil {
    didSet {
      updatePrice()
    }
  }

  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  @IBOutlet weak var buyButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    if let text = diffText {
      textView?.text = text
    }

    fixViewScroll(textView)

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }

  @IBAction func buy(_ sender: AnyObject) {
    spinner?.startAnimating()
    Flurry.logEvent("Buy Pro Clicked", withParameters: ["view": "diff"])
    SwiftyStoreKit.purchaseProduct(Product.ID, atomically: true) { result in
      switch result {
      case .success(let productId):
        User.setProUser()
        Flurry.logEvent("Buy Pro OK", withParameters: ["view": "diff", "product": "\(productId)"])
      case .error(let error):
        Flurry.logEvent("Buy Pro Error", withParameters: ["view": "diff", "error": "\(error)"])
      }
      self.spinner?.stopAnimating()
    }
  }

  @IBAction func restore(_ sender: AnyObject) {
    spinner?.startAnimating()
    Flurry.logEvent("Restore Pro Clicked", withParameters: ["view": "diff"])
    SwiftyStoreKit.restorePurchases(atomically: true) { results in
      if results.restoreFailedProducts.count > 0 {
        print("Restore Failed: \(results.restoreFailedProducts)")
      } else if results.restoredProducts.count > 0 {
        User.setProUser()
        print("Restore Success: \(results.restoredProducts)")
      } else {
        print("Nothing to Restore")
      }
      self.spinner?.stopAnimating()
    }
  }

  fileprivate func showDiff() {
    if User.isProUser() {
      if let url = targetURL {
        if let page = Page.getByURL(url) {
          diffText = page.contentDiff
          textView?.text = diffText
          fixViewScroll(textView)
        }
      }
    }
  }

  fileprivate func updatePrice() {
    if let price = proPrice {
      let text = NSLocalizedString("BuyProWithoutPrice", comment: "") + " (\(price))"
      buyButton?.setTitle(text, for: UIControlState())
    }
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

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    if User.isProUser() {
      return 1
    } else {
      return 2
    }
  }

  /*
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
