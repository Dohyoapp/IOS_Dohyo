//
//  GSLeaderBoardViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 09/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


class GSLeaderBoardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView:UITableView!
    var tableViewData:NSArray!
    
    var customLeague:GSCustomLeague!
    
    var socialShareViewController : GSSocialShareViewController!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        var titleLabel = UIButton(frame: CGRectMake(0, YSTART, 320, 35))
        titleLabel.setTitle("Leaderboard & Prize", forState: .Normal)
        titleLabel.titleLabel!.font = UIFont(name:FONT3, size:15)
        titleLabel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleLabel.backgroundColor = SPECIALBLUE
        self.view.addSubview(titleLabel)
        
        
        var yPrize = YSTART+50
        if(customLeague.pfCustomLeague["mainUser"] as NSString == PFUser.currentUser().objectId){
            
            socialShareViewController = GSSocialShareViewController()
            socialShareViewController.customLeagueId = customLeague.pfCustomLeague.objectId
            socialShareViewController.view.frame = CGRectMake(0, YSTART+40, 320, 40)
            self.view.addSubview(socialShareViewController.view)
            
            yPrize = YSTART+100
        }
        
        var blueLine1 = UIView(frame:CGRectMake(0, yPrize, 320, 1))
        blueLine1.backgroundColor = SPECIALBLUE
        self.view.addSubview(blueLine1)
        
        var pastMatchLabel    = UILabel(frame:CGRectMake(0, yPrize+3, 320, 38))
        pastMatchLabel.text   = "< Swipe to see the latest results"
        pastMatchLabel.textAlignment = .Center
        pastMatchLabel.font   = UIFont(name:FONT1, size:18)
        pastMatchLabel.textColor = SPECIALBLUE
        self.view.addSubview(pastMatchLabel)
        
        var blueLine2 = UIView(frame:CGRectMake(0, yPrize+40, 320, 1))
        blueLine2.backgroundColor = SPECIALBLUE
        self.view.addSubview(blueLine2)
        
        yPrize = yPrize + 41
        
        var prizeLabel    = UILabel(frame:CGRectMake(70, yPrize, 60, 38))
        prizeLabel.text   = "Prize:"
        prizeLabel.textAlignment = .Center
        prizeLabel.font   = UIFont(name:FONT2, size:18)
        prizeLabel.textColor = SPECIALBLUE
        self.view.addSubview(prizeLabel)
        
        var prizeNameLabel    = UILabel(frame:CGRectMake(140, yPrize, 150, 38))
        prizeNameLabel.text   = customLeague.pfCustomLeague["prize"] as NSString
        prizeNameLabel.font   = UIFont(name:FONT3, size:18)
        prizeNameLabel.textColor = SPECIALBLUE
        self.view.addSubview(prizeNameLabel)
        
        
        tableView         = UITableView(frame:CGRectMake(0, yPrize+50, self.view.frame.size.width, self.view.frame.size.height-yPrize-50))
        tableView.dataSource    = self
        tableView.delegate      = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle  = .None
        self.view.addSubview(tableView)
        
        tableViewData = []
        
        
        dispatch_async(dispatch_get_main_queue(), {
            self.getUsersAndPoints()
        })
    }
    
    
    func closeView(){
        
        if(userProfileViewController != nil){
            userProfileViewController.view.removeFromSuperview()
        }
    }
    
    
    func getUsersAndPoints(){
        
        SVProgressHUD.show()
        var customLeaguePf = customLeague.pfCustomLeague as PFObject

        PFCloud.callFunctionInBackground("getUsersByUsersId", withParameters:["customLeagueId" : customLeaguePf.objectId]) { (result: AnyObject!, error: NSError!) -> Void in
            
            if error == nil {
                self.tableViewData = result as NSArray
                
                if(self.tableViewData != nil){
                    var myData = NSMutableArray(array:self.tableViewData)
                    if(myData.count > 1){
                    
                        var sortedArray = sorted(myData) { (obj1, obj2) in
                            
                            var p1:NSString = "0"
                            if(obj1.isKindOfClass(NSDictionary) && obj1.objectForKey("userPoints") != nil){
                                p1 = obj1.objectForKey("userPoints") as NSString
                            }
                            var p2:NSString = "0"
                            if(obj2.isKindOfClass(NSDictionary) && obj2.objectForKey("userPoints") != nil){
                                p2 = obj2.objectForKey("userPoints") as NSString
                            }
                            return p1.integerValue > p2.integerValue
                        }
                        
                        self.tableViewData = sortedArray
                    }
                }
                self.tableView.reloadData()
            }
            SVProgressHUD.dismiss()
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
       return 30
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("LeaderBoardCell") as GSLeaderBoardCell!
            if(cell == nil){
                cell = GSLeaderBoardCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"LeaderBoardCell")
            }
            cell.selectionStyle = .None
            
            cell.numberLabel.text = String(indexPath.row+1)
            var dico = tableViewData[indexPath.row] as NSDictionary
            var user = dico.objectForKey("user") as PFObject
            cell.nameLabel.text = user["username"] as NSString
        
        if(dico.objectForKey("userPoints") != nil){
            cell.pointsLabel.text = NSString(format:"%@ points", dico.objectForKey("userPoints") as NSString)
        }
            return cell
    }
    
    var userProfileViewController:GSUserProfileViewController!
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var dico = tableViewData[indexPath.row] as NSDictionary
        var user = dico.objectForKey("user") as PFObject
        
        if(user.objectId != PFUser.currentUser().objectId){
            
            userProfileViewController = GSUserProfileViewController()
            userProfileViewController.user = user
            self.view.addSubview(userProfileViewController.view)
        }
    }



}