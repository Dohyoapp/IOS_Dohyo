//
//  GSBetSlip.swift
//  GrandSlam
//
//  Created by Explocial 6 on 18/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


var webViewController = GSWebViewController()



class GSBetSlip{
    
    
    var matchId: NSString
    var selection: NSDictionary
    
    
    init(aMatchId: NSString, aSelection: NSDictionary) {
        matchId = aMatchId
        selection = aSelection
    }
    
    
    
    class func getbetMatches(matches:NSArray, bets:NSArray) -> NSArray{
        
        var returnArray = NSMutableArray()
        for match in matches{
            
            for bet in bets{
                
                var betMatchId:NSString = (bet as GSBetSlip).matchId as NSString
                if(betMatchId == match.objectId){
                    returnArray.addObject(match)
                }
            }
        }
        
        return returnArray
    }
    
    
    
    class func buildSlip(betSelections: NSArray){
        
        var betSlip = betSelections[0] as NSDictionary
        var selection = betSlip.objectForKey("selection") as NSDictionary
        var selectionKey = Int(selection.objectForKey("selectionKey") as NSNumber)
        
        var urlString:NSString = URL_ROOT+"v2/betting-api/sportsbook/betslips/build"
        urlString = urlString+"?locale=en-GB&"+"api-key="+LADBROKES_API_KEY
        
        let params:[String: AnyObject] = [
            "selectionKey" : String(selectionKey)
        ] 
        
        SVProgressHUD.show()
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
       // request.addValue("CERN-LineMode/2.15 libwww/2.17b3", forHTTPHeaderField: "User-Agent")
       // request.addValue("123", forHTTPHeaderField: "X-Client-Request-ID")
        request.HTTPMethod = "POST"
        var err: NSError?
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .allZeros, error: &err)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {  (data, response, error) in
            
            SVProgressHUD.dismiss()

            var err: NSError?
            var jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as NSDictionary
            
            var g = 0
        }
        
        task.resume()
        
    }
    
    
    
    
    
    class func goToLadBrokes(selection: NSDictionary){
        
        var currentPrice:NSDictionary!  = selection.objectForKey("currentPrice") as NSDictionary //denPrice = 1; numPrice = 100;
        var selectionKey:AnyObject!     = selection.objectForKey("selectionKey")
        
        if(selectionKey != nil){
            var intSelectionKey = Int(selectionKey as NSNumber)
            var urlString = NSString(format:"https://betslip.ladbrokes.com/RemoteBetslip/bets/betslip.html?selections=%d&locale=en-GB&aff-tag=123&aff-id=123",  intSelectionKey)
            
            webViewController.loadViewWithUrl(NSURL(string:urlString)!)
            GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
        }
        else{
            var alertView = UIAlertView(title: "", message: "Sorry, this selection is not possible", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
    }
    
}