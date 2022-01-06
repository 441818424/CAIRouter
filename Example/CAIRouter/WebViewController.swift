//
//  WebViewController.swift
//  GLRouter_Example
//
//  Created by caijunlai on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WebKit
import CAIRouter

class WebViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        
        if let p = routerParams {
            if let url = URL(string: (p[kRouterWebURLKey] as? String) ?? "") {
                let request = URLRequest(url: url)
                webView.load(request)
            }  
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
