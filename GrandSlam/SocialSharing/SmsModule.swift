//
//  SmsModule.swift
//  GrandSlam
//
//  Created by Explocial 6 on 02/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation
import MessageUI

protocol SendSMSDelegate {
    func sendSmsSuccesFinish()
}



class SmsModule: NSObject, MFMessageComposeViewControllerDelegate{
    
    var myDelegate:SendSMSDelegate!
    
    init(delegate:SendSMSDelegate) {
        super.init()
        myDelegate = delegate
    }
    
    func sendSms(body:NSString, adresses:NSArray!){
        
        if(MFMessageComposeViewController.canSendText()){
            
            var messageComposeVC = MFMessageComposeViewController()
            messageComposeVC.messageComposeDelegate = self
            messageComposeVC.body = body
            if(adresses != nil && adresses.count > 0){
                messageComposeVC.recipients = adresses
            }
            GSMainViewController.getMainViewControllerInstance().presentViewController(messageComposeVC, animated: true, completion: nil)
        }
        else{
            var alertView = UIAlertView(title: "SMS error", message: "Your device does not support SMS", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
        SVProgressHUD.dismiss()
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        
        myDelegate.sendSmsSuccesFinish()
        GSMainViewController.getMainViewControllerInstance().dismissViewControllerAnimated(true, completion: nil)
    }
}