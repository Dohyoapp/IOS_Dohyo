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
    var score: NSString
    
    
    init(aMatchId: NSString, aSelection: NSDictionary, aScore: NSString) {
        matchId     = aMatchId
        selection   = aSelection
        score = aScore
    }
    
    
    
    class func getbetMatches(matches:NSArray, bets:NSArray) -> NSArray{
        /*
        var weekNumber = ""
        if(!Utils.isParseNull(league.pfLeague["weekNumber"])){
            weekNumber   = league.pfLeague["weekNumber"] as? String
        }
        */
        
        var returnArray = NSMutableArray()
        
        for match in matches{
            
            for bet in bets{
                
                var betMatchId:NSString = (bet as! GSBetSlip).matchId as! String
                if(betMatchId == match.objectId){
                    //may need to check buy week number

                    returnArray.addObject(match)
                }
            }
        }
        
        return returnArray
    }
    
    
    
    class func buildSlip(betSelections: NSArray){
        
        var betSlip = betSelections[0] as! NSDictionary
        var selection = betSlip.objectForKey("selection") as! NSDictionary
        var selectionKey = Int(selection.objectForKey("selectionKey") as! NSNumber)
        
        var urlString:String = URL_ROOT+"v2/betting-api/sportsbook/betslips/build"
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
            var jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as! NSDictionary
            
            var g = 0
        }
        
        task.resume()
        
    }
    
    
    
    
    
    class func goToLadBrokes(selections: NSArray){
        
        var selectionsKey = ""
        for selection in selections {
            //var currentPrice:NSDictionary!  = selection.objectForKey("currentPrice") as NSDictionary //denPrice = 1; numPrice = 100;
            var selectionKey:AnyObject!     = (selection as! NSDictionary).objectForKey("selectionKey")
            if(selectionKey != nil){
                var intSelectionKey = Int(selectionKey as! NSNumber)
                if(count(selectionsKey) > 1){
                    selectionsKey = String(format:"%@,%d", selectionsKey, intSelectionKey)
                }
                else{
                    selectionsKey = String(format:"%d", intSelectionKey)
                }
            }
        }
        
        
        if(count(selectionsKey) > 1){
            
            webViewController = GSWebViewController()
            
            var urlString = String(format:"https://betslip.ladbrokes.com/RemoteBetslip/bets/betslip.html?selections=%@&locale=en-GB",  selectionsKey)
            
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
            
            var selection       = getActualisedSelection(betSlip as! GSBetSlip, validMatches: validMatches)
            
            var oldBet:Bool = selection.objectForKey("oldBet") as! Bool
            if(!oldBet){
            
                var currentPrice = selection.objectForKey("currentPrice") as! NSDictionary
                var decimalPrice = currentPrice.objectForKey("decimalPrice") as! Double
                var denPrice = currentPrice.objectForKey("denPrice") as! Double
                var numPrice = currentPrice.objectForKey("numPrice") as! Double
                
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
        }
        
        var totalOddsString = NSString(format:"%f", totalOdds*100)
        var totalOddsArray = totalOddsString.componentsSeparatedByString(".")
        var aPGCD = Utils.findPGCD(totalOddsArray[0].integerValue, b:100)
        
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
            
            var matchPf = (aValidMatche as! GSMatcheSelection).pfMatche as PFObject
            if(matchPf.objectId == betSlip.matchId){
                matchSelection = aValidMatche as! GSMatcheSelection
                var matcheDate = GSCustomLeague.getDateMatche(matchPf)
                if(matcheDate.timeIntervalSinceDate(NSDate()) < 0){
                    oldBet = true
                }
            }
        }
        
        var selection       = betSlip.selection
        var selectionName   = selection.objectForKey("selectionName") as! String
        var drawArray = selectionName.componentsSeparatedByString("Draw")
        
        if(drawArray.count > 1){
            if(matchSelection != nil){
                selection = matchSelection.getDrawSelection()
            }
        }
        else{
            
            var winnerTeam      = selectionName
            if(count(selectionName) > 6){
                winnerTeam = (selectionName as NSString).substringToIndex(count(selectionName)-6)
            }
            
            if(matchSelection != nil){
                
                var title = matchSelection.pfMatche.valueForKey("title") as! String
                var teams = title.componentsSeparatedByString(" V ") as NSArray
                
                if(teams.firstObject as! String == winnerTeam){
                    
                    selection = matchSelection.getHomeSelection()
                }
                else{
                    
                    selection = matchSelection.getAwaySelection()
                }
                
            }
            
        }
        
        var newSelection = NSMutableDictionary(dictionary: selection)
        newSelection.setValue(oldBet, forKey: "oldBet")
        
        return newSelection
    }
    
}