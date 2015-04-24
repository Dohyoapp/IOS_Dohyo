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

class GSLeague: NSObject {

    var pfLeague: PFObject
    var matches: NSArray!
    
    init(league: PFObject) {
        pfLeague = league
    }

    
    func getMatchesLeague(){
        
        SVProgressHUD.show()
        
        var relation:PFRelation = pfLeague.relationForKey("events")
        relation.query().limit = 1000
        relation.query().findObjectsInBackgroundWithBlock{ (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if error != nil {
                
            } else {
                
                var events:NSArray! = objects
                
                if(events != nil){
                    
                    var matches = NSMutableArray()
                    for event in events {
                        var title = event.valueForKey("title") as! String
                        if(title.componentsSeparatedByString("V").count > 1){
                            matches.addObject(event)
                        }
                    }
                    
                    if(matches.count > 1){
                        
                        var sortedArray = sorted(matches) { (obj1, obj2) in
                            
                            var p1 = GSCustomLeague.getDateMatche(obj1 as! PFObject)
                            var p2 = GSCustomLeague.getDateMatche(obj2 as! PFObject)
                            return p1.timeIntervalSinceDate(p2) < 0
                        }
                        self.matches = sortedArray
                    }
                    
                }
                
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    


    
    class func getLeagues(delegate: LeagueCaller){

            if( !Utils.isParseNull(PFUser.currentUser()["email"]) ){
                SVProgressHUD.show()
            }
            var query = PFQuery(className:"League")
            //PFObject.pinAllInBackground(query.findObjects())
            //query.fromLocalDatastore()
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                SVProgressHUD.dismiss()
                if (error != nil) {
                    
                    SVProgressHUD.dismiss()
                    delegate.endGetLeagues!([])
                }
                else{
                    cacheLeagues = NSMutableArray()
                    
                    for league in objects{
                        var gsLeague = GSLeague(league:league as! PFObject)
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
        
        if(cacheLeagues == nil || cacheLeagues.count < 1){
            return GSLeague(league: PFObject())
        }
        
        for league in cacheLeagues{
            
            var leagueName = (league as! GSLeague).pfLeague.valueForKey("title") as! String
            if(leagueName == nameLeague){
                
                if((league as! GSLeague).matches == nil){
                    (league as! GSLeague).getMatchesLeague()
                }
                return (league as! GSLeague)
            }
            
        }
        
        return cacheLeagues.firstObject as! GSLeague
    }
    
    
    
    
    class func getMatchResults(delegate: LeagueCaller){
        
        var query = PFQuery(className:"MatchResult")
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (!Utils.isParseNull(error) ) {
                
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
            
            var matcheDateString:NSString = (matcheResult as! PFObject) ["date"] as! String
            var matcheDate:NSDate = dateFormatter.dateFromString(matcheDateString as String)!
            
            if(matcheDate.timeIntervalSinceDate(startCustomLeagueDate) > -24*3600){
                
                myResults.addObject(matcheResult)
            }
        }
        return myResults
    }
}