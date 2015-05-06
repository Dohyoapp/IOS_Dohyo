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

var teamsDict:NSDictionary = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("TeamsShortCut", ofType: "plist")!)!

var dateFormatter = NSDateFormatter()


var cacheCustomLeaguesArray:NSMutableArray!


var isAllPublicCustomLeaguesLoading = false
var isAllPrivateCustomLeagues = false
var isNewJoinLeagueNumber = false


class GSCustomLeague: NSObject {
    
    
    var pfCustomLeague: PFObject
    var cluMatches: NSArray!
    var league: GSLeague!
    
    var isLeagueEnded = false
    
    
    init(customLeague: PFObject) {
        pfCustomLeague = customLeague
        
        if(GSLeague.getCacheLeagues() != nil){
            
            league = GSLeague.getLeagueFromCache(customLeague["leagueTitle"] as! String)
        }
    }
    
    

    
    class func getNewJoinLeagueNumber(){
        
        if( !Utils.isParseNull(PFUser.currentUser()["email"] ) ){
            PFUser.currentUser().fetchIfNeeded()
        }
        
        if(isNewJoinLeagueNumber == true){
            return
        }
        
        isNewJoinLeagueNumber = true
        // params: ["JoinViewDate" : date as NSDate]
        PFCloud.callFunctionInBackground("NewJoinLeagueNumber", withParameters:[:]) { (result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                GSMainViewController.getMainViewControllerInstance().refreshJoinCount(result as! NSArray)
            }
            isNewJoinLeagueNumber = false
        }
    }

    class func getCustomLeagues(delegate: CustomLeagueCaller, user: PFUser){
        
        var user = PFUser.currentUser()
        
        if( Utils.isParseNull(user["email"]) ){
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
                    
                    if(customLeague["mainUser"] as! String == user.objectId){
                        orrderArray.addObject(customLeague)
                    }else{
                        otherArray.addObject(customLeague)
                    }
                }
                orrderArray.addObjectsFromArray(otherArray as [AnyObject])
                
                self.cacheCustomLeagues(orrderArray)
                delegate.endGetCustomLeagues!(orrderArray)
            }
        }
        
    }
    
    
    class func cacheCustomLeagues(objects : NSArray){

        cacheCustomLeaguesArray = NSMutableArray()
        for object in objects{
            var customLeague = GSCustomLeague(customLeague:object as! PFObject)
           // customLeague.getCluMatches()
            cacheCustomLeaguesArray.addObject(customLeague)
        }
    }
    
    class func getCacheCustomLeagues() -> NSArray{
        return cacheCustomLeaguesArray
    }
    

    
    func getMatchesByNumber(matches:NSArray, customLeague:PFObject) -> NSArray{
        
        var numberOfMatches:String = customLeague["numberOfMatches"] as! String
        var number:Int = numberOfMatches.toInt()!
        var startCustomLeagueDate:NSDate = customLeague["startDate"] as! NSDate

        var count = 0
        var validMatches = NSMutableArray()
        for matche in matches{
            
            var matcheDate = GSCustomLeague.getDateMatche(matche as! PFObject)
            if(matcheDate.timeIntervalSinceDate(startCustomLeagueDate) >= 0 && count < number){
                validMatches.addObject(matche)
                count = count+1
            }
        }
        return validMatches
    }
    
    
    func getMatchesByDate(matches:NSArray, customLeague:PFObject) -> NSArray{
        
        var startCustomLeagueDate:NSDate    = customLeague["startDate"] as! NSDate
        var endCustomLeagueDate:NSDate      = customLeague["endDate"] as! NSDate
        
        var validMatches = NSMutableArray()
        for matche in matches{
            
            var matcheDate = GSCustomLeague.getDateMatche(matche as! PFObject)
            if(matcheDate.timeIntervalSinceDate(startCustomLeagueDate) >= 0 && matcheDate.timeIntervalSinceDate(endCustomLeagueDate) <= 0 ){
                validMatches.addObject(matche)
            }
        }
        return validMatches
    }
    
    
    func getValidMatches(matches:NSArray) -> NSArray{
        
        var returnArray:NSArray = matches
        
        var numberOfMatches:String = pfCustomLeague["numberOfMatches"] as! String
        
        
        if(numberOfMatches != "" && numberOfMatches != "0"){
            returnArray = self.getMatchesByNumber(matches, customLeague:pfCustomLeague)
        }
        else if(!(pfCustomLeague["endOfSeason"] as! Bool)){
            returnArray = self.getMatchesByDate(matches, customLeague:pfCustomLeague)
        }
        
        var oldMatches = NSMutableArray()
        var newMatches = NSMutableArray()
        for matche in returnArray{
            var matcheDate = GSCustomLeague.getDateMatche(matche as! PFObject)
            if(matcheDate.timeIntervalSinceDate(NSDate()) < 0){
                oldMatches.addObject(matche)
            }
            else{
                newMatches.addObject(matche)
            }
        }
        
        
        if(numberOfMatches != "" && numberOfMatches != "0"){
            
            if(returnArray.count >= numberOfMatches.toInt() && newMatches.count == 0){
                self.isLeagueEnded = true
            }
        }
        else if(!(pfCustomLeague["endOfSeason"] as! Bool) && NSDate().timeIntervalSinceDate(pfCustomLeague["endDate"] as! NSDate) >= 0){
            self.isLeagueEnded = true
        }
        
        if(!Utils.isParseNull(league)){
            var weekArray = NSMutableArray()
            for matche in newMatches{
                var matcheDate = GSCustomLeague.getDateMatche(matche as! PFObject)
                if(matcheDate.timeIntervalSinceDate(league.weekDateEnd) < 0){
                    weekArray.addObject(matche)
                }
            }
            
            if(weekArray.count > 0) {
                return weekArray
            }
        }
        return newMatches//.arrayByAddingObjectsFromArray(oldMatches)
    }
    
    
    
    
    
    
    func hasBetSlip () -> NSArray!{
        
        var customLeagueBetSlips = NSMutableArray()
        var userBetSlips = GSUser.getUserBetSlips(PFUser.currentUser())
        for betSlip in userBetSlips{
            
            if((betSlip as! PFObject)["customLeagueId"] as! String == self.pfCustomLeague.objectId){
                customLeagueBetSlips.addObject(betSlip)
            }
        }
        
        var sortedArray = sorted(customLeagueBetSlips) { (obj1, obj2) in
            
            var p1 = (obj1 as! PFObject).createdAt
            var p2 = (obj2 as! PFObject).createdAt
            return p1.timeIntervalSinceDate(p2) > 0
        }
        
        var currentBetSlip: AnyObject!
        if(sortedArray.count > 0){
            currentBetSlip = sortedArray[0]
        }
        var result = NSMutableArray()
        if(currentBetSlip != nil){
            
            var bets: NSArray = (currentBetSlip as! PFObject)["bets"] as! NSArray
            for bet in bets{
                
                var matchId = (bet as! NSDictionary).objectForKey("matchId") as! String
                var selection = (bet as! NSDictionary).objectForKey("selection") as! NSDictionary
                var score = (bet as! NSDictionary).objectForKey("score") as! String
                var betSlip = GSBetSlip(aMatchId: matchId, aSelection: selection, aScore: score)
                result.addObject(betSlip)
            }
        }
        
        //step 2 check if all matches are past
        if( !Utils.isParseNull(league) && league.matches != nil){
            
            var numberOldBets = 0
            var tempMatches:NSArray = GSBetSlip.getbetMatches(league, bets: result)
            for matche in tempMatches{
                
                var matcheDate = GSCustomLeague.getDateMatche(matche as! PFObject)
                if(matcheDate.timeIntervalSinceDate(NSDate()) < 0){
                    numberOldBets += 1
                }
            }
            if(numberOldBets == result.count){
                return []
            }
        }
        
        return result
    }
    
    
    
    
    
    
    
    class func joinCurrentUserToCustomLeague(toCustomLeague: PFObject){
        
        SVProgressHUD.show()
        
        var user = PFUser.currentUser()
        
        var joinedUsers: AnyObject! = toCustomLeague["joinUsers"]
        if( Utils.isParseNull(joinedUsers) ){
            joinedUsers = NSMutableArray()
        }
        if( !(joinedUsers as! NSArray).containsObject(user.objectId) ){
            joinedUsers.addObject(user.objectId)
        }
        toCustomLeague["joinUsers"] = joinedUsers
        toCustomLeague.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            if( Utils.isParseNull(error) ){
                
                var relation = user.relationForKey("myCustomLeagues")
                relation.addObject(toCustomLeague)
                user.saveInBackgroundWithBlock { (success, error) -> Void in
                    
                    if( Utils.isParseNull(error) ){
                        SVProgressHUD.dismiss()
                        GSMainViewController.getMainViewControllerInstance().getCustomLeagues(false, joinedLeague:toCustomLeague)
                        
                        var publicLeague:Bool = toCustomLeague["public"] as! Bool
                        if(publicLeague){
                            Mixpanel.sharedInstance().track("0204 - join a public league")
                        }
                        else{
                            Mixpanel.sharedInstance().track("0205 - join a private league")
                        }
                    }
                    else{
                        Mixpanel.sharedInstance().track("0206 - join a league error")
                    }
                }
            }
            else{
                Mixpanel.sharedInstance().track("0206 - join a league error")
            }
        })
    }
    
    
    
    class func getDateMatche(matche:PFObject) -> NSDate{
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var matcheDateString:NSString = matche["eventDateTime"] as! String
        matcheDateString = matcheDateString.stringByReplacingOccurrencesOfString("T", withString: " ")
        matcheDateString = matcheDateString.stringByReplacingOccurrencesOfString("Z", withString: "")

        if let parsedDateTimeString = dateFormatter.dateFromString(matcheDateString as String) {
            return parsedDateTimeString
        } else {
            return NSDate()
        }
    }
    
    
    
    
    
    class func getShortTitle(longTitle:NSString) -> NSArray{
        
        var names:NSArray       = longTitle.componentsSeparatedByString(" V ")
        var leftName    = self.getShortNameTeam(names.firstObject as! String)
        var rightName   = self.getShortNameTeam(names.lastObject as! String)
        
        return [leftName, rightName]
    }
    
    
    class func getShortNameTeam(teamName:NSString) -> NSString{
        
        var shortTeamtName    = teamName.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if( teamsDict.objectForKey(shortTeamtName) != nil ){
            shortTeamtName = teamsDict.objectForKey(shortTeamtName) as! String
        }
        
        return shortTeamtName
    }
    
    
    
    
    
    class func getAllPublicCustomLeagues(delegate: CustomLeagueCaller){
        
        var user = PFUser.currentUser()
        
        if( Utils.isParseNull(user["email"]) || isAllPublicCustomLeaguesLoading == true){
            return
        }
        
        isAllPublicCustomLeaguesLoading = true

        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.show()
            })
        var query = PFQuery(className:"CustomLeague")
        query.limit = 1000
        query.whereKey("public", equalTo:true)
        query.whereKey("mainUser", notEqualTo:user.objectId)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                SVProgressHUD.dismiss()
                })
            if ( !Utils.isParseNull(error)) {
                isAllPublicCustomLeaguesLoading = false
                delegate.endGetAllPublicCustomLeagues!(self.splitCustomLeagueByDate([]))
            }
            else{
                
                var data = NSMutableArray()
                for customLeague in objects{
                    
                    var currentUserJoined = false
                    
                    var joinedUsers = customLeague["joinUsers"]
                    if(!Utils.isParseNull(joinedUsers)){
                        for userId in (joinedUsers as! NSArray){
                            
                            if(userId as! String == user.objectId){
                                currentUserJoined = true
                            }
                        }
                    }
                    if(!currentUserJoined){
                        data.addObject(customLeague)
                    }
                }
                isAllPublicCustomLeaguesLoading = false
                delegate.endGetAllPublicCustomLeagues!(self.splitCustomLeagueByDate(data))
            }
        }

    }
    
    
    class func getAllPrivateCustomLeagues(delegate: CustomLeagueCaller){
        
        var user = PFUser.currentUser()
        
        if( Utils.isParseNull(user["email"]) || isAllPrivateCustomLeagues == true){
            return
        }
        
        isAllPrivateCustomLeagues = true
        
        SVProgressHUD.show()
        var query = PFQuery(className:"CustomLeague")
        query.limit = 1000
        query.whereKey("public", equalTo:false)
        query.whereKey("mainUser", notEqualTo:user.objectId)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            SVProgressHUD.dismiss()
            if (!Utils.isParseNull(error)) {
                isAllPrivateCustomLeagues = false
                delegate.endGetAllPrivateCustomLeagues!(self.splitCustomLeagueByDate([]))
            }
            else{
                
                var data = NSMutableArray()
                for customLeague in objects{
                    
                    var currentUserJoined = false
                    
                    var joinedUsers = customLeague["joinUsers"]
                    if(!Utils.isParseNull(joinedUsers)){
                        for userId in joinedUsers as! NSArray{
                            
                            if(userId as! String == user.objectId){
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

                    if( !Utils.isParseNull(user["friends"])){
                        
                        for friendId in (user["friends"] as! NSArray){
                            var mainUser = customLeague2["mainUser"] as! String
                            if(friendId as! String == mainUser){
                                finalData.addObject(customLeague2)
                            }
                        }
                    }
                }
                
                isAllPrivateCustomLeagues = false
                delegate.endGetAllPrivateCustomLeagues!(self.splitCustomLeagueByDate(finalData))
            }
        }
        
    }
    
    
    class func splitCustomLeagueByDate(data : NSArray) -> NSArray{
        
        var user = PFUser.currentUser()
        
        var lastDate: AnyObject! = user["LastJoinViewDate"]
        
        var arrayNew = NSMutableArray()
        var arrayOld = NSMutableArray()
        
        if(!Utils.isParseNull(lastDate) ){
            
            for customLeague in data{
                
                var createdAt: AnyObject! = (customLeague as! PFObject).createdAt
                if( !Utils.isParseNull(createdAt) ){
                    
                    var ceatedAtDate = createdAt as! NSDate
                    var lastUserDate = lastDate as! NSDate
                    if( ceatedAtDate.timeIntervalSinceDate(lastUserDate) > 0 ){
                        
                        arrayNew.addObject(customLeague)
                    }
                    else{
                        arrayOld.addObject(customLeague)
                    }
                }
            }
            
        }else{
            arrayOld = data as! NSMutableArray
        }
        
        return [arrayNew, arrayOld]
    }
    
}