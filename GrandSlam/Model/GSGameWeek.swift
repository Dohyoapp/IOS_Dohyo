//
//  GSGameWeek.swift
//  GrandSlam
//
//  Created by Mohamed Boumansour on 21/03/15.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

var cacheNumberGameWeek:NSString!
var gameWeek:GSGameWeek!


class GSGameWeek: NSObject, UIWebViewDelegate {
    
    
    var webView:UIWebView!
    
    class func loadData(){
        
        gameWeek = GSGameWeek()
        gameWeek.getNumberWeekHtml()
    }
    

    func getNumberWeekHtml(){
        
        webView = UIWebView(frame:CGRectMake(0, 100, 100, 100))
        webView.delegate = self
        let requestObj = NSURLRequest(URL: NSURL(string:"http://fantasy.premierleague.com/fixtures/")!)
        webView.loadRequest(requestObj)
    }
    
    
    func webViewDidFinishLoad(webView: UIWebView){
        
        cacheNumberGameWeek = webView.stringByEvaluatingJavaScriptFromString("document.getElementById('ismFixtureTable').caption.innerHTML")
        
        if(navigationBar.customLeagueViewControlelr != nil){
            navigationBar.customLeagueViewControlelr.refreshDateLeagueLabel()
        }
        
    }
}