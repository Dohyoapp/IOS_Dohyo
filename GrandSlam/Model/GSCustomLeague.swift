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
    optional func endGetAllPublicCustomLeagues(data : NSArray)
    optional func endGetAllPrivateCustomLeagues(data : NSArray)
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
        
        if(PFUser.currentUser().valueForKey("email") != nil){
            PFUser.currentUser().fetch()
        }
        
        // params: ["JoinViewDate" : date as NSDate]
        PFCloud.callFunctionInBackground("NewJoinLeagueNumber", withParameters:[:]) { (result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                GSMainViewController.getMainViewControllerInstance().refreshJoinCount(result as NSArray)
            }
        }
    }

    class func getCustomLeagues(delegate: CustomLeagueCaller, user: PFUser){
        
        var user = PFUser.currentUser()
        
        if(user.valueForKey("email") == nil){
            self.cacheCustomLeagues([])
            delegate.endGetCustomLeagues!([])
        }
        else{
            GSUser.getUserBetSlips(user)
        }
        
        var relation = user.relationForKey("myCustomLeagues")
        relation.query().findObjectsInBackgroundWithBlock {    (objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                SVProgressHUD.dismiss()
                self.cacheCustomLeagues([])
                delegate.endGetCustomLeagues!([])
            } else {
                
                var orrderArray = NSMutableArray()
                var otherArray = NSMutableArray()
                for customLeague in objects as NSArray{
                    
                    if(customLeague["mainUser"] as NSString == user.objectId){
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
           // customLeague.getCluMatches()
            cacheCustomLeaguesArray.addObject(customLeague)
        }
    }
    
    class func getCacheCustomLeagues() -> NSArray{
        return cacheCustomLeaguesArray
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
    
    
    
    
    
    
    func hasBetSlip () -> NSArray!{
        
        var currentBetSlip: AnyObject!
        var userBetSlips = GSUser.getUserBetSlips(PFUser.currentUser())
        for betSlip in userBetSlips{
            
            if((betSlip as PFObject)["customLeagueId"] as NSString == self.pfCustomLeague.objectId){
                currentBetSlip = betSlip
            }
        }
        
        var result = NSMutableArray()
        if(currentBetSlip != nil){
            
            var bets: NSArray = (currentBetSlip as PFObject)["bets"] as NSArray
            for bet in bets{
                
                var betSlip = GSBetSlip(aMatchId: (bet as NSDictionary).objectForKey("matchId") as NSString, aSelection: (bet as NSDictionary).objectForKey("selection") as NSDictionary)
                result.addObject(betSlip)
            }
        }
        
        return result
    }
    
    
    
    
    
    
    
    class func joinCurrentUserToCustomLeague(toCustomLeague: PFObject){
        
        SVProgressHUD.show()
        
        var user = PFUser.currentUser()
        
        var joinedUsers: AnyObject! = toCustomLeague["joinUsers"]
        if(joinedUsers == nil){
            joinedUsers = NSMutableArray()
        }
        if( !(joinedUsers as NSArray).containsObject(user.objectId) ){
            joinedUsers.addObject(user.objectId)
        }
        toCustomLeague["joinUsers"] = joinedUsers
        toCustomLeague.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            var relation = user.relationForKey("myCustomLeagues")
            relation.addObject(toCustomLeague)
            user.saveInBackgroundWithBlock { (success, error) -> Void in
                
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
        
        var user = PFUser.currentUser()
        
        if(user.valueForKey("email") == nil){
            return
        }

        SVProgressHUD.show()
        var query = PFQuery(className:"CustomLeague")
        query.limit = 1000
        query.whereKey("public", equalTo:true)
        query.whereKey("mainUser", notEqualTo:user.objectId)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            SVProgressHUD.dismiss()
            if (error != nil) {
                delegate.endGetAllPublicCustomLeagues!(self.splitCustomLeagueByDate([]))
            }
            else{
                
                var data = NSMutableArray()
                for customLeague in objects{
                    
                    var currentUserJoined = false
                    
                    var joinedUsers = customLeague["joinUsers"]
                    if(joinedUsers? != nil){
                        for userId in joinedUsers as NSArray{
                            
                            if(userId as NSString == user.objectId){
                                currentUserJoined = true
                            }
                        }
                    }
                    if(!currentUserJoined){
                        data.addObject(customLeague)
                    }
                }
                delegate.endGetAllPublicCustomLeagues!(self.splitCustomLeagueByDate(data))
            }
        }

    }
    
    
    class func getAllPrivateCustomLeagues(delegate: CustomLeagueCaller){
        
        var user = PFUser.currentUser()
        
        if(user.valueForKey("email") == nil){
            return
        }
        
        SVProgressHUD.show()
        var query = PFQuery(className:"CustomLeague")
        query.limit = 1000
        query.whereKey("public", equalTo:false)
        query.whereKey("mainUser", notEqualTo:user.objectId)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            SVProgressHUD.dismiss()
            if (error != nil) {
                delegate.endGetAllPrivateCustomLeagues!(self.splitCustomLeagueByDate([]))
            }
            else{
                
                var data = NSMutableArray()
                for customLeague in objects{
                    
                    var currentUserJoined = false
                    
                    var joinedUsers = customLeague["joinUsers"]
                    if(joinedUsers? != nil){
                        for userId in joinedUsers as NSArray{
                            
                            if(userId as NSString == user.objectId){
                                currentUserJoined = true
                            }
                        }
                    }
                    if(!currentUserJoined){
                        data.addObject(customLeague)
                    }
                }
                
                var finalData = NSMutableArray()
                for customLeague2 in data{

                    if(user["friends"] != nil){
                        for friendId in (user["friends"] as NSArray){
                            var mainUser = customLeague2["mainUser"] as NSString
                            if(friendId as NSString == mainUser){
                                finalData.addObject(customLeague2)
                            }
                        }
                    }
                }
                
                
                delegate.endGetAllPrivateCustomLeagues!(self.splitCustomLeagueByDate(finalData))
            }
        }
        
    }
    
    
    class func splitCustomLeagueByDate(data : NSArray) -> NSArray{
        
        var user = PFUser.currentUser()
        
        var lastDate: AnyObject! = user["LastJoinViewDate"]
        
        var arrayNew = NSMutableArray()
        var arrayOld = NSMutableArray()
        
        if(lastDate != nil){
            
            for customLeague in data{
                
                var createdAt: AnyObject! = (customLeague as PFObject).createdAt
                if(createdAt != nil){
                    
                    var ceatedAtDate = createdAt as NSDate
                    var lastUserDate = lastDate as NSDate
                    if( ceatedAtDate.timeIntervalSinceDate(lastUserDate) > 0 ){
                        
                        arrayNew.addObject(customLeague)
                    }
                    else{
                        arrayOld.addObject(customLeague)
                    }
                }
            }
            
        }else{
            arrayOld = data as NSMutableArray
        }
        
        return [arrayNew, arrayOld]
    }
    
}