//
//  GSCustomLeagues.swift
//  GrandSlam
//
//  Created by Explocial 6 on 02/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


protocol CustomLeagueCaller {
    func endGetCustomLeagues(data : NSArray)
}

var myDict:NSDictionary = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("TeamsShortCut", ofType: "plist")!)!

var dateFormatter = NSDateFormatter()


class GSCustomLeagues: NSObject {
    

    class func getCustomLeagues(object: CustomLeagueCaller, user: PFUser){
        /*
        var query = PFQuery(className:"CustomLeague")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if (error != nil) {
                object.endGetCustomLeagues([])
            }
            else{
                object.endGetCustomLeagues(objects)
            }
        }*/
        PFCloud.callFunctionInBackground("getCustomLeagues", withParameters:[:]) { (result: AnyObject!, error: NSError!) -> Void in
            if error == nil {
                
                object.endGetCustomLeagues(result as NSArray)
            }
            else{
                object.endGetCustomLeagues([])
            }
        }
    }
    
    
    class func getMatchesByNumber(matches:NSArray, customLeague:PFObject) -> NSArray{
        
        var numberOfMatches:NSString = customLeague["numberOfMatches"] as NSString
        var number:Int = Int(numberOfMatches.intValue)
        var startCustomLeagueDate:NSDate = customLeague["startDate"] as NSDate

        var count = 0
        var validMatches = NSMutableArray()
        for matche in matches{
            
            var matcheDate = self.getDateMatche(matche as PFObject)
            if(matcheDate.timeIntervalSinceDate(startCustomLeagueDate) >= 0 && count < number){
                validMatches.addObject(matche)
                count = count+1
            }
        }
        return validMatches
    }
    
    
    class func getMatchesByDate(matches:NSArray, customLeague:PFObject) -> NSArray{
        
        var startCustomLeagueDate:NSDate    = customLeague["startDate"] as NSDate
        var endCustomLeagueDate:NSDate      = customLeague["endDate"] as NSDate
        
        var validMatches = NSMutableArray()
        for matche in matches{
            
            var matcheDate = self.getDateMatche(matche as PFObject)
            if(matcheDate.timeIntervalSinceDate(startCustomLeagueDate) >= 0 && matcheDate.timeIntervalSinceDate(endCustomLeagueDate) <= 0 ){
                validMatches.addObject(matche)
            }
        }
        return validMatches
    }
    
    
    class func getValidMatches(matches:NSArray, customLeague:PFObject) -> NSArray{
        
        var numberOfMatches:NSString = customLeague["numberOfMatches"] as NSString
        
        if(numberOfMatches != "" && numberOfMatches != "0"){
            return self.getMatchesByNumber(matches, customLeague:customLeague)
        }
        
        if(!(customLeague["endOfSeason"] as Bool)){
            return self.getMatchesByDate(matches, customLeague:customLeague)
        }
        
        return matches
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
    
    
    
    class func getDateMatche(matche:PFObject) -> NSDate{
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var matcheDateString:NSString = matche["eventDateTime"] as NSString
        matcheDateString = matcheDateString.stringByReplacingOccurrencesOfString("T", withString: " ")
        matcheDateString = matcheDateString.stringByReplacingOccurrencesOfString("Z", withString: "")
        return dateFormatter.dateFromString(matcheDateString)!
    }
    
}