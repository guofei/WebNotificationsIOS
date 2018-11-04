//
//  PageViewController.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/23/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit
import WebKit

class PageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
  struct StoryBoard {
    static let ID = "PageView"
    static let Navi = "PageViewNavi"
    static let toShowDiffSegue = "toShowDiff"
  }

  var targetURL: String? {
    didSet {
      loadAddressURL()
    }
  }

  @IBOutlet weak var uiView: UIView!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  var webView: WKWebView?

  override func viewDidLoad() {
    super.viewDidLoad()

    webView = WKWebView(frame: view.frame)
    // webView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    webView!.uiDelegate = self
    webView!.navigationDelegate = self
    uiView.addSubview(webView!)
    uiView.sendSubviewToBack(webView!)

    spinner.startAnimating()
    loadAddressURL()
    Page.update(targetURL, done: {_ in })
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    spinner.stopAnimating()
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    spinner.stopAnimating()
  }

  @IBAction func stop(_ sender: UIBarButtonItem) {
    setChecked()
    self.dismiss(animated: true, completion: nil)
  }

  fileprivate func setChecked() {
    Page.setChanged(targetURL, changed: false)
  }

  fileprivate func loadAddressURL() {
    if let url = targetURL {
      if let requestURL = URL(string: url) {
        let req = URLRequest(url: requestURL)
        _ = webView?.load(req)
      }
    }
  }

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == StoryBoard.toShowDiffSegue {
      if let subVC = segue.destination as? DiffTableViewController {
        subVC.targetURL = targetURL
      }
    }
  }
}
