//
//  GSUserProfileViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 19/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


class GSUserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView       = UITableView(frame:CGRectZero)
    var tableViewData   = NSMutableArray()
    
    var imageUserView:UIImageView!
    var emailLabel:UITextField!
    var userNameLabel:UITextField!
    
    var user:PFObject!
    
    
    let yStart = NAVIGATIONBAR_HEIGHT+20
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableViewData.addObject("Leagues")
        
        let leagues = GSMainViewController.getMainViewControllerInstance().leagues
        var league:PFObject
        for league in leagues{
            tableViewData.addObject(league["name"] as NSString)
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        tableView.frame         = CGRectMake(0, yStart, self.view.frame.size.width, self.view.frame.size.height-yStart)
        tableView.dataSource    = self
        tableView.delegate      = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle  = .None
        tableView.addGestureRecognizer( UITapGestureRecognizer(target: self, action:Selector("hideKeyBoard")) )
        self.view.addSubview(tableView)
    }
    
    func closeView(){
        
        self.view.removeFromSuperview()
    }
    
    func createMainCell(cell : UITableViewCell){
        
        imageUserView = UIImageView(frame: CGRectMake(100, 10, 120, 120))
        imageUserView.layer.cornerRadius = 60
        imageUserView.clipsToBounds = true
        
        let userImageFile:AnyObject! = user.valueForKey("image")
        if(userImageFile != nil){
            (userImageFile as PFFile).getDataInBackgroundWithBlock { (imageData: NSData!, error: NSError!) -> Void in
                if error == nil {
                    self.imageUserView.image = UIImage(data:imageData)
                }
                else{
                    self.imageUserView.image = UIImage(named:"Profile_Icon_Holder")
                }
            }
        }
        else{
            imageUserView.image = UIImage(named:"Profile_Plus")
        }
        
        cell.addSubview(imageUserView)
        
        
        
        userNameLabel = UITextField(frame: CGRectMake(50, 145, 220, 33))
        userNameLabel.userInteractionEnabled = false
        userNameLabel.text = user["username"] as NSString
        userNameLabel.textAlignment = .Center
        userNameLabel.font = UIFont(name:FONT1, size:15)
        userNameLabel.textColor = SPECIALBLUE
        userNameLabel.tag = 55
        cell.addSubview(userNameLabel)
        
        emailLabel = UITextField(frame: CGRectMake(50, 170, 220, 33))
        emailLabel.userInteractionEnabled = false
        emailLabel.text = user["email"] as NSString
        emailLabel.textAlignment = .Center
        emailLabel.font = UIFont(name:FONT1, size:15)
        emailLabel.textColor = SPECIALBLUE
        emailLabel.tag = 66
        cell.addSubview(emailLabel)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0){
            return 1
        }
        return tableViewData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        if(indexPath.section == 0){
            return 230
        }else{
            
            if(indexPath.row == 0){
                return 40
            }
            return 32
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            
            var cell = UITableViewCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"MainCustomCell")
            createMainCell(cell)
            cell.selectionStyle = .None
            return cell
        }
        else{
            
            var cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as GSProfileCell!
            if(cell == nil){
                cell = GSProfileCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"ProfileCell")
            }
            cell.selectionStyle = .None
            
            var objectString = tableViewData.objectAtIndex(indexPath.row) as NSString
            
            cell.labelText.font = UIFont(name:FONT1, size:18)
            if(indexPath.row == 0 || objectString.isEqualToString(SHARE_TEXXT)){
                cell.labelText.font = UIFont(name:FONT4, size:18)
            }
            cell.labelText.text = tableViewData.objectAtIndex(indexPath.row) as NSString
            
            
            return cell
        }
    }
    
}

