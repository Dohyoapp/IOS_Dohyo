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
        matchId     = aMatchId
        selection   = aSelection
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
    
    
    
    
    
    class func goToLadBrokes(selections: NSArray){
        
        var selectionsKey = ""
        for selection in selections {
            //var currentPrice:NSDictionary!  = selection.objectForKey("currentPrice") as NSDictionary //denPrice = 1; numPrice = 100;
            var selectionKey:AnyObject!     = (selection as NSDictionary).objectForKey("selectionKey")
            if(selectionKey != nil){
                var intSelectionKey = Int(selectionKey as NSNumber)
                if(countElements(selectionsKey) > 1){
                    selectionsKey = NSString(format:"%@,%d", selectionsKey, intSelectionKey)
                }
                else{
                    selectionsKey = NSString(format:"%d", intSelectionKey)
                }
            }
        }
        
        
        if(countElements(selectionsKey) > 1){
            
            var urlString = NSString(format:"https://betslip.ladbrokes.com/RemoteBetslip/bets/betslip.html?selections=%@&locale=en-GB&aff-tag=123&aff-id=123",  selectionsKey)
            
            webViewController.loadViewWithUrl(NSURL(string:urlString)!)
            GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
        }
        else{
            var alertView = UIAlertView(title: "", message: "Sorry,you should have at least one active bet", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
    }
    
    
    
    
    class func oddsCalculator(bets:NSArray, validMatches:NSMutableArray) -> NSArray{
        
        var totalOdds:Double = 0
        for betSlip in bets{
            
            var selection       = getActualisedSelection(betSlip as GSBetSlip, validMatches: validMatches)
            
            var currentPrice = selection.objectForKey("currentPrice") as NSDictionary
            var decimalPrice = currentPrice.objectForKey("decimalPrice") as Double
            var denPrice = currentPrice.objectForKey("denPrice") as Double
            var numPrice = currentPrice.objectForKey("numPrice") as Double
            
            //var odd = (numPrice/denPrice)+1
            if(totalOdds == 0){
                // totalOdds = odd
                totalOdds = decimalPrice
            }
            else{
                //totalOdds = totalOdds * odd
                totalOdds = totalOdds * decimalPrice
            }
        }
        
        var aPGCD = Utils.findPGCD(Int32(totalOdds*100), b:100)
        
        return [totalOdds*100/Double(aPGCD), 100/Double(aPGCD)]
    }
    
    
    /*
    func getActualisedSelection(betSlip: GSBetSlip) -> NSDictionary{
    
    var matchSelection:GSMatcheSelection!
    for aValidMatche in validMatches{
    
    var matchPf = (aValidMatche as GSMatcheSelection).pfMatche as PFObject
    if(matchPf.objectId == betSlip.matchId){
    matchSelection = aValidMatche as GSMatcheSelection
    }
    }
    
    var selection   = betSlip.selection
    var aSelection  = matchSelection.getScoreCorrectSelectionByName(selection.objectForKey("selectionName") as NSString)
    if(selection.objectForKey("currentPrice") != nil){
    selection = aSelection
    }
    return selection
    }*/
    
    
    class func getActualisedSelection(betSlip: GSBetSlip, validMatches:NSMutableArray) -> NSDictionary{
        
        var oldBet:Bool = false
        
        var matchSelection:GSMatcheSelection!
        for aValidMatche in validMatches{
            
            var matchPf = (aValidMatche as GSMatcheSelection).pfMatche as PFObject
            if(matchPf.objectId == betSlip.matchId){
                matchSelection = aValidMatche as GSMatcheSelection
                var matcheDate = GSCustomLeague.getDateMatche(matchPf)
                if(matcheDate.timeIntervalSinceDate(NSDate()) < 0){
                    oldBet = true
                }
            }
        }
        
        var selection       = betSlip.selection
        var selectionName   = selection.objectForKey("selectionName") as NSString
        var drawArray = selectionName.componentsSeparatedByString("Draw")
        
        if(drawArray.count > 1){
            selection = matchSelection.getDrawSelection()
        }
        else{
            
            var winnerTeam      = selectionName
            if(selectionName.length > 6){
                winnerTeam = selectionName.substringToIndex(selectionName.length-6)
            }
            
            var title = matchSelection.pfMatche.valueForKey("title") as NSString
            var teams = title.componentsSeparatedByString(" V ") as NSArray
            
            if(teams.firstObject as NSString == winnerTeam){
                
                selection = matchSelection.getHomeSelection()
            }
            else{
                
                selection = matchSelection.getAwaySelection()
            }
            
        }
        
        selection.setValue(oldBet, forKey: "oldBet")
        
        return selection
    }
    
}