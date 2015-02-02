//
//  RestKitConfig.swift
//  GrandSlam
//
//  Created by Explocial 6 on 26/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

var sharedManager:RKObjectManager!

class RestKitConfig: NSObject {
    
    
    class func getRestKitShareManager() -> RKObjectManager{
    
        if(sharedManager == nil){
            
            let baseURL = NSURL(string: URL_ROOT)!
            
            let client = AFHTTPClient(baseURL: baseURL)
            client.setDefaultHeader("Accept", value:RKMIMETypeJSON)
            
            // Initialize RestKit
            sharedManager = RKObjectManager(HTTPClient:client)
            GSUser.addMappingObject(sharedManager)
        }
        return sharedManager
    }
}


