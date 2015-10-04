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

	var urls = [String: Bool]()

	private func setChecked(url: String?) {
		if let url = url {
			urls[url] = nil
		}
	}

	@IBOutlet weak var editButton: UIButton!
	@IBAction func edit(sender: AnyObject) {
		if tableView.editing {
			tableView?.setEditing(false, animated: true)
			editButton?.setTitle(NSLocalizedString("EditButtonNormalTitle", comment: ""), forState: UIControlState.Normal)
		} else {
			tableView?.setEditing(true, animated: true)
			editButton?.setTitle(NSLocalizedString("EditButtonEditedTitle", comment: ""), forState: UIControlState.Normal)
		}
	}

	@IBAction func refresh(sender: AnyObject) {
		refresh()
	}

	private func refresh() {
		refreshControl?.beginRefreshing()
		urls.removeAll()
		Page.updateAll() { (dic: Dictionary<String, Bool>) -> Void in
			dispatch_sync(dispatch_get_main_queue()) {
				self.urls = dic
				self.tableView?.reloadData()
				self.refreshControl?.endRefreshing()
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		refresh()
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
			cell.detailTextLabel?.text = page.formatedUpdateTime() + " " + page.url
			cell.textLabel?.text = page.title
			if ((urls[page.url]) == true) {
				cell.accessoryType = UITableViewCellAccessoryType.Checkmark
			} else {
				cell.accessoryType = UITableViewCellAccessoryType.None
			}
		}

        return cell
    }

	override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
		if tableView.editing {
			let cell = tableView.cellForRowAtIndexPath(indexPath)
			performSegueWithIdentifier(StoryBoard.toAddURLSegue, sender: cell)
		} else {
			let cell = tableView.cellForRowAtIndexPath(indexPath)
			performSegueWithIdentifier(StoryBoard.toWebPageSegue, sender: cell)
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

	private struct StoryBoard {
		static let toWebPageSegue = "toWebPage"
		static let toAddURLSegue = "toAddURL"
	}

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == StoryBoard.toWebPageSegue) {
			if let subVC = segue.destinationViewController as? PageViewController {
				if let cell = sender as? UITableViewCell {
					if let indexPath = tableView.indexPathForCell(cell) {
						if let allPages = pages {
							let page = allPages[indexPath.row]
							setChecked(page.url)
							subVC.targetURL = page.url
						}
					}
				}
			}
		} else if (segue.identifier == StoryBoard.toAddURLSegue) {
			if let nav = segue.destinationViewController as? UINavigationController {
				if let addURLVC = nav.viewControllers.first as? URLAddTableViewController {
					if let cell = sender as? UITableViewCell {
						if let indexPath = tableView.indexPathForCell(cell) {
							if let allPages = pages {
								let page = allPages[indexPath.row]
								addURLVC.originURL = page.url
							}
						}
					}
				}
			}
		}
    }
}
