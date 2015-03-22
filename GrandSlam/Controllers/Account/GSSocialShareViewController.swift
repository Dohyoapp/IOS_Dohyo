//
//  GSSocialShareViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 30/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


var MESSAGE_TEXT1 = "I challenge you to beat my Premier League predictions on Dohyō! Join me here:"
var MESSAGE_TEXT2 = "I've just created a Premier League predictions contest on Dohyō. I challenge you to beat score! Join my league here:"


class GSSocialShareViewController: UIViewController, SendEmailDelegate, ShareOnFBTWSDelegate, SendSMSDelegate, FBFriendPickerDelegate {
    
    var fbButton:UIButton!
    var twitterButton:UIButton!
    var whatsAppButton:UIButton!
    var smsButton:UIButton!
    var mailButton:UIButton!
    
    
    var isProfileView = false
    var customLeagueId:NSString!
    
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
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    
    var twitterFaceBookModule:TwitterFaceBookModule!
    
    
    
    func fbButtonTap(sender: UIButton!){
        
        twitterFaceBookModule = TwitterFaceBookModule(delegate:self)
        if(!isProfileView){
            var link = String(format:"%@appLaunch.html?userId=%@&costumLeagueId=%@", TEAMS_IMAGES_URL_ROOT, PFUser.currentUser().objectId, customLeagueId)
            twitterFaceBookModule.facebook(MESSAGE_TEXT2, image: UIImage(), link: link)
            
        }else{
            twitterFaceBookModule.facebook(MESSAGE_TEXT1, image: UIImage(), link: appConfigData["itunesAppUrl"] as NSString)
        }
    }
    
    func shareFBSuccesFinish(){
        
    }
    
    
    
    
    
    func twitterButtonTap(sender: UIButton!){
        
        twitterFaceBookModule = TwitterFaceBookModule(delegate:self)
        if(!isProfileView){
            
            var link = String(format:"%@appLaunch.html?userId=%@&costumLeagueId=%@", TEAMS_IMAGES_URL_ROOT, PFUser.currentUser().objectId, customLeagueId)
            twitterFaceBookModule.twitter(MESSAGE_TEXT2, image: UIImage(), link: link)
            
        }else{
            twitterFaceBookModule.twitter(MESSAGE_TEXT1, image: UIImage(), link: appConfigData["itunesAppUrl"] as NSString)
        }
    }
    
    func shareTWSuccesFinish(){
        
    }
    
    
    
    
    
    func whatsAppButtonTap(sender: UIButton!){
        
        var message = String(format:"%@ %@", MESSAGE_TEXT1, appConfigData["itunesAppUrl"] as NSString)
        if(!isProfileView){
            var link = String(format:"Dohyo://userId/%@/costumLeagueId/%@", PFUser.currentUser().objectId, customLeagueId)
            message = String(format:"%@ %@", MESSAGE_TEXT2, link)
        }
        
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
        
        var message = String(format:"%@ %@", MESSAGE_TEXT1, appConfigData["itunesAppUrl"] as NSString)
        if(!isProfileView){
            var link = String(format:"Dohyo://userId/%@/costumLeagueId/%@", PFUser.currentUser().objectId, customLeagueId)
            message = String(format:"%@ %@", MESSAGE_TEXT2, link)
        }
        
        smsModule = SmsModule(delegate: self)
        smsModule.sendSms(message, adresses:nil)
    }
    
    func sendSmsSuccesFinish(){
        
    }
    
    
    
    
    var emailModule:EmailModule!
    func mailButtonTap(sender: UIButton!){
        
        var message = String(format:"%@ %@", MESSAGE_TEXT1, appConfigData["itunesAppUrl"] as NSString)
        if(!isProfileView){
            var link = String(format:"%@appLaunch.html?userId=%@&costumLeagueId=%@", TEAMS_IMAGES_URL_ROOT, PFUser.currentUser().objectId, customLeagueId)
            message = String(format:"%@ %@", MESSAGE_TEXT2, link)
        }
        
        emailModule = EmailModule(delegate:self)
        emailModule.sendSimpleMail("Join my league", adresses:nil, body: message)
    }
    
    func sendEmailSuccesFinish(){
        
    }
    
    
}
