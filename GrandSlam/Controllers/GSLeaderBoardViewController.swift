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
    
    let yStart = NAVIGATIONBAR_HEIGHT+20
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        var titleLabel = UIButton(frame: CGRectMake(0, yStart, 320, 33))
        titleLabel.setTitle("Leaderboard", forState: .Normal)
        titleLabel.titleLabel!.font = UIFont(name:FONT3, size:15)
        titleLabel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleLabel.backgroundColor = SPECIALBLUE
        self.view.addSubview(titleLabel)
        
        
        var yPrize = yStart+50
        if(customLeague.pfCustomLeague["mainUser"] as NSString == PFUser.currentUser().objectId){
            
            socialShareViewController = GSSocialShareViewController()
            socialShareViewController.customLeagueId = customLeague.pfCustomLeague.objectId
            socialShareViewController.view.frame = CGRectMake(0, yStart+40, 320, 40)
            self.view.addSubview(socialShareViewController.view)
            
            yPrize = yStart+100
        }
        
        
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
        
        var usersArray = NSMutableArray()
        if(customLeague.pfCustomLeague["mainUser"] != nil){
            usersArray.addObject(customLeague.pfCustomLeague["mainUser"])
        }
        if(customLeague.pfCustomLeague["joinUsers"] != nil){
            var users = customLeague.pfCustomLeague["joinUsers"] as NSArray
            usersArray.addObjectsFromArray(users)
        }
        getUsers(usersArray)
    }
    
    
    func getUsers(usersId: NSArray){
        
        SVProgressHUD.show()
        PFCloud.callFunctionInBackground("getUsersByuserId", withParameters:["usersId" : usersId]) { (result: AnyObject!, error: NSError!) -> Void in
            
            if error == nil {
                self.tableViewData = result as NSArray
                if(self.tableView != nil){
                    self.tableView.reloadData()
                }
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
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("LeaderBoardCell") as GSLeaderBoardCell!
            if(cell == nil){
                cell = GSLeaderBoardCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"LeaderBoardCell")
            }
            
            cell.numberLabel.text = String(indexPath.row+1)
            var user = tableViewData[indexPath.row] as PFObject
            cell.nameLabel.text = user["username"] as NSString
        
            cell.pointsLabel.text = NSString(format:"%d points", 54)
        
            return cell
    }
}