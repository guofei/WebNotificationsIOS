//
//  DiffViewController.swift
//  WebNotificationsIOS
//
//  Created by kaku on 11/18/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import UIKit

class DiffViewController: UIViewController {

	var targetURL : String? {
		didSet {
			showDiff()
		}
	}

	var diffText : String?

	@IBOutlet weak var textView: UITextView!

	override func viewDidLoad() {
        super.viewDidLoad()

		if let text = diffText {
			textView?.text = text
		}
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	private func showDiff() {
		if let url = targetURL {
			if let page = Page.getByURL(url) {
				self.diffText = page.contentDiff
				self.textView?.text = self.diffText
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

}
