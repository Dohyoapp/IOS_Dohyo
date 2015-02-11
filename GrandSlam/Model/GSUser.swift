//
//  Classe.swift
//  GrandSlam
//
//  Created by Explocial 6 on 22/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

var userMapping:RKObjectMapping!

class GSUser:NSObject{
    
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
                    
                    var friendId:NSString = dataArray[1] as NSString
                    
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
                    query.getObjectInBackgroundWithId(dataArray[3] as NSString) {
                        (customLeague: PFObject!, error: NSError!) -> Void in
                        if error == nil {
                            GSCustomLeague.joinCurrentUserToCustomLeague(customLeague)
                        } else {
                            NSLog("%@", error)
                        }
                    }
                    
                }
 
    }
    
    
    
}

