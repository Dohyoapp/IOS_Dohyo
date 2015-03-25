//
//  GSJoinCustomLeagueViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 09/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


class GSJoinCustomLeagueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomLeagueCaller {
    
    var tableView = UITableView(frame:CGRectZero)
    var tableViewDataNew:NSArray!
    var tableViewDataOld:NSArray!
    
    var countArray:NSArray!
    
    
    
    var publicButton: UIButton!
    var privateButton: UIButton!
    
    var publicData:NSArray!
    var privateData:NSArray!
    
    
    var publicNumber:UILabel!
    var privateNumber:UILabel!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        publicButton = UIButton(frame: CGRectMake(10, YSTART+5, 145, 33))
        publicButton.setTitle("Public", forState: .Normal)
        publicButton.titleLabel!.font = UIFont(name:FONT2, size:18)
        publicButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        publicButton.backgroundColor = UIColor.whiteColor()
        publicButton.addTarget(self, action:"publicButtonTap:", forControlEvents:.TouchUpInside)
        //publicButton.alpha = 0.6
        self.view.addSubview(publicButton)
        
        publicNumber = UILabel(frame: CGRectMake(100, 0, 15, 15))
        publicNumber.layer.cornerRadius = 7
        publicNumber.clipsToBounds = true
        publicNumber.textAlignment = .Center
        publicNumber.font  = UIFont(name:FONT1, size:14)
        publicNumber.textColor = UIColor.whiteColor()
        publicNumber.backgroundColor = UIColor.redColor()
        publicButton.addSubview(publicNumber)
        publicNumber.hidden = true
        
        if(countArray != nil && countArray.count > 0){
            var publicCount = countArray.firstObject as Int
            if(publicCount > 0){
                publicNumber.text = String(publicCount)
                publicNumber.hidden = false
            }
        }
        
        
        privateButton = UIButton(frame: CGRectMake(165, YSTART+5, 145, 33))
        privateButton.setTitle("Private", forState: .Normal)
        privateButton.titleLabel!.font = UIFont(name:FONT1, size:18)
        privateButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        privateButton.backgroundColor = UIColor.whiteColor()
        privateButton.addTarget(self, action:"privateButtonTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(privateButton)
        
        privateNumber = UILabel(frame: CGRectMake(100, 0, 15, 15))
        privateNumber.layer.cornerRadius = 7
        privateNumber.clipsToBounds = true
        privateNumber.textAlignment = .Center
        privateNumber.font  = UIFont(name:FONT1, size:14)
        privateNumber.textColor = UIColor.whiteColor()
        privateNumber.backgroundColor = UIColor.redColor()
        privateButton.addSubview(privateNumber)
        privateNumber.hidden = true
        
        if(countArray != nil && countArray.count > 0){
            var privateCount = countArray.lastObject as Int
            if(privateCount > 0){
                privateNumber.text = String(privateCount)
                privateNumber.hidden = false
            }
        }
        
        tableView.frame         = CGRectMake(0, YSTART+50, self.view.frame.size.width, self.view.frame.size.height-YSTART-50)
        tableView.dataSource    = self
        tableView.delegate      = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle  = .None
        self.view.addSubview(tableView)
        
        tableViewDataNew = []
        tableViewDataOld = []
        
        dispatch_async(dispatch_get_main_queue(), {
            GSCustomLeague.getAllPublicCustomLeagues(self)
        })
    }
    
    func closeView(){
        
        self.view.removeFromSuperview()
    }
    
    func endGetAllPublicCustomLeagues(data : NSArray){
        
        publicData = data
        
        tableViewDataNew = publicData.firstObject as NSArray
        tableViewDataOld = publicData.lastObject as NSArray
        
        tableView.reloadData()
        
        GSCustomLeague.getAllPrivateCustomLeagues(self)
        
        GSUser.saveLastJoinViewDate()
    }
    
    func endGetAllPrivateCustomLeagues(data : NSArray){
        
        privateData = data
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        /*if(section == 0){
            return 0
        }
        else{*/
            return 40.0
        //}
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = UIView(frame: CGRectMake(0, 0, 320, 40))
        
        
            var blueLineTop = UIView(frame: CGRectMake(0, 0, 320, 1))
            blueLineTop.backgroundColor = SPECIALBLUE
            headerView.addSubview(blueLineTop)
            
            var oldInvitationLabel = UILabel(frame: CGRectMake(0, 1, 320, 38))
            oldInvitationLabel.textAlignment = .Center
            oldInvitationLabel.font  = UIFont(name:FONT2, size:18)
            oldInvitationLabel.textColor = SPECIALBLUE
            oldInvitationLabel.backgroundColor = UIColor.whiteColor()
            headerView.addSubview(oldInvitationLabel)
        if(section == 1){
            oldInvitationLabel.text = "Older Invitations"
        }
        else{
            oldInvitationLabel.text = "New Invitations"
        }
            
            var blueLineBottom = UIView(frame: CGRectMake(0, 39, 320, 1))
            blueLineBottom.backgroundColor = SPECIALBLUE
            headerView.addSubview(blueLineBottom)
        
        
        return headerView
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return tableViewDataNew.count
        }else{
            return tableViewDataOld.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            
            var cell = tableView.dequeueReusableCellWithIdentifier("JoinCustomCell") as UITableViewCell!
            if(cell == nil){
                cell = UITableViewCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"JoinCustomCell")
                
                var joinButton = UIButton(frame: CGRectMake(265, 10, 45, 30))
                joinButton.setTitle("Join", forState: .Normal)
                joinButton.titleLabel!.font = UIFont(name:FONT2, size:15)
                joinButton.setTitleColor(SPECIALBLUE, forState: .Normal)
                joinButton.backgroundColor = UIColor.whiteColor()
                joinButton.addTarget(self, action:"joinButtonTap:", forControlEvents:.TouchUpInside)
                cell.addSubview(joinButton)
                
                cell.textLabel?.font = UIFont(name:FONT1, size:17)
                cell.textLabel?.textColor = SPECIALBLUE
            }
            
            cell.tag  = indexPath.row
            cell.selectionStyle = .None
        
            if(indexPath.section == 0){
            
                if(tableViewDataNew.count > indexPath.row){
                    var data: AnyObject? = tableViewDataNew[indexPath.row] as AnyObject
                    if(data != nil){
                        var customLeague = tableViewDataNew[indexPath.row] as PFObject
                        cell.textLabel?.text = customLeague["name"] as NSString
                    }
                }
            }
            else{
                
                if(tableViewDataOld.count > indexPath.row){
                    var data: AnyObject? = tableViewDataOld[indexPath.row] as AnyObject
                    if(data != nil){
                        var customLeague = tableViewDataOld[indexPath.row] as PFObject
                        cell.textLabel?.text = customLeague["name"] as NSString
                    }
                }
            }
        
            return cell
    }
    
    func publicButtonTap(sender: UIButton!){
        
       // publicButton.alpha = 0.6
       // privateButton.alpha  = 1
        
        publicButton.titleLabel!.font = UIFont(name:FONT2, size:18)
        privateButton.titleLabel!.font = UIFont(name:FONT1, size:18)
        
        if(publicData != nil){
            tableViewDataNew = publicData.firstObject as NSArray
            tableViewDataOld = publicData.lastObject as NSArray
        }
        
        tableView.reloadData()
    }
    
    func privateButtonTap(sender: UIButton!){
        
       // privateButton.alpha = 0.6
      //  publicButton.alpha  = 1
        
        publicButton.titleLabel!.font = UIFont(name:FONT1, size:18)
        privateButton.titleLabel!.font = UIFont(name:FONT2, size:18)
        
        if(privateData != nil){
            tableViewDataNew = privateData.firstObject as NSArray
            tableViewDataOld = privateData.lastObject as NSArray
        }
        else{
            tableViewDataNew = []
            tableViewDataOld = []
        }
        
        tableView.reloadData()
    }
    
    func joinButtonTap(sender: UIButton!){
        
        var cell = (sender as UIView).superview!
        
        var indexPath: NSIndexPath = tableView.indexPathForCell(cell as UITableViewCell) as NSIndexPath!
        
        var num = cell.tag
        var customLeague:PFObject!
        
        if(indexPath.section == 0){
            customLeague    = tableViewDataNew[num] as PFObject
            if(countArray != nil && countArray.count > 1){
                var firstValue  = NSNumber(integer:(countArray.firstObject as Int) - 1)
                var secondValue = countArray.lastObject as NSNumber
                countArray      = [firstValue, secondValue]
            }
        }
        else{
            customLeague    = tableViewDataOld[num] as PFObject
            if(countArray != nil && countArray.count > 1){
                var firstValue  = countArray.firstObject as NSNumber
                var secondValue = NSNumber(integer:(countArray.lastObject as Int) - 1)
                countArray      = [firstValue, secondValue]
            }
        }
        
        GSCustomLeague.joinCurrentUserToCustomLeague(customLeague)
        GSCustomLeague.getAllPublicCustomLeagues(self)
        
        
        
        if(countArray != nil && countArray.count > 0){
            var publicCount = countArray.firstObject as Int
            if(publicCount > 0){
                publicNumber.text = String(publicCount)
                publicNumber.hidden = false
            }
            else{
                publicNumber.hidden = true
            }
        }
        
        if(countArray != nil && countArray.count > 0){
            var privateCount = countArray.lastObject as Int
            if(privateCount > 0){
                privateNumber.text = String(privateCount)
                privateNumber.hidden = false
            }
            else{
                privateNumber.hidden = true
            }
        }
    }
    
    
    
}
