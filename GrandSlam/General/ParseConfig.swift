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



class ParseConfig: NSObject {
    
    class func initialization(){
        
        Parse.enableLocalDatastore()
        // Enable Crash Reporting
        ParseCrashReporting.enable()
        
        // Initialize Parse.
        Parse.setApplicationId("XCYnUIgcJKdPcW8u5FsiqMFeL0sFZDiWoeqWrUn2",
        clientKey:"XIV8NiEBmQDm54CskEMMC8BeEdD2QeTlUAz1m1Mf")
        
        PFFacebookUtils.initializeFacebook()
        // [Optional] Track statistics around application opens.
        var dico:NSDictionary = [:]
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(dico, block: nil)
        
        PFUser.enableAutomaticUser()
        
        PFInstallation.currentInstallation().saveInBackgroundWithBlock { (success, error) -> Void in
            PFUser.currentUser().setObject(PFInstallation.currentInstallation(), forKey:"installation")
            PFUser.currentUser().save()
        }
    }
    
    
    
    
    
    class func fbLogin1(object: FaceBookDelegate){
        
        SVProgressHUD.show()
        PFFacebookUtils.logInWithPermissions(["email"], { (user: PFUser!, error: NSError!) -> Void in
            if(error != nil){
                SVProgressHUD.dismiss()
            }
            if user == nil {
                SVProgressHUD.dismiss()
                var alertView = UIAlertView(title: "", message: "Login with facebook failed. \nPlease try again.", delegate:nil, cancelButtonTitle: "Ok")
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
                    
                    var query = PFUser.query()
                    query.whereKey("email", equalTo:email)
                    query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
                        if error == nil {
                            
                            if(objects != nil && objects.count > 0){
                                var pfUser:PFUser = objects[0] as PFUser
                                
                                PFFacebookUtils.unlinkUserInBackground(PFUser.currentUser()) { (success, error) -> Void in
                                    
                                    var userId:AnyObject! = PFUser.currentUser().objectId
                                    if(userId != nil){
                                        PFUser.currentUser().delete()
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
                                self.saveUserData(data, object:object)
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
        
        PFUser.currentUser().setValue(data.objectForKey("name"), forKey: "username")
        PFUser.currentUser().setValue(data.objectForKey("email"), forKey: "email")
        PFUser.currentUser().setValue(data.objectForKey("email"), forKey: "password")
        
        var idFBUser:NSString = data.objectForKey("id") as NSString
        var imageLink = NSString(format:"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", idFBUser)
        
        var imageView   = UIImageView(frame: CGRectMake(0, 0, 80, 80))
        var urlRequest  = NSURLRequest(URL:NSURL(string: imageLink)!)
        imageView.setImageWithURLRequest( urlRequest, placeholderImage: nil, success: { (url, response, image) -> Void in
            
                SVProgressHUD.dismiss()
                var userId:AnyObject! = PFUser.currentUser().objectId
                if(userId != nil){
                    let imageFile = PFFile(name:NSString(format:"image%@.png", userId as NSString), data:UIImagePNGRepresentation(image))
                    PFUser.currentUser().setObject(imageFile, forKey: "image")
                    PFUser.currentUser().saveInBackgroundWithBlock({ (success, error) -> Void in
                        object.endGetFacebookData()
                    })
                }
                else{
                    object.endGetFacebookData()
                }
            }, failure: { (url, response, error) -> Void in
                
                PFUser.currentUser().save()
                object.endGetFacebookData()
        })
    }
}

