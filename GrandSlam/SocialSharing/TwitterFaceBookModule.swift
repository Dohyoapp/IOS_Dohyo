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
            var alertView = UIAlertView(title: "Sorry", message: "You can't send a facebook post right now, make sure your device has an internet connection and you have at least one facebook account setup", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
    }
    
}

