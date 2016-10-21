//
//  WebViewController.swift
//  Whisper
//
//  Created by Hayden on 2016/10/21.
//  Copyright © 2016年 unimelb. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var webView: WKWebView!
    var webURL = "www.google.com.au"
    var titles = "Web"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let url = URL(string: webURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        self.title = titles
        
        // Do any additional setup after loading the view.
    }

    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
