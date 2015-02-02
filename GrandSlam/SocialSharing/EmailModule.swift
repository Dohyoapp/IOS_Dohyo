//
//  EmailModule.swift
//  GrandSlam
//
//  Created by Explocial 6 on 02/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation
import MessageUI

protocol SendEmailDelegate {
    func sendEmailSuccesFinish()
}



class EmailModule: NSObject, MFMailComposeViewControllerDelegate{
    
    var myDelegate:SendEmailDelegate!
    
    init(delegate:SendEmailDelegate) {
        super.init()
        myDelegate = delegate
    }
    
    func sendSimpleMail(title:NSString, adresses:NSArray!, body:NSString){
        
        if(MFMailComposeViewController.canSendMail()){
            
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setSubject(title)
            mailComposerVC.setMessageBody(body, isHTML: false)
            if(adresses != nil && adresses.count > 0){
                mailComposerVC.setToRecipients(adresses)
            }
            GSMainViewController.getMainViewControllerInstance().presentViewController(mailComposerVC, animated: true, completion: nil)
        }
        else{
            var alertView = UIAlertView(title: "Email error", message: "We cannot connect to your email", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        switch result.value {
            case MFMailComposeResultCancelled.value:
                NSLog("Mail cancelled")
            case MFMailComposeResultSaved.value:
                NSLog("Mail saved")
            case MFMailComposeResultSent.value:
                NSLog("Mail sent")
                myDelegate.sendEmailSuccesFinish()
            case MFMailComposeResultFailed.value:
                NSLog("Mail sent failure: %@", [error.localizedDescription])
            default:
                break
        }
        GSMainViewController.getMainViewControllerInstance().dismissViewControllerAnimated(false, completion: nil)
    }
}