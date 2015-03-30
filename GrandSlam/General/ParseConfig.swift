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
            PFUser.currentUser().setObject(PFInstallation.currentInstallation(), forKey:"installation")
            PFUser.currentUser().save()
        }
        
        var query = PFQuery(className:"AppConfigData")
        //PFObject.pinAllInBackground(query.findObjects())
        //query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if(error == nil){
                if(objects.count > 0){
                    appConfigData = (objects as NSArray).firstObject as PFObject
                    if( appConfigData["appRepository"] != nil){
                        TEAMS_IMAGES_URL_ROOT = appConfigData["appRepository"] as NSString
                    }
                }
            }
        }
        
        PFFacebookUtils.initializeFacebook()
        
        Mixpanel.sharedInstanceWithToken(MIXPANEL_TOKEN)
    }
    
    
    
    
    
    class func fbLogin1(object: FaceBookDelegate){
        
        SVProgressHUD.show()
        PFFacebookUtils.logInWithPermissions(["email"], { (user: PFUser!, error: NSError!) -> Void in
            if(error != nil){
                SVProgressHUD.dismiss()
            }
            if user == nil {
                SVProgressHUD.dismiss()
                var alertView = UIAlertView(title: "", message: "Login with facebook failed. \nPlease check your Settings -> Facebook and try again.", delegate:nil, cancelButtonTitle: "Ok")
                alertView.show()
                
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
            
            if (error == nil) {
                
                var data:NSDictionary = user as NSDictionary
                
                var email:AnyObject! = data.objectForKey("email")
                if(email != nil){
                    
                    var user = PFUser.currentUser()
                    
                    var query = PFUser.query()
                   // PFObject.pinAllInBackground(query.findObjects())
                   // query.fromLocalDatastore()
                    query.whereKey("email", equalTo:email)
                    query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
                        if error == nil {
                            
                            if(objects != nil && objects.count > 0){
                                var pfUser:PFUser = objects[0] as PFUser
                                
                                PFFacebookUtils.unlinkUserInBackground(user) { (success, error) -> Void in
                                    
                                    var userId:AnyObject! = user.objectId
                                    if(userId != nil){
                                        user.delete()
                                    }
                                    var username = pfUser["username"] as NSString
                                    var password = email as NSString
                                    PFUser.logInWithUsernameInBackground(username, password:password) { (user: PFUser!, error: NSError!) -> Void in
                                        if user != nil {
                                            self.saveUserData(data, object:object)
                                        } else {
                                            // The login failed. Check error to see why.
                                            self.errorMessage()
                                        }
                                    }
                                }
                            }
                            else{
                                self.createUserData(data, object:object)
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
    
    class func saveUserData(data: NSDictionary, object: FaceBookDelegate){
        
        var user = PFUser.currentUser() as PFUser
        
        user["username"]   = data.objectForKey("name")
        user["email"]      = data.objectForKey("email")
        user.password      = data.objectForKey("email") as NSString
        
        var idFBUser:NSString = data.objectForKey("id") as NSString
        var imageLink = NSString(format:"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", idFBUser)
        
        var imageView   = UIImageView(frame: CGRectMake(0, 0, 80, 80))
        var urlRequest  = NSURLRequest(URL:NSURL(string: imageLink)!)
        imageView.setImageWithURLRequest( urlRequest, placeholderImage: nil, success: { (url, response, image) -> Void in
            
                SVProgressHUD.dismiss()
                var userId:AnyObject! = user.objectId
                if(userId != nil){
                    let imageFile = PFFile(name:NSString(format:"image%@.png", userId as NSString), data:UIImagePNGRepresentation(image))
                    user.setObject(imageFile, forKey: "image")
                    user.saveInBackgroundWithBlock({ (success, error) -> Void in
                        object.endGetFacebookData()
                    })
                }
                else{
                    object.endGetFacebookData()
                }
            }, failure: { (url, response, error) -> Void in
                
                user.save()
                object.endGetFacebookData()
        })
    }
    
    
    
    
    class func createUserData(data: NSDictionary, object: FaceBookDelegate){
        
        var user = PFUser.currentUser() as PFUser
        
        user["username"]   = data.objectForKey("name")
        user["email"]      = data.objectForKey("email")
        user.password      = data.objectForKey("email") as NSString
        
        user.signUpInBackgroundWithBlock({ (success, error) -> Void in
            
            var idFBUser:NSString = data.objectForKey("id") as NSString
            var imageLink = NSString(format:"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", idFBUser)
            
            var imageView   = UIImageView(frame: CGRectMake(0, 0, 80, 80))
            var urlRequest  = NSURLRequest(URL:NSURL(string: imageLink)!)
            imageView.setImageWithURLRequest( urlRequest, placeholderImage: nil, success: { (url, response, image) -> Void in
                
                SVProgressHUD.dismiss()
                var userId:AnyObject! = user.objectId
                if(userId != nil){
                    let imageFile = PFFile(name:NSString(format:"image%@.png", userId as NSString), data:UIImagePNGRepresentation(image))
                    user.setObject(imageFile, forKey: "image")
                    user.saveInBackgroundWithBlock({ (success, error) -> Void in
                        object.endGetFacebookData()
                    })
                }
                else{
                    object.endGetFacebookData()
                }
                }, failure: { (url, response, error) -> Void in
                    
                    user.save()
                    object.endGetFacebookData()
            })
            
        })
    }
}

