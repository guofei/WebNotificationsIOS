//
//  DiffTableViewController.swift
//  WebNotificationsIOS
//
//  Created by kaku on 11/22/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit
import Parse
import Flurry_iOS_SDK

class DiffTableViewController: UITableViewController, SKProductsRequestDelegate {
  var targetURL : String? {
    didSet {
      showDiff()
    }
  }
  var diffText : String? = NSLocalizedString("BuyToUseDiff", comment: "")

  var proPrice : String? = nil {
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

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }

  @IBAction func buy(sender: AnyObject) {
    spinner?.startAnimating()
    Flurry.logEvent("Buy Pro Clicked", withParameters: ["view": "diff"])
    PFPurchase.buyProduct(Product.ID) { (error: NSError?) -> Void in
      if error == nil {
        Flurry.logEvent("Buy Pro OK", withParameters: ["view": "diff"])
      } else {
        Flurry.logEvent("Buy Pro Error", withParameters: ["view": "diff"])
      }
      self.spinner?.stopAnimating()
    }
  }

  @IBAction func restore(sender: AnyObject) {
    spinner?.startAnimating()
    Flurry.logEvent("Restore Pro Clicked", withParameters: ["view": "diff"])
    PFPurchase.restore()
  }

  private func showDiff() {
    if User.isProUser() {
      if let url = targetURL {
        if let page = Page.getByURL(url) {
          diffText = page.contentDiff
          textView?.text = diffText
        }
      }
    }
  }

  private func updatePrice() {
    if let price = proPrice {
      let text = NSLocalizedString("BuyProWithoutPrice", comment: "") + " (\(price))"
      buyButton?.setTitle(text, forState: UIControlState.Normal)
    }
  }

  var productsRequest: SKProductsRequest?

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let productID: Set<String> = [Product.ID]
    productsRequest = SKProductsRequest(productIdentifiers: productID)
    productsRequest?.delegate = self;
    productsRequest?.start();
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    productsRequest?.cancel()
    productsRequest?.delegate = nil
  }

  func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
    for	product in response.products {
      if product.productIdentifier == Product.ID {
        proPrice = product.localizedPrice()
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
