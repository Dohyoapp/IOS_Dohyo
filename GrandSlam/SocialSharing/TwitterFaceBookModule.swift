//
//  TwitterFaceBookModule.swift
//  GrandSlam
//
//  Created by Explocial 6 on 02/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation
import Social



protocol ShareOnFBTWSDelegate {
    func shareFBSuccesFinish()
    func shareTWSuccesFinish()
}


class TwitterFaceBookModule: NSObject{
    
    var myDelegate:ShareOnFBTWSDelegate!
    
    init(delegate:ShareOnFBTWSDelegate) {
        super.init()
        myDelegate = delegate
    }
    
    func twitter(text: NSString, image: UIImage, link: NSString){
        
        if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)){
            
            var socialVC :SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            socialVC.setInitialText(text)
            socialVC.addImage(image)
            socialVC.addURL(NSURL(string:link))
            
            socialVC.completionHandler = { (result:SLComposeViewControllerResult) in
                // Your code
                switch (result.rawValue) {
                    case SLComposeViewControllerResult.Cancelled.rawValue:
                        NSLog("Post Canceled");
                        break
                    case SLComposeViewControllerResult.Done.rawValue:
                        NSLog("Post Sucessful");
                        self.myDelegate.shareTWSuccesFinish()
                        break
                    
                    default:
                        
                        break
                }
                GSMainViewController.getMainViewControllerInstance().dismissViewControllerAnimated(false, completion: nil)
            }
            
            GSMainViewController.getMainViewControllerInstance().presentViewController(socialVC, animated: true, completion: nil)
        }
        else{
            var alertView = UIAlertView(title: "Sorry", message: "You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
        SVProgressHUD.dismiss()
    }
    
    func facebook(text: NSString, image: UIImage, link: NSString){
        
        if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)){
            
            var socialVC :SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            socialVC.setInitialText(text)
            socialVC.addImage(image)
            socialVC.addURL(NSURL(string:link))
            
            socialVC.completionHandler = { (result:SLComposeViewControllerResult) in
                // Your code
                switch (result.rawValue) {
                case SLComposeViewControllerResult.Cancelled.rawValue:
                    NSLog("Post Canceled");
                    break
                case SLComposeViewControllerResult.Done.rawValue:
                    NSLog("Post Sucessful");
                    self.myDelegate.shareFBSuccesFinish()
                    break
                    
                default:
                    
                    break
                }
                GSMainViewController.getMainViewControllerInstance().dismissViewControllerAnimated(false, completion: nil)
            }
            
            GSMainViewController.getMainViewControllerInstance().presentViewController(socialVC, animated: true, completion: nil)
        }
        else{
            /*
            var alertView = UIAlertView(title: "Sorry", message: "You can't send a facebook post right now, make sure your device has an internet connection and you have at least one facebook account setup", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
*/
            oldSendFaceBook(text, image: image, link: link)
        }
        SVProgressHUD.dismiss()
    }
    
    
    func oldSendFaceBook(text: NSString, image: UIImage, link: NSString){
    
        var params:FBLinkShareParams = FBLinkShareParams()
        //FBShareDialogParams
        params.link     = NSURL(string:link)
        params.picture  = NSURL(string:TEAMS_IMAGES_URL_ROOT+"app_icon.png")
        params.linkDescription = text
        
        // If the Facebook app is installed and we can present the share dialog
        if (FBDialogs.canPresentShareDialogWithParams(params)) {
            // Present the share dialog
            FBDialogs.presentShareDialogWithLink(params.link, name: "", caption: params.caption, description: params.linkDescription, picture: params.picture, clientState: nil,  handler: { (call, results, error) -> Void in
                
                if(error != nil) {
                    
                } else {
                    // Success
                    NSLog("result %@", results)
                    var completition = (results as NSDictionary).objectForKey("completionGesture") as NSString
                    var complete = (results as NSDictionary).valueForKey("didComplete") as Int
                    
                     if (completition.isEqualToString("post")  && (complete == 1)){
                        self.myDelegate.shareFBSuccesFinish()
                    }
                }
            })
            
        } else {
            
            var params = ["name":"", "description":text, "link":link, "picture":TEAMS_IMAGES_URL_ROOT+"app_icon.png"]
            
            
            // Show the feed dialog
            FBWebDialogs.presentFeedDialogModallyWithSession(nil, parameters: params) { (result, resultURL, error) -> Void in
                
                if (error != nil) {
                    NSLog("Error publishing story: %@", error.description);
                } else {
                    
                    if (result == FBWebDialogResult.DialogNotCompleted) {
                        // User cancelled.
                        NSLog("User cancelled.");
                    } else {
                        // Handle the publish feed callback
                        var urlParams:NSDictionary =  self.parseURLParams(resultURL.query!)
                    
                        if (urlParams.objectForKey("post_id") == nil) {
                            // User cancelled.
                            NSLog("User cancelled.");
                    
                        } else{
                            self.myDelegate.shareFBSuccesFinish()
                        }
                    }
                    
                }
            }
            
        }
        
    }
    
    
    // A function for parsing URL parameters returned by the Feed Dialog.
    class func parseURLParams(query:NSString) -> NSDictionary {
        var pairs:NSArray = query.componentsSeparatedByString("&")
        var params:NSMutableDictionary = NSMutableDictionary()
        for pair in pairs {
            var kv:NSArray     = (pair as NSString).componentsSeparatedByString("=")
            var val:NSString   = kv[1].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            params.setObject(val, forKey: kv[0] as NSString)
        }
        return params;
    }

    
    /*
    func getFBUrl(theUrl: NSString){
    
        var appId =  NSNumber(int:(appConfigData["itunesAppId"] as NSString).intValue)
        let jsonObject = NSMutableArray()
        jsonObject.addObject(["url": theUrl, "app_store_id": appId , "app_name": "Dohyo"])
        var jsonData:NSData = NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: nil)!
    
        let dataStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
    
        var params = NSMutableDictionary(object:"Dohyo", forKey:"name")
        params.setObject(dataStr!, forKey: "ios")
        params.setObject("{\"should_fallback\": false}", forKey: "web")
        params.setObject("770143146388459|pAUH5kY_4BjfqJDsRHysDy7mgzA", forKey: "access_token")
    
        FBRequestConnection.startWithGraphPath("/770143146388459/app_link_hosts", parameters: params, HTTPMethod: "POST",
            completionHandler: { (connection , result, error) -> Void in
    
                if (error != nil) {
    
                }else{
                    NSLog("Result = %@",result as NSDictionary)
    
                    var newLink: NSString = (result as NSDictionary).objectForKey("id") as NSString
                    self.facebook(MESSAGE_TEXT2, image: UIImage(), link: String(format:"https://fb.me/%@", newLink) )
                }
        })
    }
    */
    
    
    
    
    func parseURLParams(query : NSString) -> NSDictionary {
        var pairs:NSArray = query.componentsSeparatedByString("&")
        var params:NSMutableDictionary = NSMutableDictionary()
        for pair in pairs {
            var kv:NSArray = pair.componentsSeparatedByString("=")
            var val:NSString = kv[1].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            params[kv[0] as NSString] = val
        }
        return params;
    }
    
    var friendPickerController:FBFriendPickerViewController!

    func sendToFriends(){

        friendPickerController = FBFriendPickerViewController()
        friendPickerController.title = "Pick Friends"
        friendPickerController.loadData()
        //friendPickerController.delegate = self
        //friendPickerController.presentModallyFromViewController(self, animated:true, handler:nil)
    }
    
    func facebookViewControllerDoneWasPressed(sender:AnyObject)
    {/*
        var users = NSMutableArray()
        
        for user in self.friendPickerController.selection {
        var dico = user as NSDictionary
        users.addObject(dico.objectForKey("id") as NSString)
        NSLog("Friend selected: %@", dico.objectForKey("name") as NSString)
        }
        */
        var params:FBLinkShareParams = FBLinkShareParams()
        params.link = NSURL(string : "https://developers.facebook.com/docs/ios/share/")
        params.friends = self.friendPickerController.selection
        
        FBDialogs.presentShareDialogWithParams(params, clientState: nil, handler: { (call:FBAppCall!, result, error) -> Void in
            
        })
        
        friendPickerController.dismissViewControllerAnimated(false, completion: nil)
    }
    
}

