//
//  WebViewController.swift
//  OptOutside
//
//  Created by Josiah Mory on 11/9/17.
//  Copyright © 2017 kickinbahk Productions. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        print("webview loaded: \(url)")
        makeURLRequest(url: url)
    }
    
    func makeURLRequest(url: String) {
        print(url)
        if let convertedURL = URL(string: url) {
            let request = URLRequest(url: convertedURL)
            webView.load(request)
        }
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
