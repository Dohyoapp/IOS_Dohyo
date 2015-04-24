//
//  GSMatchSelection.swift
//  GrandSlam
//
//  Created by Explocial 6 on 16/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


class GSMatcheSelection: AnyObject {
    
    var pfMatche: PFObject
    var pfCustomLeague: PFObject
    var correctScoreSelections: NSArray!
    var matchBettingSelections: NSArray!
    
    var bestCorrectScoreSelection:NSDictionary!
    
    

    func getDrawSelection() -> NSDictionary{
        
        if(self.matchBettingSelections == nil){
            return NSDictionary()
        }
        for selection in self.matchBettingSelections{
            
            if( ((selection as! NSDictionary).objectForKey("outcomeMeaningMinorCode") as! String) == "D"){
                return (selection as! NSDictionary)
            }
        }
        return NSDictionary()
    }
    
    func getHomeSelection() -> NSDictionary{
        
        if(self.matchBettingSelections == nil){
            return NSDictionary()
        }
        for selection in self.matchBettingSelections{
            
            if( ((selection as! NSDictionary).objectForKey("outcomeMeaningMinorCode") as! String) == "H"){
                return (selection as! NSDictionary)
            }
        }
        return NSDictionary()
    }
    
    func getAwaySelection() -> NSDictionary{
        
        if(self.matchBettingSelections == nil){
            return NSDictionary()
        }
        for selection in self.matchBettingSelections{
            
            if( ((selection as! NSDictionary).objectForKey("outcomeMeaningMinorCode") as! String) == "A"){
                return (selection as! NSDictionary)
            }
        }
        return NSDictionary()
    }

    init(matche: PFObject, customLeague:PFObject) {
        
        pfMatche = matche
        pfCustomLeague = customLeague
        
        if( Utils.isParseNull(matche.objectForKey("CorrectScore")) ||  Utils.isParseNull(matche.objectForKey("MatchBetting"))){
            
            if( !Utils.isParseNull(matche.objectForKey("CorrectScore"))){
                correctScoreSelections = matche.objectForKey("CorrectScore") as! NSArray
                bestCorrectScoreSelection = getBestCorrectScoreSelection()
            }
            if( !Utils.isParseNull(matche.objectForKey("MatchBetting"))){
                matchBettingSelections = matche.objectForKey("MatchBetting") as! NSArray
            }
            loadMatcheSelection(customLeague)
        }
        else{
            correctScoreSelections = matche.objectForKey("CorrectScore") as! NSArray
            matchBettingSelections = matche.objectForKey("MatchBetting") as! NSArray
            bestCorrectScoreSelection = getBestCorrectScoreSelection()
        }
    }
    
    
    func loadMatcheSelection(customLeague:PFObject){
        
        var leagueName      = customLeague.valueForKey("leagueTitle") as! String
        var league:PFObject = (GSLeague.getLeagueFromCache(leagueName) as GSLeague).pfLeague
        
        var classKey   = String(format:"%d", (league["classKey"] as! NSNumber))
        var typeKey    = String(format:"%d",(league["typeKey"] as! NSNumber))
        var subTypeKey = String(format:"%d",(league["subTypeKey"] as! NSNumber))
        var matchKey   = String(format:"%d",(pfMatche["eventKey"] as! NSNumber))
        var urlString:String = URL_ROOT+"v2/sportsbook-api/classes/"+classKey+"/types/"+typeKey+"/subtypes/"+subTypeKey+"/events/"+matchKey
        urlString = urlString+"?locale=en-GB&"+"api-key="+LADBROKES_API_KEY+"&expand=selection"
        
        SVProgressHUD.show()
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {  (data, response, error) in
            
            var err: NSError?
            var jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as! NSDictionary
            
            if(jsonData["event"] != nil){
                
                var marketsEventArray:NSArray = ((jsonData["event"] as! NSDictionary)["markets"] as! NSDictionary)["market"] as! NSArray
                
                var marketJson:NSDictionary
                for marketJson in marketsEventArray {
                    
                    if((marketJson["marketName"] as! String == "Correct score")){
                        
                        self.correctScoreSelections = (marketJson["selections"] as! NSDictionary)["selection"] as! NSArray
                        self.pfMatche["CorrectScore"] = self.correctScoreSelections
                        self.bestCorrectScoreSelection = self.getBestCorrectScoreSelection()
                    }
                    
                    if((marketJson["marketName"] as! String == "Match betting")){
                        
                        self.matchBettingSelections = (marketJson["selections"] as! NSDictionary)["selection"] as! NSArray
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
        
        if(self.correctScoreSelections == nil){
            return retSelection
        }
        
        for selection in (self.correctScoreSelections as NSArray) {
            
            if(selection.objectForKey("selectionName") as! String == selectionName){
                
                return selection as! NSDictionary
            }
        }
        return retSelection
    }
    
    
    func getBestCorrectScoreSelection() -> NSDictionary{
        
        var retSelection:NSDictionary = [:]
        var bestValue: CGFloat = 0.0
        
        var i = 0
        for selection in (self.correctScoreSelections as NSArray) {
            
            var currentPrice = selection.objectForKey("currentPrice") as! NSDictionary
            
            var denPrice = currentPrice.objectForKey("denPrice") as! CGFloat
            var numPrice = currentPrice.objectForKey("numPrice") as! CGFloat
            
            var percent: CGFloat = 0.0
            if(denPrice > numPrice){
                percent = denPrice / numPrice
            }
            else{
                percent = numPrice / denPrice
            }
            
            if(i == 0){
                bestValue = percent
                retSelection = selection as! NSDictionary
            }
            else{
                if(percent < bestValue){
                    bestValue = percent
                    retSelection = selection as! NSDictionary
                }
            }
            
            i++
        }
        return retSelection
    }
    
    
    func setPredictionTeamWin(leftScore:String, rightScore:String){
    
        var homeTeamScore = leftScore.toInt()
        var awayTeamScore = rightScore.toInt()
        
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
        if( !Utils.isParseNull(pfMatche["drawPrediction"]) ){
            drawP = pfMatche["drawPrediction"] as! NSNumber
        }
        var homeTeamWin:NSNumber = 0
        if(!Utils.isParseNull(pfMatche["homeTeamWinPrediction"])){
            homeTeamWin = pfMatche["homeTeamWinPrediction"] as! NSNumber
        }
        var awayTeamWin:NSNumber = 0
        if(!Utils.isParseNull(pfMatche["awayTeamWinPrediction"])){
            awayTeamWin = pfMatche["awayTeamWinPrediction"] as! NSNumber
        }
        
        return CGFloat(homeTeamWin)/(CGFloat(homeTeamWin)+CGFloat(drawP)+CGFloat(awayTeamWin))
    }
    
    func percentThinkDraw() -> CGFloat{
        
        var drawP:NSNumber = 0
        if(!Utils.isParseNull(pfMatche["drawPrediction"])){
            drawP = pfMatche["drawPrediction"] as! NSNumber
        }
        var homeTeamWin:NSNumber = 0
        if(!Utils.isParseNull(pfMatche["homeTeamWinPrediction"])){
            homeTeamWin = pfMatche["homeTeamWinPrediction"] as! NSNumber
        }
        var awayTeamWin:NSNumber = 0
        if(!Utils.isParseNull(pfMatche["awayTeamWinPrediction"])){
            awayTeamWin = pfMatche["awayTeamWinPrediction"] as! NSNumber
        }
        
        return CGFloat(drawP)/(CGFloat(homeTeamWin)+CGFloat(drawP)+CGFloat(awayTeamWin))
    }
    
    func percentThinkAwayTeamWin() -> CGFloat{
        
        var drawP:NSNumber = 0
        if(!Utils.isParseNull(pfMatche["drawPrediction"])){
            drawP = pfMatche["drawPrediction"] as! NSNumber
        }
        var homeTeamWin:NSNumber = 0
        if(!Utils.isParseNull(pfMatche["homeTeamWinPrediction"])){
            homeTeamWin = pfMatche["homeTeamWinPrediction"] as! NSNumber
        }
        var awayTeamWin:NSNumber = 0
        if(!Utils.isParseNull(pfMatche["awayTeamWinPrediction"])){
            awayTeamWin = pfMatche["awayTeamWinPrediction"] as! NSNumber
        }
        
        return CGFloat(awayTeamWin)/(CGFloat(homeTeamWin)+CGFloat(drawP)+CGFloat(awayTeamWin))
    }
    
    
    
    
    func getDateMatche() -> NSDate{
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var matcheDateString = self.pfMatche["eventDateTime"] as! String
        matcheDateString = matcheDateString.stringByReplacingOccurrencesOfString("T", withString: " ")
        matcheDateString = matcheDateString.stringByReplacingOccurrencesOfString("Z", withString: "")
        return dateFormatter.dateFromString(matcheDateString)!
    }
    
    
    func track(){
        
        Mixpanel.sharedInstance().track("0107 - Bet Now", properties: [
            "user": PFUser.currentUser()["username"],
            "league": self.pfCustomLeague["name"],
            "match": self.pfMatche["title"]
            ])
    }
    
}

