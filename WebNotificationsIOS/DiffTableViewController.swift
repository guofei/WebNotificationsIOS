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

class DiffTableViewController: UITableViewController {
	var targetURL : String? {
		didSet {
			showDiff()
		}
	}
	var diffText : String? = NSLocalizedString("BuyToUseDiff", comment: "")

	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var spinner: UIActivityIndicatorView!

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
		Flurry.logEvent("Buy Pro Clicked")
		PFPurchase.buyProduct(Product.ID) { (error: NSError?) -> Void in
			if error == nil {
				Flurry.logEvent("Buy Pro OK")
			} else {
				Flurry.logEvent("Buy Pro Error")
			}
			self.spinner?.stopAnimating()
		}
	}

	@IBAction func restore(sender: AnyObject) {
		spinner?.startAnimating()
		Flurry.logEvent("Restore Pro Clicked")
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
