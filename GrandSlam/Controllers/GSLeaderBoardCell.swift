//
//  GSLeaderBoardCell.swift
//  GrandSlam
//
//  Created by Explocial 6 on 09/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


class GSLeaderBoardCell: UITableViewCell {
    
    var numberLabel:UILabel!
    var nameLabel:UILabel!
    var pointsLabel:UILabel!
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        numberLabel = UILabel(frame: CGRectMake(10, 0, 20, 33))
        numberLabel.font = UIFont(name:FONT3, size:15)
        numberLabel.textColor = SPECIALBLUE
        self.addSubview(numberLabel)
        
        nameLabel = UILabel(frame: CGRectMake(50, 0, 200, 33))
        nameLabel.font = UIFont(name:FONT3, size:15)
        nameLabel.textColor = SPECIALBLUE
        self.addSubview(nameLabel)
        
        
        pointsLabel = UILabel(frame: CGRectMake(245, 0, 65, 33))
        pointsLabel.font = UIFont(name:FONT3, size:15)
        pointsLabel.textColor = SPECIALBLUE
        self.addSubview(pointsLabel)
    }
    
}