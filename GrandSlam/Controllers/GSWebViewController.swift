//
//  GSWebViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 05/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


class GSWebViewController: UIViewController, UIWebViewDelegate {
    
    var webView:UIWebView!
    var betTextLoading:UIImageView!
    //var timer:NSTimer!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var closeButton = UIButton(frame: CGRectMake(0, 20, 100, 43))
        closeButton.titleLabel!.font  = UIFont(name:FONT2, size:15)
        //closeButton.backgroundColor   = SPECIALBLUE
        closeButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.addTarget(self, action:"closeTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(closeButton)

        webView = UIWebView(frame:CGRectMake(0, YSTART, 320, self.view.frame.size.height-YSTART))
        webView.delegate = self
        self.view.addSubview(webView)
        
    }
    
    func loadViewWithUrl(url:NSURL){
        
        if(url.path?.componentsSeparatedByString("RemoteBetslip").count > 1){
            
            betTextLoading = UIImageView(frame: CGRectMake(0, 120, 320, 76))
            betTextLoading.image = UIImage(named:"betTextLoading")
            self.view.addSubview(betTextLoading)
        }

        self.view.backgroundColor = UIColor.whiteColor()
        let requestObj = NSURLRequest(URL: url)
        SVProgressHUD.show()
        webView.loadRequest(requestObj)
    }
    
    func closeTap(sender: UIButton!){
        
        SVProgressHUD.dismiss()
        dismissViewControllerAnimated(true, completion: nil)
        /*if(timer != nil){
            timer.invalidate()
        }*/
    }
    /*
    func webViewDidStartLoad(webView: UIWebView){
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "dismissLoading", userInfo: nil, repeats: false)
    }
    
    func dismissLoading() {
        SVProgressHUD.dismiss()
    }*/
    
    func webViewDidFinishLoad(webView: UIWebView){
        
        if(betTextLoading != nil){
            betTextLoading.removeFromSuperview()
        }
        SVProgressHUD.dismiss()
    }
    
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError){
        
        if(betTextLoading != nil){
            betTextLoading.removeFromSuperview()
        }
        SVProgressHUD.dismiss()
        
        var alertView = UIAlertView(title: "", message: "Sorry, this page is not available", delegate: nil, cancelButtonTitle: "Ok")
        alertView.show()
        
        closeTap(nil)
    }
    

}