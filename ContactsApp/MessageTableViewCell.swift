//
//  MessageTableViewCell.swift
//  ContactsApp
//
//  Created by Atom - Sachin on 9/11/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import UIKit
//import SnapKit

class MessageTableViewCell: UITableViewCell {
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        self.addSubview(self.nameLabel)
//        self.addSubview(self.bodyLabel)
//
//        nameLabel.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo(self).offset(10)
//            make.left.equalTo(self).offset(20)
//            make.right.equalTo(self).offset(-20)
//        }
//
//        bodyLabel.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo(nameLabel.snp.bottom).offset(1)
//            make.left.equalTo(self).offset(20)
//            make.right.equalTo(self).offset(-20)
//            make.bottom.equalTo(self).offset(-10)
//        }
    }

    // We won’t use this but it’s required for the class to compile
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
