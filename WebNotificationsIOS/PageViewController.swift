//
//  PageViewController.swift
//  WebNotificationsIOS
//
//  Created by kaku on 9/23/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit

class PageViewController: UIViewController, UIWebViewDelegate {
	@IBOutlet weak var webView: UIWebView!
	@IBOutlet weak var spinner: UIActivityIndicatorView!

	var targetURL : String? {
		didSet {
			loadAddressURL()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		webView?.delegate = self
		spinner?.startAnimating()
		loadAddressURL()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func loadAddressURL() {
		if let url = targetURL {
			if let requestURL = NSURL(string: url) {
				let req = NSURLRequest(URL: requestURL)
				webView?.loadRequest(req)
			}
		}
	}

	func webViewDidFinishLoad(webView: UIWebView) {
		spinner?.stopAnimating()
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
