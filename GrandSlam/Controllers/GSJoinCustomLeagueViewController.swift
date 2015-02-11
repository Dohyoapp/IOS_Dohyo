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
    var tableViewData:NSArray!
    
    
    var countArray:NSArray!
    
    let yStart = NAVIGATIONBAR_HEIGHT+20
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        var publicButton = UIButton(frame: CGRectMake(10, yStart+5, 145, 33))
        publicButton.setTitle("Public", forState: .Normal)
        publicButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        publicButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        publicButton.backgroundColor = SPECIALBLUE
        publicButton.addTarget(self, action:"publicButtonTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(publicButton)
        
        var publicNumber = UILabel(frame: CGRectMake(138, -5, 15, 15))
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
        
        
        var privateButton = UIButton(frame: CGRectMake(165, yStart+5, 145, 33))
        privateButton.setTitle("Private", forState: .Normal)
        privateButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        privateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        privateButton.backgroundColor = SPECIALBLUE
        privateButton.addTarget(self, action:"privateButtonTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(privateButton)
        
        var privateNumber = UILabel(frame: CGRectMake(138, -5, 15, 15))
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
        
        tableView.frame         = CGRectMake(0, yStart+50, self.view.frame.size.width, self.view.frame.size.height-yStart-50)
        tableView.dataSource    = self
        tableView.delegate      = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle  = .None
        self.view.addSubview(tableView)
        
        tableViewData = []
        GSCustomLeague.getAllPublicCustomLeagues(self)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        //defaults.setObject(NSDate(), forKey: "JoinViewDate")
    }
    
    func closeView(){
        
        self.view.removeFromSuperview()
    }
    
    func endGetAllPublicCustomLeagues(data : NSArray){
        
        tableViewData = data
        tableView.reloadData()
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return tableViewData.count
        }else{
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            
            var cell = tableView.dequeueReusableCellWithIdentifier("JoinCustomCell") as UITableViewCell!
            if(cell == nil){
                cell = UITableViewCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"JoinCustomCell")
                
                var joinButton = UIButton(frame: CGRectMake(265, 7, 45, 30))
                joinButton.setTitle("Join", forState: .Normal)
                joinButton.titleLabel!.font = UIFont(name:FONT3, size:15)
                joinButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                joinButton.backgroundColor = SPECIALBLUE
                joinButton.addTarget(self, action:"joinButtonTap:", forControlEvents:.TouchUpInside)
                cell.addSubview(joinButton)
            }
            
            cell.tag  = indexPath.row
            cell.selectionStyle = .None
            
            if(tableViewData.count > indexPath.row){
                var data: AnyObject? = tableViewData[indexPath.row] as AnyObject
                if(data != nil){
                    var customLeague = tableViewData[indexPath.row] as PFObject
                    cell.textLabel.text = customLeague["name"] as NSString
                }
            }
            
            return cell
        }
        
        var cell = UITableViewCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"OldCustomCell")
        return cell
    }
    
    func publicButtonTap(sender: UIButton!){
        
    }
    
    func privateButtonTap(sender: UIButton!){
        
    }
    
    func joinButtonTap(sender: UIButton!){
        
        var cell = (sender as UIView).superview!
        var num = cell.tag
        var customLeague = tableViewData[num] as PFObject
        
        GSCustomLeague.joinCurrentUserToCustomLeague(customLeague)
    }
    
    
    
}
