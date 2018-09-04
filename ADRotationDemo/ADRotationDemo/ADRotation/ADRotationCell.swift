//
//  ADRotationCell.swift
//  ADRotationDemo
//
//  Created by Public on 2018/9/4.
//  Copyright © 2018年 Public. All rights reserved.
//

import UIKit

class ADRotationCell: UICollectionViewCell {

    var titleLabel : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.titleLabel = UILabel.init()
        self.titleLabel?.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width-5, height: self.bounds.size.height)
        self.contentView.addSubview(titleLabel!)
    }

}
