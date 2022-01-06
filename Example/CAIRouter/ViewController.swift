//
//  ViewController.swift
//  GLRouter
//
//  Created by caijunlai on 11/17/2021.
//  Copyright (c) 2021 caijunlai. All rights reserved.
//

import UIKit
import CAIRouter

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let label = UILabel()
        label.text = "点击跳转"
        label.textColor = .lightGray
        label.frame.size = CGSize(width: 100, height: 30)
        label.center = view.center
        view.addSubview(label)
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        RouterCenter.shared.openURL(url: "router://home/detail?title=详情&name=测试", userInfo: ["userId" : "123456"]) { params in
           print(params)
        }
        
//        RouterCenter.shared.openURL(url: "router://home/detail?title=详情", modal: true)
        
//        RouterCenter.shared.openURL(url: "https://www.baidu.com")
    }
}
