//
//  GSNavigationBar.swift
//  GrandSlam
//
//  Created by Explocial 6 on 23/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

var createCustomLeague:GSCreateCustomLeague!


class GSNavigationBar: UIScrollView, UIScrollViewDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var buttonsArray:NSMutableArray = NSMutableArray()
    
    init(frame: CGRect, objects: NSArray) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.delegate = self;
        
        var sizeTextLabel   = UILabel()
        sizeTextLabel.font  = UIFont(name:FONT1, size:18)
        
        sizeTextLabel.frame = CGRectMake(0, 0, 160, NAVIGATIONBAR_HEIGHT)
        sizeTextLabel.text = "Create"
        sizeTextLabel.sizeToFit()
        var createWidth = sizeTextLabel.frame.size.width+30
        var createButton = UILabel(frame: CGRectMake(0, 0, createWidth, NAVIGATIONBAR_HEIGHT))
        createButton.userInteractionEnabled = true
        createButton.text = "Create"
        createButton.textAlignment = .Center
        createButton.addGestureRecognizer( UITapGestureRecognizer(target: self, action:Selector("createTap:")) )
        createButton.font = UIFont(name:FONT2, size:18)
        createButton.textColor = SPECIALBLUE
        self.addSubview(createButton)
        self.buttonsArray.addObject(createButton)
        
        
        sizeTextLabel.frame = CGRectMake(0, 0, 160, NAVIGATIONBAR_HEIGHT)
        sizeTextLabel.text = "Join"
        sizeTextLabel.sizeToFit()
        var joinWidth = sizeTextLabel.frame.size.width+30
        var joinButton = UILabel(frame: CGRectMake(createWidth, 0, joinWidth, NAVIGATIONBAR_HEIGHT))
        joinButton.userInteractionEnabled = true
        joinButton.text = "Join"
        joinButton.textAlignment = .Center
        joinButton.addGestureRecognizer( UITapGestureRecognizer(target: self, action:Selector("joinTap:")) )
        joinButton.font  = UIFont(name:FONT1, size:18)
        joinButton.textColor = SPECIALBLUE
        self.addSubview(joinButton)
        self.buttonsArray.addObject(joinButton)
        
        var i = 0
        var xViews = createWidth+joinWidth
        var league:PFObject
        for league in objects{
            
            var leagueName = league.valueForKey("title") as NSString
            
            sizeTextLabel.frame = CGRectMake(0, 0, 260, NAVIGATIONBAR_HEIGHT)
            sizeTextLabel.text = leagueName
            sizeTextLabel.sizeToFit()
            var buttonWidth = sizeTextLabel.frame.size.width+30
            var button = UILabel(frame: CGRectMake(xViews, 0, buttonWidth, NAVIGATIONBAR_HEIGHT))
            button.userInteractionEnabled = true
            button.text = leagueName
            button.textAlignment = .Center
            button.addGestureRecognizer( UITapGestureRecognizer(target: self, action:Selector("otherButtonTap:")) )
            button.font = UIFont(name:FONT1, size:18)
            button.textColor = SPECIALBLUE
            button.tag = i
            //greenView.backgroundColor = UIColor.greenColor();
            self.addSubview(button)
            self.buttonsArray.addObject(button)
            xViews += buttonWidth
            i += 1
        }
        
        self.contentSize = CGSizeMake(xViews+40, 44)
        self.showsHorizontalScrollIndicator = false
        
        var gestures:NSArray = (createButton as UIView).gestureRecognizers!
        var tapGestureRecognizer:UITapGestureRecognizer = gestures[0] as UITapGestureRecognizer
        createTap(tapGestureRecognizer)
    }
    
    
    func setButtonFont(sender: UILabel){
        for button in self.buttonsArray{
            var abutton:UILabel = button as UILabel
            abutton.font = UIFont(name:FONT1, size:18)
        }
        sender.font  = UIFont(name:FONT2, size:18)
    }
    
    
    func createTap(recognizer: UITapGestureRecognizer!){
        setButtonFont(recognizer.view as UILabel);
        
        createCustomLeague = GSCreateCustomLeague()
        GSMainViewController.getMainViewControllerInstance().view.addSubview(createCustomLeague.view)
    }
    
    func joinTap(recognizer: UITapGestureRecognizer!){
        setButtonFont(recognizer.view as UILabel);
        
    }
    
    func otherButtonTap(recognizer: UITapGestureRecognizer!){
        setButtonFont(recognizer.view as UILabel);
        
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
    }
}