//
//  GSLeague.swift
//  GrandSlam
//
//  Created by Explocial 6 on 06/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


@objc protocol LeagueCaller {
    optional func endGetLeagues(data : NSArray)
    optional func endGetMatchResults(data : NSArray)
}


var cacheLeagues:NSMutableArray!
var cacheMatchResults:NSArray!

class GSLeague {

    var pfLeague: PFObject
    var matches: NSArray!
    
    init(league: PFObject) {
        pfLeague = league
    }

    
    func getMatchesLeague(){
        
        var relation:PFRelation = pfLeague.relationForKey("events")
        relation.query().limit = 1000
        relation.query().findObjectsInBackgroundWithBlock{ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                
            } else {
                var events:NSArray = objects
                
                var matches = NSMutableArray()
                for event in events {
                    var title = event.valueForKey("title") as NSString
                    if(title.componentsSeparatedByString("V").count > 1){
                        matches.addObject(event)
                    }
                }
                
                var sortedArray = sorted(matches) { (obj1, obj2) in
                    
                    let p1 = GSCustomLeague.getDateMatche(obj1 as PFObject)
                    let p2 = GSCustomLeague.getDateMatche(obj2 as PFObject)
                    return p1.timeIntervalSinceDate(p2) < 0
                }
                
                self.matches = sortedArray
            }
        }
    }
    
    
    
    class func getLeagues(delegate: LeagueCaller){

            if(PFUser.currentUser().valueForKey("email") != nil){
                SVProgressHUD.show()
            }
            var query = PFQuery(className:"League")
            PFObject.pinAllInBackground(query.findObjects())
            query.fromLocalDatastore()
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                SVProgressHUD.dismiss()
                if (error != nil) {
                    
                    SVProgressHUD.dismiss()
                    delegate.endGetLeagues!([])
                }
                else{
                    cacheLeagues = NSMutableArray()
                    
                    for league in objects{
                        var gsLeague = GSLeague(league:league as PFObject)
                        gsLeague.getMatchesLeague()
                        cacheLeagues.addObject( gsLeague )
                    }
                    
                    delegate.endGetLeagues!(objects)
                }
            }
    }
    
    
    class func getCacheLeagues() -> NSMutableArray!{
        return cacheLeagues
    }
    

    class func getLeagueFromCache(nameLeague: NSString) -> GSLeague{
        
        var league:GSLeague!
        for league in cacheLeagues{
            
            var leagueName = (league as GSLeague).pfLeague.valueForKey("title") as NSString
            if(leagueName == nameLeague){
                
                if(league.matches == nil){
                    (league as GSLeague).getMatchesLeague()
                }
                return (league as GSLeague)
            }
            
        }
        return league
    }
    
    
    
    
    class func getMatchResults(delegate: LeagueCaller){
        
        var query = PFQuery(className:"MatchResult")
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error != nil) {
                
            }
            else{
                cacheMatchResults = objects
            }
        }
    }
    
    class func getCacheMatchResultsFromDate(startCustomLeagueDate : NSDate) -> NSMutableArray{
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        
        
        var myResults:NSMutableArray = NSMutableArray()
        for matcheResult in cacheMatchResults{
            
            var matcheDateString:NSString = (matcheResult as PFObject) ["date"] as NSString
            var matcheDate:NSDate = dateFormatter.dateFromString(matcheDateString)!
            
            if(matcheDate.timeIntervalSinceDate(startCustomLeagueDate) > -24*3600){
                
                myResults.addObject(matcheResult)
            }
        }
        return myResults
    }
}