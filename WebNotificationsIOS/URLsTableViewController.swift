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
        let result = try Realm().objects(Page.self).sorted(byProperty: "createdAt", ascending: false)
        return result
      } catch {
        return nil
      }
    }
  }
  var showPageOnce: String?

  @IBOutlet weak var editBar: UIBarButtonItem!

  @IBAction func edit(_ sender: AnyObject) {
    if tableView.isEditing {
      tableView?.setEditing(false, animated: true)
      editBar.title = NSLocalizedString("EditButtonNormalTitle", comment: "")
    } else {
      tableView?.setEditing(true, animated: true)
      editBar.title = NSLocalizedString("EditButtonEditedTitle", comment: "")
    }
  }

  @IBAction func refresh(_ sender: AnyObject) {
    refresh()
  }

  fileprivate func refresh() {
    refreshControl?.beginRefreshing()
    Page.updateAll() { (_) -> Void in
      DispatchQueue.main.sync {
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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    refreshControl?.beginRefreshing()
    tableView?.reloadData()
    self.refreshControl?.endRefreshing()

    if let url = showPageOnce {
      showPageOnce = nil
      performSegue(withIdentifier: StoryBoard.toWebPageSegue, sender: url)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    if let allPages = pages {
      return allPages.count
    } else {
      return 0
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "URLCell", for: indexPath)

    if let allPages = pages {
      let page = allPages[indexPath.row]
      var emoji = page.stopFetch ? "🔕" : ""
      if page.changed {
        emoji += "🆕"
      }
      cell.detailTextLabel?.text = emoji + page.formatedUpdateTime() + " " + page.url
      cell.textLabel?.text = page.title
      if page.changed {
        cell.accessoryType = UITableViewCellAccessoryType.checkmark
      } else {
        cell.accessoryType = UITableViewCellAccessoryType.none
      }
    }

    return cell
  }

  override func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
    if let allPages = pages {
      let page = allPages[indexPath.row]
      if tableView.isEditing {
        // let cell = tableView.cellForRowAtIndexPath(indexPath)
        performSegue(withIdentifier: StoryBoard.toAddURLSegue, sender: page.url)
      } else {
        // let cell = tableView.cellForRowAtIndexPath(indexPath)
        performSegue(withIdentifier: StoryBoard.toWebPageSegue, sender: page.url)
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
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // Delete the row from the data source
      if let allPages = pages {
        let page = allPages[indexPath.row]
        Page.deleteByURL(page.url)
        tableView.deleteRows(at: [indexPath], with: .fade)
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
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == StoryBoard.toWebPageSegue) {
      if let nav = segue.destination as? UINavigationController {
        if let subVC = nav.viewControllers.first as? PageViewController {
          if let url = sender as? String {
            subVC.targetURL = url
          }
        }
      }
    } else if (segue.identifier == StoryBoard.toAddURLSegue) {
      if let nav = segue.destination as? UINavigationController {
        if let addURLVC = nav.viewControllers.first as? URLAddTableViewController {
          if let url = sender as? String {
            addURLVC.originURL = url
          }
        }
      }
    }
  }
}
