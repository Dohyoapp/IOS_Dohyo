//
//  GSNavigationBar.swift
//  GrandSlam
//
//  Created by Explocial 6 on 23/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


var createCustomLeague:GSCreateCustomLeagueViewController!

let SPACEBETWEENLABELS:CGFloat = 20

var fakeTextField = UITextField(frame:CGRectZero)


class GSNavigationBar: UIScrollView, UIScrollViewDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var buttonsArray:NSMutableArray = NSMutableArray()
    
    
    var customLeagueViewControlelr:GSCustomLeagueViewControlelr!
    var joinCustomLeagueViewController:GSJoinCustomLeagueViewController!
    
    
    var joinButton:UILabel!
    var joinNumber:UILabel!
    
    
    init(frame: CGRect, objects: NSArray) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.delegate = self;
        
        var sizeTextLabel   = UILabel()
        sizeTextLabel.font  = UIFont(name:FONT1, size:18)
        
        sizeTextLabel.frame = CGRectMake(0, 0, 160, NAVIGATIONBAR_HEIGHT)
        sizeTextLabel.text = "Contests:"
        sizeTextLabel.sizeToFit()
        var dohyoWidth = sizeTextLabel.frame.size.width+SPACEBETWEENLABELS-8
        var dohyoButton = UILabel(frame: CGRectMake(5, 2, dohyoWidth, NAVIGATIONBAR_HEIGHT))
        dohyoButton.text = "Contests:"
        dohyoButton.font = UIFont(name:FONT1, size:18)
        dohyoButton.textColor = SPECIALBLUE
        self.addSubview(dohyoButton)
        
        var startX:CGFloat = dohyoWidth
        
        sizeTextLabel.frame = CGRectMake(0, 0, 160, NAVIGATIONBAR_HEIGHT)
        sizeTextLabel.text = "Create"
        sizeTextLabel.sizeToFit()
        var createWidth = sizeTextLabel.frame.size.width+SPACEBETWEENLABELS
        var createButton = UILabel(frame: CGRectMake(startX, 2, createWidth, NAVIGATIONBAR_HEIGHT))
        createButton.userInteractionEnabled = true
        createButton.text = "Create"
        createButton.textAlignment = .Center
        createButton.addGestureRecognizer( UITapGestureRecognizer(target: self, action:Selector("createTap:")) )
        createButton.font = UIFont(name:FONT2, size:18)
        createButton.textColor = SPECIALBLUE
        self.addSubview(createButton)
        self.buttonsArray.addObject(createButton)
        
        startX += 6
        
        sizeTextLabel.frame = CGRectMake(0, 0, 160, NAVIGATIONBAR_HEIGHT)
        sizeTextLabel.text = "Join"
        sizeTextLabel.sizeToFit()
        var joinWidth = sizeTextLabel.frame.size.width+SPACEBETWEENLABELS
        joinButton = UILabel(frame: CGRectMake(startX+createWidth-5, 2, joinWidth, NAVIGATIONBAR_HEIGHT))
        joinButton.userInteractionEnabled = true
        joinButton.text = "Join"
        joinButton.textAlignment = .Center
        joinButton.addGestureRecognizer( UITapGestureRecognizer(target: self, action:Selector("joinTap:")) )
        joinButton.font  = UIFont(name:FONT1, size:18)
        joinButton.textColor = SPECIALBLUE
        self.addSubview(joinButton)
        self.buttonsArray.addObject(joinButton)
        
        
        joinNumber = UILabel(frame: CGRectMake(40, 13, 14, 14))
        joinNumber.layer.cornerRadius = 7
        joinNumber.clipsToBounds = true
        joinNumber.text = ""
        joinNumber.textAlignment = .Center
        joinNumber.font  = UIFont(name:FONT1, size:12)
        joinNumber.textColor = UIColor.whiteColor()
        joinNumber.backgroundColor = UIColor.redColor()
        joinButton.addSubview(joinNumber)
        joinNumber.hidden = true
        
        var i = 0
        var xViews = startX+createWidth+joinWidth
        var league:PFObject
        for league in objects{
            
            var leagueName = league.valueForKey("name") as! String
            
            sizeTextLabel.frame = CGRectMake(0, 0, 260, NAVIGATIONBAR_HEIGHT)
            sizeTextLabel.text = leagueName
            sizeTextLabel.sizeToFit()
            var buttonWidth = sizeTextLabel.frame.size.width+SPACEBETWEENLABELS
            var button = UILabel(frame: CGRectMake(xViews, 2, buttonWidth, NAVIGATIONBAR_HEIGHT))
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
        
        
        if(createCustomLeague == nil){//app launch only
            goToCreateViewController()
        }
        
        self.addSubview(fakeTextField)
        
        self.setContentOffset(CGPointMake(0, 0), animated:false)
    }
    
    
    func goToCreateViewController(){
    
        var createButton = self.buttonsArray[0] as! UILabel
            
        var gestures:NSArray = (createButton as UIView).gestureRecognizers!
        var tapGestureRecognizer:UITapGestureRecognizer = gestures[0] as! UITapGestureRecognizer
        createTap(tapGestureRecognizer)
        
        var wCustomLeague = GSMainViewController.getMainViewControllerInstance().waitingCreateCustomLeague
        if( !Utils.isParseNull(wCustomLeague) && !Utils.isParseNull(wCustomLeague["name"]) ){
            createCustomLeague.endCreationCustomLeague(wCustomLeague)
            wCustomLeague = PFObject()
        }
    }
    
    
    func setButtonFont(sender: UILabel){
        for button in self.buttonsArray{
            var abutton:UILabel = button as! UILabel
            abutton.font = UIFont(name:FONT1, size:18)
        }
        sender.font  = UIFont(name:FONT2, size:18)
    }
    
    
    func navBarHideKeyBoard(){
        
        dispatch_async(dispatch_get_main_queue(), {
            if( Utils.isParseNull(fakeTextField)){
                fakeTextField = UITextField(frame:CGRectZero)
                self.addSubview(fakeTextField)
            }
            fakeTextField.becomeFirstResponder()
            fakeTextField.resignFirstResponder()
        })
    }
    
    func closeAccountViewIfNeeded(){
        
        navBarHideKeyBoard()
        
        if(GSMainViewController.getMainViewControllerInstance().createAccountView){
            
            if( Utils.isParseNull(PFUser.currentUser()["email"])){
                if(GSMainViewController.getMainViewControllerInstance().createAccountViewController != nil){
                    GSMainViewController.getMainViewControllerInstance().createAccountViewController.closeView()
                }
            }
            else{
                if(GSMainViewController.getMainViewControllerInstance().profileViewController != nil){
                    GSMainViewController.getMainViewControllerInstance().profileViewController.closeView()
                }
            }
        }
    }
    
    
    func createTap(recognizer: UITapGestureRecognizer!){
        
        closeAccountViewIfNeeded()
        var createLabel = recognizer.view as! UILabel
        setButtonFont(createLabel);
        
        createCustomLeague = GSCreateCustomLeagueViewController()
        GSMainViewController.getMainViewControllerInstance().view.addSubview(createCustomLeague.view)

        if(customLeagueViewControlelr != nil){
            customLeagueViewControlelr.closeView()
        }
        if(joinCustomLeagueViewController != nil){
            joinCustomLeagueViewController.closeView()
        }
        
        self.setContentOffset(CGPointMake(createLabel.center.x-150, 0), animated:true)
    }
    
    func joinTap(recognizer: UITapGestureRecognizer!){
        
        closeAccountViewIfNeeded()
        var joinLabel = recognizer.view as! UILabel
        setButtonFont(joinLabel);
        
        joinCustomLeagueViewController = GSJoinCustomLeagueViewController()
        joinCustomLeagueViewController.countArray = countArray
        GSMainViewController.getMainViewControllerInstance().view.addSubview(joinCustomLeagueViewController.view)
        
        if(customLeagueViewControlelr != nil){
            customLeagueViewControlelr.closeView()
        }
        
        var x = joinLabel.center.x-150
        if(x > 0){
            self.setContentOffset(CGPointMake(x, 0), animated:true)
        }
        else{
            self.setContentOffset(CGPointMake(0, 0), animated:true)
        }
    }
    
    func otherButtonTap(recognizer: UITapGestureRecognizer!){
        
        closeAccountViewIfNeeded()
        var label = recognizer.view as! UILabel
        labelSelected(label)
    }
    
    func labelSelected(label: UILabel){
        
        if(joinCustomLeagueViewController != nil){
            joinCustomLeagueViewController.closeView()
        }
        
        if(label.font  != UIFont(name:FONT2, size:18)){
            
            setButtonFont(label);
            
            if(customLeagueViewControlelr != nil){
                customLeagueViewControlelr.closeView()
            }
            customLeagueViewControlelr = GSCustomLeagueViewControlelr()
            customLeagueViewControlelr.customLeague = GSCustomLeague.getCacheCustomLeagues()[label.tag] as! GSCustomLeague
            GSMainViewController.getMainViewControllerInstance().view.addSubview(customLeagueViewControlelr.view)
            
            if(label.center.x-157 > 0){
                self.setContentOffset(CGPointMake(label.center.x-157, 0), animated:true)
            }
        }
        else{
            customLeagueViewControlelr.backToMainView()
        }
    }
    
    
    func goToLeague(num: NSInteger){
        SVProgressHUD.show()
        if(buttonsArray.count > num+2){
            var label:UILabel = buttonsArray.objectAtIndex(num+2) as! UILabel
            labelSelected(label)
        }
        SVProgressHUD.dismiss()
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
    }
    
    
    var countArray:NSArray!
    func addNotificationNumber(result: NSArray){
        
        if(result.count > 0){
            
            var total:NSInteger = (result.firstObject as! NSInteger) + (result.lastObject as! NSInteger)
            if(total > 0){
                joinNumber.hidden = false
                joinNumber.text = String(total)
            }else{
                joinNumber.hidden = true
            }
            countArray = result
        }
    }


}