//
//  DetailViewController.swift
//  GLRouter_Example
//
//  Created by caijunlai on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .green
        
        let label = UILabel()
        label.text = "点击返回"
        label.textColor = .lightGray
        label.frame.size = CGSize(width: 100, height: 30)
        label.center = view.center
        view.addSubview(label)
        
        if let p = routerParams {
           print(p)
           self.title = p["title"] as? String
        }
        
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let c = self.routerCallBack {
            c(["callBack": "123"])
        }
        if let nav = navigationController {
            nav.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
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
