//
//  GSWebViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 05/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

let AUTHENTIFICATION_LINK = "https://api.ladbrokes.com/forms/authorise-client?client_id="


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
    
    
    var state = false
    //&state=stjoe
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        
        var urlString:NSString = request.URL!.absoluteString!
        var urlsArray:NSArray = urlString.componentsSeparatedByString(AUTHENTIFICATION_LINK)
        if (urlsArray.count > 1){
            
            if(!state){

                var range:Range = (urlsArray.lastObject as! String).rangeOfString("&")!
                
                var newString = (urlsArray.lastObject as! String).substringFromIndex(range.startIndex) as String
                var newUrl = AUTHENTIFICATION_LINK+LADBROKES_API_KEY+newString
                
                newUrl = newUrl.stringByReplacingOccurrencesOfString("prompt=0", withString: "prompt=1")
                
                var requestObj = NSURLRequest(URL: NSURL(string:newUrl)!)
                webView.loadRequest(requestObj)
                
                state = true
                
                return false
            }
            else{
                state = false
            }
        }
        /*
        var urlsArray2:NSArray = urlString.componentsSeparatedByString("betslip.ladbrokes.com/RemoteBetslip/bets/betslip.html?token=")
        if(urlsArray.count > 2){
            
        }*/
        
        return true
    }
    

    
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