//
//  Classe.swift
//  GrandSlam
//
//  Created by Explocial 6 on 22/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


@objc protocol UserCaller {
    optional func endGetUserBetSlips()
}



var userMapping:RKObjectMapping!

var cacheBetSlipsUser:NSMutableDictionary!



class GSUser:NSObject, UserCaller{
    
    var name    :NSString!
    var email   :NSString!
    var passWord:NSString!
    
    
    class func addMappingObject(objectManager : RKObjectManager){
        
        userMapping = RKObjectMapping(forClass: GSUser.self)
        userMapping.addAttributeMappingsFromArray(["name", "email", "passWord"])
        
        let responseDescriptor = RKResponseDescriptor(mapping: userMapping, method: RKRequestMethod.POST, pathPattern: "v1/customer-api/customers/auth", keyPath: nil, statusCodes: NSIndexSet(index: 200))
        
        objectManager.addResponseDescriptor(responseDescriptor)
        
        let responseDescriptorClasses = RKResponseDescriptor(mapping: RKObjectMapping(forClass: NSDictionary.self), method: RKRequestMethod.GET, pathPattern: "v2/sportsbook-api/classes", keyPath: nil, statusCodes: NSIndexSet(index: 200))
        
        objectManager.addResponseDescriptor(responseDescriptorClasses)
    }
    
    class func getUserMapping() -> RKObjectMapping{
        
        return userMapping
    }
    
    class func autho(objectManager : RKObjectManager){
        
        objectManager.HTTPClient.setDefaultHeader("Authorization", value:"Basic ".stringByAppendingString(LADBROKES_API_KEY))
        objectManager.HTTPClient.setDefaultHeader("grantType", value:"refresh_token")
        
        
        let parameters =
        [
            "locale"    : "en-GB",
            "api-key"   : LADBROKES_API_KEY,
            "grantType" : "refresh_token"
            
        ];
        objectManager.postObject(nil, path:"v1/customer-api/customers/auth", parameters:parameters, success: { (operation, RKMappingResult) in
            
            var i = 0
            
            },
            failure: { (operation, error) in
                var j = 0
        })
    }
    
    
    class func getClasses(objectManager : RKObjectManager){
        
        let parameters =
        [
            "locale"    : "en-GB",
            "api-key"   : LADBROKES_API_KEY,
        ];
        objectManager.getObject(nil, path:"v2/sportsbook-api/classes", parameters:parameters, success: { (operation, RKMappingResult) in
            
            var i = 0
            
            },
            failure: { (operation, error) in
                var j = 0
        })
    }
    
    
    
    class func parseUrl(url: NSString){

                
                var dataArray = url.componentsSeparatedByString("/") as NSArray
    
                if(dataArray.count > 3){
                    
                    var friendId:NSString   = dataArray[1] as NSString
                    var customLeagueId      = dataArray[3] as NSString
                    
                    var user = PFUser.currentUser()
                    
                    if(user["email"] != nil){
                        
                        if(user.objectId as NSString != friendId){
                            self.addInvitation(friendId, customLeagueId:customLeagueId)
                        }
                    }
                    else{
                        
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject([friendId, customLeagueId], forKey: "pendingInvitation")
                    }
                    
                }
 
    }
    
    class func addInvitation(friendId: NSString, customLeagueId: NSString){
        
        var friends: AnyObject! = PFUser.currentUser()["friends"]
        if(friends == nil){
            friends = NSMutableArray()
        }
        if( !(friends as NSArray).containsObject(friendId) ){
            friends.addObject(friendId)
        }
        PFUser.currentUser()["friends"] = friends
        PFUser.currentUser().saveInBackground()
        
        var query = PFQuery(className:"CustomLeague")
        query.getObjectInBackgroundWithId(customLeagueId) {
            (customLeague: PFObject!, error: NSError!) -> Void in
            if error == nil {
                GSCustomLeague.joinCurrentUserToCustomLeague(customLeague)
            } else {
                NSLog("%@", error)
            }
        }
    }
    
    
    class func pendingInvitations() {
    
        var user = PFUser.currentUser()
        
        if(user["email"] != nil){
            
            let defaults = NSUserDefaults.standardUserDefaults()
            var data: AnyObject? = defaults.objectForKey("pendingInvitation")
        
            if(data != nil && (data as NSArray).count > 0){
                var friendId: NSString = (data as NSArray).firstObject as NSString
                var customLeagueId: NSString = (data as NSArray).lastObject as NSString
                
                if(user.objectId as NSString != friendId){
                    self.addInvitation(friendId, customLeagueId:customLeagueId)
                    defaults.removeObjectForKey("pendingInvitation")
                }
            }
        }
    }
    
    
    
    
    class func saveLastJoinViewDate(){
        
        var user = PFUser.currentUser()
        
        var lastDate: AnyObject! = user["LastJoinViewDate"]

        if(lastDate != nil){
            if( NSDate().timeIntervalSinceDate(lastDate as NSDate) > 3600*24 ){
                user["LastJoinViewDate"] = NSDate()
                user.save()
            }
        }
        else{
            
            user["LastJoinViewDate"] = NSDate()
            user.save()
        }
    }
    
    
    
    
    class func loadUserBetSlips(user : PFObject, delegate : UserCaller){
        
        var relation = user.relationForKey("betSlips")
        relation.query().limit = 1000
        relation.query().findObjectsInBackgroundWithBlock {    (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if(objects != nil){
                
                cacheBetSlipsUser = NSMutableDictionary ()
                
                cacheBetSlipsUser.setObject(objects, forKey: "bets")
                cacheBetSlipsUser.setObject(user.objectId , forKey: "userId")
            }
            delegate.endGetUserBetSlips!()
        }
    }
    
    
    
    
    class func getUserBetSlips(user : PFObject) -> NSArray{
        
        if(cacheBetSlipsUser == nil){
            loadUserBetSlips(user, delegate: GSUser())
            return []
        }
        else{
            
            var userId = cacheBetSlipsUser.objectForKey("userId") as NSString
            if(userId != user.objectId){
                loadUserBetSlips(user, delegate: GSUser())
                return []
            }
        }
        
        return cacheBetSlipsUser.objectForKey("bets") as NSArray
    }
    
    func endGetUserBetSlips(){
        
    }
    
}

