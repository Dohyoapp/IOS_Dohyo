//
//  GSProfileCell.swift
//  GrandSlam
//
//  Created by Explocial 6 on 30/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

class GSProfileCell: UITableViewCell {
    
    var labelText:UILabel!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        labelText = UILabel(frame: CGRectMake(0, 0, 320, 33))
        labelText.font = UIFont(name:FONT1, size:15)
        labelText.textColor = SPECIALBLUE
        labelText.textAlignment = .Center
        self.addSubview(labelText)
    }
    
}
