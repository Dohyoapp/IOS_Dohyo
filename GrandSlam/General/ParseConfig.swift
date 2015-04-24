//
//  ParseConfig.swift
//  GrandSlam
//
//  Created by Explocial 6 on 26/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


protocol FaceBookDelegate {
    func endFaceBookLogIn()
    func endGetFacebookData()
}



var appConfigData:PFObject!

class ParseConfig: NSObject {
    
    class func initialization(){
        
        Parse.enableLocalDatastore()
        ParseCrashReporting.enable()
        
        // Initialize Parse.
        Parse.setApplicationId(PARSE_APPLICATION_KEY, clientKey:PARSE_CLIENT_KEY)
        
        
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground([:], block: nil)
        
        PFUser.enableAutomaticUser()
        
        
        PFInstallation.currentInstallation().saveInBackgroundWithBlock { (success, error) -> Void in
            if(success && Utils.isParseNull(error)){
                PFUser.currentUser().setObject(PFInstallation.currentInstallation(), forKey:"installation")
                PFUser.currentUser().save()
            }
        }
        
        var query = PFQuery(className:"AppConfigData")
        //PFObject.pinAllInBackground(query.findObjects())
        //query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if(Utils.isParseNull(error)){
                if(objects.count > 0){
                    appConfigData = (objects as NSArray).firstObject as! PFObject
                    if( !Utils.isParseNull(appConfigData["appRepository"]) ){
                        TEAMS_IMAGES_URL_ROOT = appConfigData["appRepository"] as! String
                    }
                }
            }
        }
        
        PFFacebookUtils.initializeFacebook()
        
        Mixpanel.sharedInstanceWithToken(MIXPANEL_TOKEN)
    }
    
    
    
    
    
    class func fbLogin1(object: FaceBookDelegate){
        
        SVProgressHUD.show()
        PFFacebookUtils.logInWithPermissions(["email"], block: { (user: PFUser!, error: NSError!) -> Void in
            if(!Utils.isParseNull(error)){
                self.errorMessage()
                return
            }
            if Utils.isParseNull(user) {
                SVProgressHUD.dismiss()
                PFUser.new().saveInBackgroundWithBlock({ (success, error) -> Void in
                    if(success){
                        object.endFaceBookLogIn()
                    }
                })
                
            } else if user.isNew {
                NSLog("User signed up and logged in through Facebook!")
                object.endFaceBookLogIn()
            } else {
                NSLog("User logged in through Facebook!")
                object.endFaceBookLogIn()
            }
        })
    }
    
    
    

    
    /*
    class func fbLogin2(object: FaceBookDelegate){

        SVProgressHUD.show()
        var user = PFUser.currentUser()
        if !PFFacebookUtils.isLinkedWithUser(user) {
            PFFacebookUtils.linkUser(user, permissions:nil, { (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    object.endFaceBookLogIn()
                }
                else{
                    var alertView = UIAlertView(title: "", message: "Login with facebook failed. \nPlease try again.", delegate:nil, cancelButtonTitle: "Ok")
                    alertView.show()
                }
                SVProgressHUD.dismiss()
            })
        }
        else{
            object.endFaceBookLogIn()
            SVProgressHUD.dismiss()
        }
    }*/
    
    
    
    class func getFacebookData(object: FaceBookDelegate) {
        
        SVProgressHUD.show()
        FBRequest.requestForMe().startWithCompletionHandler { (connection, user, error) -> Void in
            
            if ( Utils.isParseNull(error)) {
                
                var data:NSDictionary = user as! NSDictionary
                
                var email:String = data.objectForKey("email") as! String
                if(!Utils.isParseNull(email)){
                    
                    
                    var query = PFUser.query()
                    query.whereKey("email", containedIn: [email, email+"fb"])
                    query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
                        if Utils.isParseNull(error) {
                            
                            //email Allready exist
                            if(objects != nil && objects.count > 0){
                                
                                var pfUser:PFUser = objects[0] as! PFUser
                                if(objects.count > 1){
                                    for userObject in objects{
                                        if(userObject["email"] as! String == email+"fb"){
                                            pfUser = userObject as! PFUser
                                        }
                                    }
                                }
                                
                                email = pfUser["email"] as! String
                                
                                var isFacebookAccount = false
                                if( !Utils.isParseNull(pfUser["isFaceBookAccount"]) && (pfUser["isFaceBookAccount"] as! Bool) ){
                                    isFacebookAccount = true
                                }
                                if( (!Utils.isParseNull(pfUser["authData"]) && (pfUser["authData"] as! NSString).containsString("Facebook")) ){
                                    isFacebookAccount = true
                                }
                                if( (!Utils.isParseNull(pfUser["username"]) && (pfUser["username"] as? NSString == data.objectForKey("name") as! String)) ){
                                    isFacebookAccount = true
                                }
                                
                                if( !isFacebookAccount ){//email Allready exist not faceBook
       
                                    var newData:NSMutableDictionary = NSMutableDictionary(dictionary: data)
                                    newData.removeObjectForKey("email")
                                    newData.setObject(email+"fb", forKey: "email")
                                    self.saveOrCreateFbUserData(newData, object:object)
                                    
                                }
                                else{
                                
                                    PFFacebookUtils.unlinkUserInBackground(PFUser.currentUser()) { (success, error) -> Void in
                                        
                                        var username = pfUser["username"] as! String
                                        var password = email
                                        PFUser.logInWithUsernameInBackground(username, password:password ) { (user: PFUser!, error: NSError!) -> Void in
                                            if !Utils.isParseNull(user) {
                                                // as email could be email or email+"fb"
                                                var newData:NSMutableDictionary = NSMutableDictionary(dictionary: data)
                                                newData.removeObjectForKey("email")
                                                newData.setObject(email, forKey: "email")
                                                self.saveOrCreateFbUserData(newData, object:object)
                                            } else {
                                                // The login failed. Check error to see why.
                                                self.errorMessage()
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            else{
                                self.saveOrCreateFbUserData(data, object:object)
                            }
                            
                        }//querry error
                        else{
                            self.errorMessage()
                        }
                    }//end query
                }
                else{
                    self.errorMessage()
                }
                
            }
            else{
                self.errorMessage()
            }
            
        }
    }
    
    class func errorMessage(){
        
        SVProgressHUD.dismiss()
        var alertView = UIAlertView(title: "", message: "failed to get your information from facebook . \nPlease try again.", delegate:nil, cancelButtonTitle: "Ok")
        alertView.show()
    }
    
    
    
    
    
    // svaee or create user function used Only here
    class func saveOrCreateFbUserData(data: NSDictionary, object: FaceBookDelegate){
        
        var user = PFUser.currentUser() as PFUser
        if(Utils.isParseNull(user.objectId)){
            user = PFUser.new()
        }
        
        user["username"]   = data.objectForKey("name")
        user["email"]      = data.objectForKey("email") as! String
        user.password      = data.objectForKey("email") as! String
        user["isFaceBookAccount"] = true
        
        if(PFInstallation.currentInstallation().objectId == nil){
            if( !Utils.isParseNull(user["installation"]) ){
                user.removeObjectForKey("installation")
            }
        }
        if(!Utils.isParseNull(user.objectId)){
            self.saveFBImage(data, object: object, user: user)
        }
        else{
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                
                if(success && Utils.isParseNull(error)){
                    self.saveFBImage(data, object: object, user: user)
                }
                else{
                    SVProgressHUD.dismiss()
                    var alertView = UIAlertView(title: "", message: error.description, delegate:nil, cancelButtonTitle: "Ok")
                    alertView.show()
                }
            })
        }
    }
    
    
    class func saveFBImage(data: NSDictionary, object: FaceBookDelegate, user: PFUser){
        
        var idFBUser:NSString = data.objectForKey("id") as! String
        var imageLink = NSString(format:"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", idFBUser)
        
        var imageView   = UIImageView(frame: CGRectMake(0, 0, 80, 80))
        var urlRequest  = NSURLRequest(URL:NSURL(string: imageLink as String)!)
        imageView.setImageWithURLRequest( urlRequest, placeholderImage: nil, success: { (url, response, image) -> Void in
            
                var userId:AnyObject! = user.objectId
                if( !Utils.isParseNull(userId)){
                    let imageFile = PFFile(name:String(format:"image%@.png", userId as! NSString), data:UIImagePNGRepresentation(image))
                    user.setObject(imageFile, forKey: "image")
                    user.saveInBackgroundWithBlock({ (success, error) -> Void in
                        SVProgressHUD.dismiss()
                        object.endGetFacebookData()
                    })
                }
                else{
                    SVProgressHUD.dismiss()
                    object.endGetFacebookData()
                }
            
            }, failure: { (url, response, error) -> Void in
                
                NSLog("failed loading FaceBook image")
                SVProgressHUD.dismiss()
                user.save()
                object.endGetFacebookData()
        })
    }
    
    
}

