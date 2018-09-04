//
//  ViewController.swift
//  ADRotationDemo
//
//  Created by Public on 2018/9/4.
//  Copyright © 2018年 Public. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        let bgView = UIView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 30))
        bgView.backgroundColor = UIColor.white
        self.view.addSubview(bgView)
        
        let imageView = UIImageView.init()
        imageView.frame = CGRect.init(x: 10, y: 2.5, width: 25, height: 25)
        imageView.image = UIImage.init(named: "laba")
        bgView.addSubview(imageView)
        
        let ad = ADRotation.init(frame: CGRect.init(x: 40, y: 0, width: UIScreen.main.bounds.size.width-40, height: 30), titles: ["这是第一行数据","这是第二行数据","这是第三行数据"])
        ad.titleColor = UIColor.blue
        ad.titleFont = UIFont.systemFont(ofSize: 15)
        ad.delegate = self
        bgView.addSubview(ad)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController:ADRotationDelegate{
    func adRotation(adRotation: ADRotation, didSelectAt index: Int) {
        
    }

    func adRotation(adRotation: ADRotation, didScrollTo index: Int) {

    }
}

