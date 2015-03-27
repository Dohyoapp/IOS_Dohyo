//
//  GSCreateAccountCell.swift
//  GrandSlam
//
//  Created by Explocial 6 on 29/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


class GSCreateAccountCell: UITableViewCell {
    
    var textField:UITextField!

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textField = UITextField(frame: CGRectMake(60, 0, 200, 33))
        textField.font = UIFont(name:FONT1, size:15)
        textField.textColor = SPECIALBLUE
        textField.layer.borderColor = SPECIALBLUE.CGColor
        textField.layer.borderWidth = 1.5
        textField.textAlignment = .Center
        textField.autocapitalizationType = .None
        self.addSubview(textField)
    }
    
}