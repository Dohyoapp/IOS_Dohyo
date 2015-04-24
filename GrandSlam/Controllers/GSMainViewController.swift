//
//  GSMainViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 23/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

var navigationBar:GSNavigationBar = GSNavigationBar(frame: CGRectMake(0, 20, 260, NAVIGATIONBAR_HEIGHT), objects: [])

var profileView = UIView(frame:CGRectMake(260, 20, 60, NAVIGATIONBAR_HEIGHT))



@objc protocol MainVCgetCustomLeaguesCaller {
    optional func getCustomLeaguesEnd()
}






var mainViewControllerInstance:GSMainViewController!


class GSMainViewController: UIViewController, CustomLeagueCaller{
    
    var launchImageView:UIImageView!
    
    var leagues:NSArray!
    
    var waitingCreateCustomLeague:PFObject!
    
    class func getMainViewControllerInstance() -> GSMainViewController{
        return mainViewControllerInstance
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    
    override func viewDidLoad() {
        
        //self.presentViewController(GSTuttorial(), animated: false, completion: nil)
        
        var user = PFUser.currentUser()
        if( Utils.isParseNull(user["email"])){
            if( !Utils.isParseNull(user.sessionToken)){
                PFUser.becomeInBackground(user.sessionToken, block: { (user:PFUser!, error: NSError!) -> Void in
           
                })
            }
        }
        
        
        super.viewDidLoad()
        
        var bgStatusBar = UIView(frame: CGRectMake(0, 0, 320, 20))
        bgStatusBar.backgroundColor = SPECIALBLUE
        self.navigationController?.view.addSubview(bgStatusBar)
        
        self.navigationController?.navigationBar.hidden = true
        
        self.view.backgroundColor = SPECIALBLUE
        
        mainViewControllerInstance = self
        
        var imageName = "launch-screen-iphone5"
        if(UIDevice.isIPhone4()){
            imageName = "launch-screen-iphone4"
        }
        launchImageView = UIImageView(image: UIImage(named: imageName))
        self.view.addSubview(launchImageView)
        
        
        profileView.backgroundColor = UIColor.whiteColor()
        var profileButton = UIButton(frame: CGRectMake(10, 7, 41, 40))
        profileButton.backgroundColor = UIColor.whiteColor()
        profileButton.setImage(UIImage(named: "Profile_Icon"), forState: .Normal)
        profileButton.addTarget(self, action:"profileTap:", forControlEvents:.TouchUpInside)
        profileView.addSubview(profileButton)
        
        
        endGetCustomLeagues([])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar.hidden = false
        profileView.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        navigationBar.hidden    = true
        profileView.hidden      = true
    }
    
    
    var isAfterNewLeague:Bool = false
    var lastJoinedLeague:PFObject!
    func getCustomLeagues(isNewLeague:Bool, joinedLeague: PFObject!){
        
        GSCustomLeague.getCustomLeagues(self, user:PFUser.currentUser())
        GSUser.pendingInvitations()
        
        isAfterNewLeague = isNewLeague
        lastJoinedLeague = joinedLeague
    }
    
    
    var gsTuttorial = GSTuttorial()
    
    func endGetCustomLeagues(data: NSArray){
        
        leagues = data
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var isTutorialShown: AnyObject? = defaults.objectForKey("tutorialShown")
        if(isTutorialShown == nil){
            
            self.navigationController?.view.addSubview(gsTuttorial.view)
        }
        else{
            
            navigationBar = GSNavigationBar(frame: CGRectMake(0, 20, 260, NAVIGATIONBAR_HEIGHT), objects: data)
            self.navigationController?.navigationBar.hidden = false
            //self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
            self.navigationController?.view.addSubview(navigationBar)
            self.navigationController?.view.addSubview(profileView)
            launchImageView.hidden = true
        }
        
        
        
        
        GSCustomLeague.getNewJoinLeagueNumber()
        if(isAfterNewLeague){
            (createCustomLeague as MainVCgetCustomLeaguesCaller).getCustomLeaguesEnd!()
        }
        
        if( !Utils.isParseNull(lastJoinedLeague) &&  !Utils.isParseNull(lastJoinedLeague.objectId)){
            if(data.containsObject(lastJoinedLeague)){
                var index = data.indexOfObject(lastJoinedLeague)
                navigationBar.goToLeague(index)
            }
        }
    }
    
    
    var createAccountViewController:GSCreateAccountViewController!
    var profileViewController:GSProfileViewController!
    var createAccountView = false
    
    func profileTap(sender: UIButton!){
        
        navigationBar.navBarHideKeyBoard()
        
        var email: AnyObject? = PFUser.currentUser().valueForKey("email")
        
        if(!createAccountView){
            //self.navigationController?.pushViewController(GSCreateAccountViewController(), animated: true)
            if( Utils.isParseNull(email) ){
                createAccountViewController = GSCreateAccountViewController()
                if(sender == nil){
                    createAccountViewController.isFromCreateLeague = true
                }
                self.view.addSubview(createAccountViewController.view)
            }
            else{
                profileViewController = GSProfileViewController()
                self.view.addSubview(profileViewController.view)
            }
            createAccountView = true
        }
        else{
            
            if( Utils.isParseNull(email) ){
                if(navigationBar.customLeagueViewControlelr != nil){
                    navigationBar.customLeagueViewControlelr.closeView()
                }
                
                if(createAccountViewController != nil){
                    createAccountViewController.closeView()
                }
            }
            else{
                if(profileViewController != nil){
                    profileViewController.closeView()
                }
            }
        }
    }
    
    func refreshJoinCount(result : NSArray){
        navigationBar.addNotificationNumber(result)
    }
}
