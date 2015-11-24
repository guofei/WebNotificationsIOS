//
//  URLsTableViewController.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/17/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import Ji


class URLsTableViewController: UITableViewController {

	var pages : Results<Page>? {
		get {
			do {
				let result = try Realm().objects(Page).sorted("createdAt", ascending: false)
				return result
			} catch {
				return nil
			}
		}
	}

	@IBOutlet weak var editBar: UIBarButtonItem!

	@IBAction func edit(sender: AnyObject) {
		if tableView.editing {
			tableView?.setEditing(false, animated: true)
			editBar.title = NSLocalizedString("EditButtonNormalTitle", comment: "")
		} else {
			tableView?.setEditing(true, animated: true)
			editBar.title = NSLocalizedString("EditButtonEditedTitle", comment: "")
		}
	}

	@IBAction func refresh(sender: AnyObject) {
		refresh()
	}

	private func refresh() {
		refreshControl?.beginRefreshing()
		Page.updateAll() { (_) -> Void in
			dispatch_sync(dispatch_get_main_queue()) {
				self.tableView?.reloadData()
				self.refreshControl?.endRefreshing()
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		refresh()
		editBar.possibleTitles = [
			NSLocalizedString("EditButtonNormalTitle", comment: ""),
			NSLocalizedString("EditButtonEditedTitle", comment: "")
		]

    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		refreshControl?.beginRefreshing()
		tableView?.reloadData()
		self.refreshControl?.endRefreshing()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if let allPages = pages {
			return allPages.count
		} else {
			return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("URLCell", forIndexPath: indexPath)

		if let allPages = pages {
			let page = allPages[indexPath.row]
			if page.changed {
				cell.detailTextLabel?.text = "🆕" + page.formatedUpdateTime() + " " + page.url
			} else {
				cell.detailTextLabel?.text = page.formatedUpdateTime() + " " + page.url
			}
			cell.textLabel?.text = page.title
			if page.changed {
				cell.accessoryType = UITableViewCellAccessoryType.Checkmark
			} else {
				cell.accessoryType = UITableViewCellAccessoryType.None
			}
		}

        return cell
    }

	override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
		if let allPages = pages {
			let page = allPages[indexPath.row]
			if tableView.editing {
				// let cell = tableView.cellForRowAtIndexPath(indexPath)
				performSegueWithIdentifier(StoryBoard.toAddURLSegue, sender: page.url)
			} else {
				// let cell = tableView.cellForRowAtIndexPath(indexPath)
				performSegueWithIdentifier(StoryBoard.toWebPageSegue, sender: page.url)
			}
		}
	}

	/*
	override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
		let alert = UIAlertController(title: "Update", message: "Page has been updated", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	*/


	/*
	// Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
	*/


    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
			if let allPages = pages {
				let page = allPages[indexPath.row]
				Page.deleteByURL(page.url)
				tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
			}
        }
    }


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


    // MARK: - Navigation

	struct StoryBoard {
		static let toWebPageSegue = "toWebPage"
		static let toAddURLSegue = "toAddURL"
	}

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == StoryBoard.toWebPageSegue) {
			if let nav = segue.destinationViewController as? UINavigationController {
				if let subVC = nav.viewControllers.first as? PageViewController {
					if let url = sender as? String {
							subVC.targetURL = url
					}
				}
			}
		} else if (segue.identifier == StoryBoard.toAddURLSegue) {
			if let nav = segue.destinationViewController as? UINavigationController {
				if let addURLVC = nav.viewControllers.first as? URLAddTableViewController {
					if let url = sender as? String {
						addURLVC.originURL = url
					}
				}
			}
		}
    }
}
