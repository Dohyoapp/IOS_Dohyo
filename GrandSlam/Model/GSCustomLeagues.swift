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

class GSCustomLeagues: NSObject {


    class func getCustomLeagues(object: CustomLeagueCaller, user: PFUser){
        
        var query = PFQuery(className:"CustomLeague")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if (error != nil) {
                object.endGetCustomLeagues([])
            }
            else{
                object.endGetCustomLeagues(objects)
            }
        }
    }
}