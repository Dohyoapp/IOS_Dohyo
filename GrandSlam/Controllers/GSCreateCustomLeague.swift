//
//  GSCreateCustomLeague.swift
//  GrandSlam
//
//  Created by Explocial 6 on 02/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

class GSCreateCustomLeague: UIViewController, UITextFieldDelegate {
    
    var customLeagueNameLabel:UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let yStart = NAVIGATIONBAR_HEIGHT+20

        var scrollView = UIScrollView(frame:CGRectMake(0, yStart, 320, self.view.frame.size.height - yStart))
        self.view.addSubview(scrollView)
        
        var premierLeagueLabel = UILabel(frame:CGRectMake(0, 5, 320, 38))
        premierLeagueLabel.text = "Premier League Football"
        premierLeagueLabel.textAlignment = .Center
        premierLeagueLabel.font  = UIFont(name:FONT2, size:18)
        premierLeagueLabel.textColor = SPECIALBLUE
        scrollView.addSubview(premierLeagueLabel)
        
        var blueLine = UIView(frame:CGRectMake(0, 40, 320, 2))
        blueLine.backgroundColor = SPECIALBLUE
        scrollView.addSubview(blueLine)
        
        
        customLeagueNameLabel = UITextField(frame: CGRectMake(70, 55, 180, 33))
        customLeagueNameLabel.font = UIFont(name:FONT1, size:15)
        customLeagueNameLabel.textColor = SPECIALBLUE
        customLeagueNameLabel.layer.borderColor = SPECIALBLUE.CGColor
        customLeagueNameLabel.layer.borderWidth = 1.5
        customLeagueNameLabel.textAlignment = .Center
        customLeagueNameLabel.attributedPlaceholder = NSAttributedString(string:"Name your League",
            attributes:[NSForegroundColorAttributeName: SPECIALBLUE])
        customLeagueNameLabel.delegate = self
        scrollView.addSubview(customLeagueNameLabel)
        
    }


    func textFieldShouldReturn(textField: UITextField) -> Bool{
    
        textField.resignFirstResponder()
        return true
    }

}