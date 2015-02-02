//
//  GSMainViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 23/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

var navigationBar:GSNavigationBar = GSNavigationBar(frame: CGRectMake(0, 0, 320, NAVIGATIONBAR_HEIGHT), objects: [])

var profileButton:UIButton = UIButton(frame: CGRectMake(279, 20, 41, 40))




var mainViewControllerInstance:GSMainViewController!

class GSMainViewController: UIViewController, CustomLeagueCaller {
    
    var launchImageView:UIImageView!
    
    var leagues:NSArray!
    
    class func getMainViewControllerInstance() -> GSMainViewController{
        return mainViewControllerInstance
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func viewDidLoad() {
        
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
        
       // ParseConfig.getLeagues(self)
        GSCustomLeagues.getCustomLeagues(self, user:PFUser.currentUser())
        
        profileButton.backgroundColor = UIColor.whiteColor()
        profileButton.setImage(UIImage(named: "Profile_Icon"), forState: .Normal)
        profileButton.addTarget(self, action:"profileTap:", forControlEvents:.TouchUpInside)
        
        // Do any additional setup after loading the view, typically from a nib.
        /*self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton*/
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar.hidden = false
        profileButton.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        navigationBar.hidden = true
        profileButton.hidden = true
    }
    
    
    func endGetCustomLeagues(data: NSArray){
        
        leagues = data
        
        navigationBar = GSNavigationBar(frame: CGRectMake(0, 20, 320, NAVIGATIONBAR_HEIGHT), objects: data)
        self.navigationController?.navigationBar.hidden = false
        //self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController?.view.addSubview(navigationBar)
        self.navigationController?.view.addSubview(profileButton)
        launchImageView.hidden = true
    }
    
    
    var createAccountViewController:GSCreateAccountViewController!
    var profileViewController:GSProfileViewController!
    var createAccountView = false
    
    func profileTap(sender: UIButton!){
        
        var email: AnyObject? = PFUser.currentUser().valueForKey("email")
        
        if(!createAccountView){
            //self.navigationController?.pushViewController(GSCreateAccountViewController(), animated: true)
            if(email == nil){
                createAccountViewController = GSCreateAccountViewController()
                self.view.addSubview(createAccountViewController.view)
            }
            else{
                profileViewController = GSProfileViewController()
                self.view.addSubview(profileViewController.view)
            }
            createAccountView = true
        }
        else{
            
            if(email == nil){
                createAccountViewController.closeView()
            }
            else{
                profileViewController.closeView()
            }
        }
    }
    
}
