//
//  GSMatchSelection.swift
//  GrandSlam
//
//  Created by Explocial 6 on 16/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


class GSMatcheSelection {
    
    var pfMatche: PFObject
    var pfCustomLeague: PFObject
    var correctScoreSelections: NSArray!
    var matchBettingSelections: NSArray!
    
    var bestCorrectScoreSelection:NSDictionary!
    
    

    func getDrawSelection() -> NSDictionary{
        
        for selection in self.matchBettingSelections{
            
            if( ((selection as NSDictionary).objectForKey("outcomeMeaningMinorCode") as NSString) == "D"){
                return (selection as NSDictionary)
            }
        }
        return NSDictionary()
    }
    
    func getHomeSelection() -> NSDictionary{
        
        for selection in self.matchBettingSelections{
            
            if( ((selection as NSDictionary).objectForKey("outcomeMeaningMinorCode") as NSString) == "H"){
                return (selection as NSDictionary)
            }
        }
        return NSDictionary()
    }
    
    func getAwaySelection() -> NSDictionary{
        
        for selection in self.matchBettingSelections{
            
            if( ((selection as NSDictionary).objectForKey("outcomeMeaningMinorCode") as NSString) == "A"){
                return (selection as NSDictionary)
            }
        }
        return NSDictionary()
    }

    init(matche: PFObject, customLeague:PFObject) {
        
        pfMatche = matche
        pfCustomLeague = customLeague
        
        if(matche.objectForKey("CorrectScore") == nil || matche.objectForKey("MatchBetting") == nil){
            
            if(matche.objectForKey("CorrectScore") != nil){
                correctScoreSelections = matche.objectForKey("CorrectScore") as NSArray
                bestCorrectScoreSelection = getBestCorrectScoreSelection()
            }
            if(matche.objectForKey("MatchBetting") != nil){
                matchBettingSelections = matche.objectForKey("MatchBetting") as NSArray
            }
            loadMatcheSelection(customLeague)
        }
        else{
            correctScoreSelections = matche.objectForKey("CorrectScore") as NSArray
            matchBettingSelections = matche.objectForKey("MatchBetting") as NSArray
            bestCorrectScoreSelection = getBestCorrectScoreSelection()
        }
    }
    
    
    func loadMatcheSelection(customLeague:PFObject){
        
        var leagueName      = customLeague.valueForKey("leagueTitle") as NSString
        var league:PFObject = (GSLeague.getLeagueFromCache(leagueName) as GSLeague).pfLeague
        
        var classKey:NSString   = String(Int(league["classKey"] as NSNumber))
        var typeKey:NSString    = String(Int(league["typeKey"] as NSNumber))
        var subTypeKey:NSString = String(Int(league["subTypeKey"] as NSNumber))
        var matchKey:NSString   = String(Int(pfMatche["eventKey"] as NSNumber))
        var urlString:NSString = URL_ROOT+"v2/sportsbook-api/classes/"+classKey+"/types/"+typeKey+"/subtypes/"+subTypeKey+"/events/"+matchKey
        urlString = urlString+"?locale=en-GB&"+"api-key="+LADBROKES_API_KEY+"&expand=selection"
        
        SVProgressHUD.show()
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {  (data, response, error) in
            
            var err: NSError?
            var jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as NSDictionary
            
            if(jsonData["event"] != nil){
                
                var marketsEventArray:NSArray = ((jsonData["event"] as NSDictionary)["markets"] as NSDictionary)["market"] as NSArray
                
                var marketJson:NSDictionary
                for marketJson in marketsEventArray {
                    
                    if((marketJson["marketName"] as NSString == "Correct score")){
                        
                        self.correctScoreSelections = (marketJson["selections"] as NSDictionary)["selection"] as NSArray
                        self.pfMatche["CorrectScore"] = self.correctScoreSelections
                        self.bestCorrectScoreSelection = self.getBestCorrectScoreSelection()
                    }
                    
                    if((marketJson["marketName"] as NSString == "Match betting")){
                        
                        self.matchBettingSelections = (marketJson["selections"] as NSDictionary)["selection"] as NSArray
                        self.pfMatche["MatchBetting"] = self.matchBettingSelections
                    }
                }
                
                self.pfMatche.saveInBackgroundWithBlock({ (success, error) -> Void in
                    
                })
            }
            dispatch_after(1, dispatch_get_main_queue(), {
                 SVProgressHUD.dismiss()
            })
           
        }
        
        task.resume()
    }
    
    
    
    func getScoreCorrectSelectionByName(selectionName:NSString) -> NSDictionary{
        
        var retSelection:NSDictionary = [:]
        for selection in (self.correctScoreSelections as NSArray) {
            
            if(selection.objectForKey("selectionName") as NSString == selectionName){
                
                return selection as NSDictionary
            }
        }
        return retSelection
    }
    
    
    func getBestCorrectScoreSelection() -> NSDictionary{
        
        var retSelection:NSDictionary = [:]
        var bestValue: CGFloat = 0.0
        
        var i = 0
        for selection in (self.correctScoreSelections as NSArray) {
            
            var currentPrice = selection.objectForKey("currentPrice") as NSDictionary
            
            var denPrice = currentPrice.objectForKey("denPrice") as CGFloat
            var numPrice = currentPrice.objectForKey("numPrice") as CGFloat
            
            var percent: CGFloat = 0.0
            if(denPrice > numPrice){
                percent = denPrice / numPrice
            }
            else{
                percent = numPrice / denPrice
            }
            
            if(i == 0){
                bestValue = percent
                retSelection = selection as NSDictionary
            }
            else{
                if(percent < bestValue){
                    bestValue = percent
                    retSelection = selection as NSDictionary
                }
            }
            
            i++
        }
        return retSelection
    }
    
    
    func setPredictionTeamWin(leftScore:NSString, rightScore:NSString){
    
        var homeTeamScore = leftScore.intValue
        var awayTeamScore = rightScore.intValue
        
        if(homeTeamScore == awayTeamScore){
            pfMatche.incrementKey("drawPrediction")
        }
        else{
            if(homeTeamScore > awayTeamScore){
                pfMatche.incrementKey("homeTeamWinPrediction")
            }
            else{
                pfMatche.incrementKey("awayTeamWinPrediction")
            }
        }
        pfMatche.saveInBackground()
    }
    
    
    func percentThinkHomeTeamWin() -> CGFloat{
        
        var drawP:NSNumber = 0
        if(pfMatche["drawPrediction"] != nil){
            drawP = pfMatche["drawPrediction"] as NSNumber
        }
        var homeTeamWin:NSNumber = 0
        if(pfMatche["homeTeamWinPrediction"] != nil){
            homeTeamWin = pfMatche["homeTeamWinPrediction"] as NSNumber
        }
        var awayTeamWin:NSNumber = 0
        if(pfMatche["awayTeamWinPrediction"] != nil){
            awayTeamWin = pfMatche["awayTeamWinPrediction"] as NSNumber
        }
        
        return CGFloat(homeTeamWin)/(CGFloat(homeTeamWin)+CGFloat(drawP)+CGFloat(awayTeamWin))
    }
    
    func percentThinkDraw() -> CGFloat{
        
        var drawP:NSNumber = 0
        if(pfMatche["drawPrediction"] != nil){
            drawP = pfMatche["drawPrediction"] as NSNumber
        }
        var homeTeamWin:NSNumber = 0
        if(pfMatche["homeTeamWinPrediction"] != nil){
            homeTeamWin = pfMatche["homeTeamWinPrediction"] as NSNumber
        }
        var awayTeamWin:NSNumber = 0
        if(pfMatche["awayTeamWinPrediction"] != nil){
            awayTeamWin = pfMatche["awayTeamWinPrediction"] as NSNumber
        }
        
        return CGFloat(drawP)/(CGFloat(homeTeamWin)+CGFloat(drawP)+CGFloat(awayTeamWin))
    }
    
    func percentThinkAwayTeamWin() -> CGFloat{
        
        var drawP:NSNumber = 0
        if(pfMatche["drawPrediction"] != nil){
            drawP = pfMatche["drawPrediction"] as NSNumber
        }
        var homeTeamWin:NSNumber = 0
        if(pfMatche["homeTeamWinPrediction"] != nil){
            homeTeamWin = pfMatche["homeTeamWinPrediction"] as NSNumber
        }
        var awayTeamWin:NSNumber = 0
        if(pfMatche["awayTeamWinPrediction"] != nil){
            awayTeamWin = pfMatche["awayTeamWinPrediction"] as NSNumber
        }
        
        return CGFloat(awayTeamWin)/(CGFloat(homeTeamWin)+CGFloat(drawP)+CGFloat(awayTeamWin))
    }
    
    
    
    
    func getDateMatche() -> NSDate{
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var matcheDateString:NSString = self.pfMatche["eventDateTime"] as NSString
        matcheDateString = matcheDateString.stringByReplacingOccurrencesOfString("T", withString: " ")
        matcheDateString = matcheDateString.stringByReplacingOccurrencesOfString("Z", withString: "")
        return dateFormatter.dateFromString(matcheDateString)!
    }
    
}

