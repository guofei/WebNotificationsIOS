//
//  URLAddTableViewController.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/17/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit
import Parse

class URLAddTableViewController: UITableViewController, UITextFieldDelegate, SKPaymentTransactionObserver {
	var defaultSecond = 3 * 60 * 60
	var stopFetch : Bool {
		get {
			if notification == nil {
				return false
			} else {
				return !notification.on
			}
		}
	}

	var originURL: String?
	@IBOutlet weak var restoreCell: UITableViewCell!
	@IBOutlet weak var urlField: UITextField!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	@IBOutlet weak var buyTable: UITableViewCell!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var notification: UISwitch!

	@IBAction func cancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func save(sender: AnyObject) {
		spinner?.startAnimating()
		let sec = Int(datePicker.countDownDuration)
		if changeURL() {
			Page.deleteByURL(UrlHelper.getURL(originURL))
		}
		Page.addOrUpdate(UrlHelper.getURL(urlField.text), second: sec, stopFetch: stopFetch) { (ok: Bool) -> Void in
			dispatch_sync(dispatch_get_main_queue()) {
				self.spinner?.stopAnimating()
				if ok {
					self.dismissViewControllerAnimated(true, completion: nil)
				} else {
					self.alert("Error", message: "URL error!")
					if let url = UrlHelper.getURL(self.urlField.text) {
						Flurry.logEvent("Error URL", withParameters: ["url": url])
					}
				}
			}
		}
		Flurry.logEvent("Add URL")
	}

	@IBAction func tap(sender: AnyObject) {
		view.endEditing(true)
	}

	@IBAction func restore(sender: AnyObject) {
		PFPurchase.restore()
	}

	@IBAction func buyPro(sender: AnyObject) {
		PFPurchase.buyProduct(Product.ID) { (error: NSError?) -> Void in
			if error == nil {
				self.setProUI()
				User.setProUser()
				self.alert("Success", message: "Thank you for buying pro version")
				Flurry.logEvent("Buy Pro Successed")
			} else {
				self.alert("Error", message: error?.description)
				let errorParams = ["message": error!.description];
				Flurry.logEvent("Buy Pro Error", withParameters: errorParams)
			}
		}
	}

	func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		print("paymentQueue")
	}

	func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
		for transaction:SKPaymentTransaction in queue.transactions {
			if transaction.payment.productIdentifier == Product.ID {
				alert("Success", message: "Restore successed")
				setProUI()
				// User.setProUser()
			}
		}
	}

	func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
		alert("Error", message: error.description)
	}

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
		buyTable?.hidden = true
		restoreCell?.hidden = true
		datePicker?.userInteractionEnabled = true
	}

	private func updateUI() {
		if let url = UrlHelper.getURL(originURL) {
			if let page = Page.getByURL(url) {
				urlField?.text = page.url
				notification?.setOn(!page.stopFetch, animated: false)
				datePicker?.countDownDuration = Double(page.sec)
			}
		} else {
			datePicker?.countDownDuration = Double(defaultSecond)
		}
		if (User.isProUser()) {
			setProUI()
		}
		if !User.isOpenNotifaction() {
			notification?.setOn(false, animated: false)
			notification?.enabled = false
		} else {
			notification?.enabled = true
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()

		urlField?.delegate = self
		updateUI()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
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
