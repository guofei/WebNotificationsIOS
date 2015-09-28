//
//  URLAddTableViewController.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/17/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit
import Parse


class URLAddTableViewController: UITableViewController, UITextFieldDelegate {
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

	@IBOutlet weak var urlField: UITextField!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	@IBOutlet weak var buyTable: UITableViewCell!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var notification: UISwitch!

	@IBAction func cancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func tap(sender: AnyObject) {
		view.endEditing(true)
	}

	private func setProUI() {
		buyTable?.hidden = true
		datePicker?.userInteractionEnabled = true
	}

	private struct Product {
		static let ID = "proversion"
	}

	@IBAction func buyPro(sender: AnyObject) {
		Flurry.logEvent("Buy Pro")

		PFPurchase.buyProduct(Product.ID) { (error: NSError?) -> Void in
			if error == nil {
				self.setProUI()
				User.setProUser()
				let alert = UIAlertController(title: "Success", message: "Thank you for buying pro", preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
			} else {
				let errorParams = ["message": error!.description];
				Flurry.logEvent("Buy Pro Error", withParameters: errorParams)
				let alert = UIAlertController(title: "Error", message: error?.description, preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
			}
		}
	}

	@IBAction func save(sender: AnyObject) {
		spinner?.startAnimating()
		let sec = Int(datePicker.countDownDuration)
		print(stopFetch)
		Page.add(UrlHelper.getURL(urlField.text), second: sec, stopFetch: stopFetch) { (ok: Bool) -> Void in
			dispatch_sync(dispatch_get_main_queue()) {
				self.spinner?.stopAnimating()
				self.dismissViewControllerAnimated(true, completion: nil)
			}
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		urlField?.delegate = self
		datePicker.countDownDuration = Double(defaultSecond)

		if (User.isProUser()) {
			setProUI()
		}

		Flurry.logEvent("Add URL")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
