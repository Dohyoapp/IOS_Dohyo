//
//  GSCustomLeagues.swift
//  GrandSlam
//
//  Created by Explocial 6 on 02/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


@objc protocol CustomLeagueCaller {
    optional func endGetCustomLeagues(data : NSArray)
    optional func endGetAllPublicCustomLeagues (data : NSArray)
}

var myDict:NSDictionary = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("TeamsShortCut", ofType: "plist")!)!

var dateFormatter = NSDateFormatter()


var cacheCustomLeaguesArray:NSMutableArray!

class GSCustomLeague: NSObject {
    
    
    var pfCustomLeague: PFObject
    var cluMatches: NSArray!
    
    
    init(customLeague: PFObject) {
        pfCustomLeague = customLeague
    }

    
    class func getNewJoinLeagueNumber(){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        //defaults.removeObjectForKey("JoinViewDate")
        var date: AnyObject! = defaults.objectForKey("JoinViewDate")
        if(date == nil){
            return
        }
            
        PFCloud.callFunctionInBackground("NewJoinLeagueNumber", withParameters:["JoinViewDate" : date as NSDate]) { (result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                GSMainViewController.getMainViewControllerInstance().refreshJoinCount(result as NSArray)
            }
        }
    }

    class func getCustomLeagues(delegate: CustomLeagueCaller, user: PFUser){
        
        var email: AnyObject? = PFUser.currentUser().valueForKey("email")
        if(email == nil){
            self.cacheCustomLeagues([])
            delegate.endGetCustomLeagues!([])
        }
        
        var relation = user.relationForKey("myCustomLeagues")
        relation.query().findObjectsInBackgroundWithBlock {    (objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                self.cacheCustomLeagues([])
                delegate.endGetCustomLeagues!([])
            } else {
                
                var orrderArray = NSMutableArray()
                var otherArray = NSMutableArray()
                for customLeague in objects as NSArray{
                    
                    if(customLeague["mainUser"] as NSString == PFUser.currentUser().objectId){
                        orrderArray.addObject(customLeague)
                    }else{
                        otherArray.addObject(customLeague)
                    }
                }
                orrderArray.addObjectsFromArray(otherArray)
                
                self.cacheCustomLeagues(orrderArray)
                delegate.endGetCustomLeagues!(orrderArray)
            }
        }
        
    }
    
    class func cacheCustomLeagues(objects : NSArray){

        cacheCustomLeaguesArray = NSMutableArray()
        for object in objects{
            var customLeague = GSCustomLeague(customLeague:object as PFObject)
            customLeague.getCluMatches()
            cacheCustomLeaguesArray.addObject(customLeague)
        }
    }
    
    class func getCacheCustomLeagues() -> NSArray{
        return cacheCustomLeaguesArray
    }
    
    func getCluMatches(){

        var relation = pfCustomLeague.relationForKey("lcuMatches")
        relation.query().findObjectsInBackgroundWithBlock {    (objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                self.cluMatches = []
            } else {
                
                var data = NSMutableArray()
                for clusMatche in objects as NSArray{
                    
                    if(clusMatche["userId"] as NSString == PFUser.currentUser().objectId){
                        data.addObject(clusMatche)
                    }
                }
                self.cluMatches = data
            }
        }
    }
    
    
    
    func getMatcheScore(matcheId: NSString) -> NSString{
        
        for matche in cluMatches{
            
            if(matche["matcheId"] as NSString == matcheId){
               return matche["savePScore"] as NSString
            }
        }
        return ""
    }
    
    

    
    func getMatchesByNumber(matches:NSArray, customLeague:PFObject) -> NSArray{
        
        var numberOfMatches:NSString = customLeague["numberOfMatches"] as NSString
        var number:Int = Int(numberOfMatches.intValue)
        var startCustomLeagueDate:NSDate = customLeague["startDate"] as NSDate

        var count = 0
        var validMatches = NSMutableArray()
        for matche in matches{
            
            var matcheDate = GSCustomLeague.getDateMatche(matche as PFObject)
            if(matcheDate.timeIntervalSinceDate(startCustomLeagueDate) >= 0 && count < number){
                validMatches.addObject(matche)
                count = count+1
            }
        }
        return validMatches
    }
    
    
    func getMatchesByDate(matches:NSArray, customLeague:PFObject) -> NSArray{
        
        var startCustomLeagueDate:NSDate    = customLeague["startDate"] as NSDate
        var endCustomLeagueDate:NSDate      = customLeague["endDate"] as NSDate
        
        var validMatches = NSMutableArray()
        for matche in matches{
            
            var matcheDate = GSCustomLeague.getDateMatche(matche as PFObject)
            if(matcheDate.timeIntervalSinceDate(startCustomLeagueDate) >= 0 && matcheDate.timeIntervalSinceDate(endCustomLeagueDate) <= 0 ){
                validMatches.addObject(matche)
            }
        }
        return validMatches
    }
    
    
    func getValidMatches(matches:NSArray) -> NSArray{
        
        var numberOfMatches:NSString = pfCustomLeague["numberOfMatches"] as NSString
        
        if(numberOfMatches != "" && numberOfMatches != "0"){
            return self.getMatchesByNumber(matches, customLeague:pfCustomLeague)
        }
        
        if(!(pfCustomLeague["endOfSeason"] as Bool)){
            return self.getMatchesByDate(matches, customLeague:pfCustomLeague)
        }
        
        return matches
    }
    
    
    
    
    
    
    
    
    
    
    
    class func joinCurrentUserToCustomLeague(toCustomLeague: PFObject){
        
        SVProgressHUD.show()
        
        var joinedUsers: AnyObject! = toCustomLeague["joinUsers"]
        if(joinedUsers == nil){
            joinedUsers = NSMutableArray()
        }
        if( !(joinedUsers as NSArray).containsObject(PFUser.currentUser().objectId) ){
            joinedUsers.addObject(PFUser.currentUser().objectId)
        }
        toCustomLeague["joinUsers"] = joinedUsers
        toCustomLeague.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            var relation = PFUser.currentUser().relationForKey("myCustomLeagues")
            relation.addObject(toCustomLeague)
            PFUser.currentUser().saveInBackgroundWithBlock { (success, error) -> Void in
                
                SVProgressHUD.dismiss()
                GSMainViewController.getMainViewControllerInstance().getCustomLeagues()
            }
        })
    }
    
    
    
    class func getDateMatche(matche:PFObject) -> NSDate{
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var matcheDateString:NSString = matche["eventDateTime"] as NSString
        matcheDateString = matcheDateString.stringByReplacingOccurrencesOfString("T", withString: " ")
        matcheDateString = matcheDateString.stringByReplacingOccurrencesOfString("Z", withString: "")
        return dateFormatter.dateFromString(matcheDateString)!
    }
    
    
    
    
    
    class func getShortTitle(longTitle:NSString) -> NSArray{
        
        var names:NSArray       = longTitle.componentsSeparatedByString(" V ")
        var leftName:NSString   = names.firstObject as NSString
        var rightName:NSString  = names.lastObject as NSString
        leftName    = leftName.stringByReplacingOccurrencesOfString(" ", withString: "")
        rightName   = rightName.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if( myDict.objectForKey(leftName) != nil ){
            leftName = myDict.objectForKey(leftName) as NSString
        }
        if( myDict.objectForKey(rightName) != nil ){
            rightName = myDict.objectForKey(rightName) as NSString
        }
        
        return [leftName, rightName]
    }
    
    
    
    
    
    class func getAllPublicCustomLeagues(delegate: CustomLeagueCaller){
        
        var email: AnyObject? = PFUser.currentUser().valueForKey("email")
        if(email == nil){
            return
        }

        var query = PFQuery(className:"CustomLeague")
        query.whereKey("public", equalTo:true)
        query.whereKey("mainUser", notEqualTo:PFUser.currentUser().objectId)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            SVProgressHUD.dismiss()
            if (error != nil) {
                delegate.endGetAllPublicCustomLeagues!([])
            }
            else{
                
                var data = NSMutableArray()
                for customLeague in objects{
                    
                    var currentUserJoined = false
                    
                    var joinedUsers = customLeague["joinUsers"]
                    if(joinedUsers? != nil){
                        for userId in joinedUsers as NSArray{
                            
                            if(userId as NSString == PFUser.currentUser().objectId){
                                currentUserJoined = true
                            }
                        }
                    }
                    if(!currentUserJoined){
                        data.addObject(customLeague)
                    }
                }
                delegate.endGetAllPublicCustomLeagues!(data)
            }
        }

    }
    
}