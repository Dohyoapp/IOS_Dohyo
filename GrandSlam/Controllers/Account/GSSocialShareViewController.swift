//
//  GSSocialShareViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 30/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

class GSSocialShareViewController: UIViewController, SendEmailDelegate, ShareOnFBTWSDelegate, SendSMSDelegate {
    
    var fbButton:UIButton!
    var twitterButton:UIButton!
    var whatsAppButton:UIButton!
    var smsButton:UIButton!
    var mailButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        var yButtons = 10 as CGFloat
        
        fbButton = UIButton(frame: CGRectMake(30, yButtons, 40, 40))
        fbButton.setBackgroundImage(UIImage(named: "facebook"), forState: .Normal)
        fbButton.addTarget(self, action:"fbButtonTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(fbButton)
        
        
        twitterButton = UIButton(frame: CGRectMake(85, yButtons, 40, 40))
        twitterButton.setBackgroundImage(UIImage(named: "twitter"), forState: .Normal)
        twitterButton.addTarget(self, action:"twitterButtonTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(twitterButton)
        
        whatsAppButton = UIButton(frame: CGRectMake(140, yButtons, 40, 40))
        whatsAppButton.setBackgroundImage(UIImage(named: "whatsapp"), forState: .Normal)
        whatsAppButton.addTarget(self, action:"whatsAppButtonTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(whatsAppButton)
        
        
        smsButton = UIButton(frame: CGRectMake(195, yButtons, 40, 40))
        smsButton.setBackgroundImage(UIImage(named: "chat"), forState: .Normal)
        smsButton.addTarget(self, action:"smsButtonTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(smsButton)
        
        mailButton = UIButton(frame: CGRectMake(250, yButtons, 40, 40))
        mailButton.setBackgroundImage(UIImage(named: "email"), forState: .Normal)
        mailButton.addTarget(self, action:"mailButtonTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(mailButton)
        
    }
    
    
    var twitterFaceBookModule:TwitterFaceBookModule!
    
    func fbButtonTap(sender: UIButton!){
        
        twitterFaceBookModule = TwitterFaceBookModule(delegate:self)
        twitterFaceBookModule.facebook("text", image: UIImage(), link: "http://fr.yahoo.com")
    }
    
    func shareFBSuccesFinish(){
        
    }
    
    
    
    func twitterButtonTap(sender: UIButton!){
        twitterFaceBookModule = TwitterFaceBookModule(delegate:self)
        twitterFaceBookModule.twitter("text", image: UIImage(), link: "http://fr.yahoo.com")
    }
    
    func shareTWSuccesFinish(){
        
    }
    
    
    
    
    
    func whatsAppButtonTap(sender: UIButton!){
        
        var message = "hello"
        
        var text  = NSString(format:"whatsapp://send?text=%@", message)
        var escapedUrlString  = text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var whatsappURL  = NSURL(string:escapedUrlString!)
        if (UIApplication.sharedApplication().canOpenURL(whatsappURL!)) {
            UIApplication.sharedApplication().openURL(whatsappURL!)
        }
        else{
            var alertView = UIAlertView(title: "", message: "Your device does not support whats app!", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
    }
    
    
    
    
    
    var smsModule:SmsModule!
    func smsButtonTap(sender: UIButton!){
        smsModule = SmsModule(delegate: self)
        smsModule.sendSms("body", adresses:nil)
    }
    
    func sendSmsSuccesFinish(){
        
    }
    
    
    
    
    var emailModule:EmailModule!
    func mailButtonTap(sender: UIButton!){
        
        emailModule = EmailModule(delegate:self)
        emailModule.sendSimpleMail("my title", adresses:nil, body: "hello body")
    }
    
    func sendEmailSuccesFinish(){
        
    }
}
