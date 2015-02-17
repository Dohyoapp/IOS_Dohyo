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
            loadMatcheSelection(matche, customLeague: customLeague)
        }
        else{
            correctScoreSelections = matche.objectForKey("CorrectScore") as NSArray
            matchBettingSelections = matche.objectForKey("MatchBetting") as NSArray
            bestCorrectScoreSelection = getBestCorrectScoreSelection()
        }
    }
    
    
    func loadMatcheSelection(matche:PFObject, customLeague:PFObject){
        
        var leagueName      = customLeague.valueForKey("leagueTitle") as NSString
        var league:PFObject = (GSLeague.getLeagueFromCache(leagueName) as GSLeague).pfLeague
        
        var classKey:NSString   = String(Int(league["classKey"] as NSNumber))
        var typeKey:NSString    = String(Int(league["typeKey"] as NSNumber))
        var subTypeKey:NSString = String(Int(league["subTypeKey"] as NSNumber))
        var matchKey:NSString   = String(Int(matche["eventKey"] as NSNumber))
        var urlMatcheSelection:NSString = URL_ROOT+"v2/sportsbook-api/classes/"+classKey+"/types/"+typeKey+"/subtypes/"+subTypeKey+"/events/"+matchKey
        urlMatcheSelection = urlMatcheSelection+"?locale=en-GB&"+"api-key="+LADBROKES_API_KEY+"&expand=selection"
        
        
        var dataArray:NSArray!
        
        SVProgressHUD.show()
        var request = NSMutableURLRequest(URL: NSURL(string: urlMatcheSelection)!)
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
                        matche["CorrectScore"] = self.correctScoreSelections
                        self.bestCorrectScoreSelection = self.getBestCorrectScoreSelection()
                    }
                    
                    if((marketJson["marketName"] as NSString == "Match betting")){
                        
                        self.matchBettingSelections = (marketJson["selections"] as NSDictionary)["selection"] as NSArray
                        matche["MatchBetting"] = self.matchBettingSelections
                    }
                }
                
                matche.saveInBackgroundWithBlock({ (success, error) -> Void in
                    
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
    
}

