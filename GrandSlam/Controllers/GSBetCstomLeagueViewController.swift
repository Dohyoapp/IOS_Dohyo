//
//  GSBetCstomLeagueViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 17/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation




class GSBetCstomLeagueViewController: UIViewController, LeagueCaller, CrowdPredictionProtocol {
    
    var scrollView:UIScrollView!
    
    var customLeague:GSCustomLeague!
    
    var validMatches:NSMutableArray!
    var currentBets:NSArray!
    
    let yStart = NAVIGATIONBAR_HEIGHT+20
    
    
    var gsLeaderBoardViewController:GSLeaderBoardViewController!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        var leaderBoardButton = UIButton(frame: CGRectMake(10, yStart, 300, 33))
        leaderBoardButton.setTitle("See Leaderboard", forState: .Normal)
        leaderBoardButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        leaderBoardButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        leaderBoardButton.backgroundColor = SPECIALBLUE
        leaderBoardButton.addTarget(self, action:"leaderBoardTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(leaderBoardButton)
        

        
        var betSummaryView = UIView(frame:CGRectMake(0, yStart+35, 320, CELLHEIGHT))
        betSummaryView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(betSummaryView)
        
        var goodLuckLabel    = UILabel(frame:CGRectMake(0, 0, 320, 38))
        goodLuckLabel.text   = "GOOD LUCK!"
        goodLuckLabel.textAlignment = .Center
        goodLuckLabel.font   = UIFont(name:FONT2, size:18)
        goodLuckLabel.textColor = SPECIALBLUE
        betSummaryView.addSubview(goodLuckLabel)
        
        scrollView = UIScrollView(frame:CGRectMake(0, yStart+36+CELLHEIGHT, 320, self.view.frame.size.height - 36 - yStart - CELLHEIGHT))
        self.view.addSubview(scrollView)
        
        currentBets = customLeague.hasBetSlip()
        self.loadViewWithMatchs()
    }
    
    
    
    func loadViewWithMatchs(){
        
        var leagueName = customLeague.pfCustomLeague.valueForKey("leagueTitle") as NSString
        var league = GSLeague.getLeagueFromCache(leagueName)
        
        if(league.matches == nil){
            GSLeague.getLeagues(self)
            return
        }
        
        
        validMatches = NSMutableArray()
        var tempMatches:NSArray = GSBetSlip.getbetMatches(league.matches, bets: currentBets)
        for matche in tempMatches{
            
            validMatches.addObject(GSMatcheSelection(matche: matche as PFObject, customLeague: customLeague.pfCustomLeague))
        }
        
        var count:CGFloat = 0
        for validMatche in validMatches{
            
            self.createMatcheCell(validMatche as GSMatcheSelection, num:count, betSlip: currentBets[Int(count)] as GSBetSlip)
            count += 1
        }
        
        self.scrollView.contentSize = CGSizeMake(320, (CELLHEIGHT*count))
    }
    
    
    
    func createMatcheCell(matche:GSMatcheSelection, num:CGFloat, betSlip: GSBetSlip){
        
        var cell = UIScrollView(frame:CGRectMake(0, num*CELLHEIGHT, 320, CELLHEIGHT))
        cell.pagingEnabled = true
        cell.showsHorizontalScrollIndicator = false
        cell.tag = Int(num)
        scrollView.addSubview(cell)
        
        cell.addSubview(createMatchView(matche, betSlip:betSlip))
        
        cell.addSubview(GSCustomLeagueViewControlelr.createCrowdPredictionView(matche, delegate: self))
        
        cell.contentSize = CGSizeMake(640, CELLHEIGHT)
    }
    
    
    func createMatchView(matche:GSMatcheSelection, betSlip: GSBetSlip) -> UIView{
        
        var matchView = UIView(frame:CGRectMake(0, 0, 320, CELLHEIGHT))
        matchView.backgroundColor = UIColor.whiteColor()
        
        var matchTitle = matche.pfMatche.valueForKey("title") as NSString
        GSCustomLeagueViewControlelr.createTopView(matchView, title: matchTitle, isCrowd:false)
        
        var leftScoreLabel  = UILabel(frame:CGRectMake(95, 26, 60, 100))
        leftScoreLabel.tag  = 888
        leftScoreLabel.text = "0"
        leftScoreLabel.textAlignment = .Center
        leftScoreLabel.font = UIFont(name:FONT2, size:44)
        leftScoreLabel.textColor = SPECIALBLUE
        matchView.addSubview(leftScoreLabel)
        
        var centerScoreLabel    = UILabel(frame:CGRectMake(127, 40, 60, 60))
        centerScoreLabel.text   = "-"
        centerScoreLabel.textAlignment = .Center
        centerScoreLabel.font   = UIFont(name:FONT2, size:44)
        centerScoreLabel.textColor = SPECIALBLUE
        matchView.addSubview(centerScoreLabel)
        
        var rightScoreLabel     = UILabel(frame:CGRectMake(160, 26, 60, 100))
        rightScoreLabel.tag     = 999
        rightScoreLabel.text = "0"
        rightScoreLabel.textAlignment = .Center
        rightScoreLabel.font    = UIFont(name:FONT2, size:44)
        rightScoreLabel.textColor = SPECIALBLUE
        matchView.addSubview(rightScoreLabel)

        var scores = self.getScoreFromSelection(betSlip, matchTitle: matchTitle)
        if(scores.count > 1){
            
            leftScoreLabel.text     = scores.firstObject as NSString
            rightScoreLabel.text    = scores.lastObject as NSString
        }
        
        
        var selection       = betSlip.selection
        
        var currentPrice = selection.objectForKey("currentPrice") as NSDictionary
        var denPrice = currentPrice.objectForKey("denPrice") as CGFloat
        var numPrice = currentPrice.objectForKey("numPrice") as CGFloat
        
        var currentOdd = String(Int(numPrice))+"/"+String(Int(denPrice))
        
        var currentOddLabel     = UILabel(frame:CGRectMake(110, 100, 50, 40))
        currentOddLabel.text    = currentOdd
        currentOddLabel.textAlignment = .Center
        currentOddLabel.font    = UIFont(name:FONT2, size:18)
        currentOddLabel.textColor = SPECIALBLUE
        matchView.addSubview(currentOddLabel)
        
        var currentOddButton = UIButton(frame: CGRectMake(175, 106, 70, 28))
        currentOddButton.titleLabel!.font = UIFont(name:FONT3, size:14)
        currentOddButton.backgroundColor = SPECIALBLUE
        currentOddButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        currentOddButton.setTitle("Bet Now", forState: .Normal)
        currentOddButton.addTarget(self, action:"currentOddButtonTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(currentOddButton)
        
        return matchView
    }
    
    
    func leaderBoardTap(sender: UIButton!){
        
        gsLeaderBoardViewController = GSLeaderBoardViewController()
        gsLeaderBoardViewController.customLeague = customLeague
        gsLeaderBoardViewController.customLeague.pfCustomLeague.fetch()
        self.view.addSubview(gsLeaderBoardViewController.view)
    }
    
    func getScoreFromSelection(betSlip: GSBetSlip, matchTitle: NSString) -> NSArray{
    
        var selection       = betSlip.selection
        var selectionName   = selection.objectForKey("selectionName") as NSString
        var winnerTeam      = selectionName.substringToIndex(selectionName.length-6)
        
        var teams = matchTitle.componentsSeparatedByString(" V ") as NSArray
        
        var score = selectionName.substringFromIndex(selectionName.length-5)
        var scores = score.componentsSeparatedByString(" - ") as NSArray
        
        if(teams.firstObject as NSString == winnerTeam){
            
            return scores
        }
        else{
            
            return [scores.lastObject as NSString, scores.firstObject as NSString]
        }
    }
    
    
    func currentOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        
        var selection:NSDictionary  = (currentBets[row] as GSBetSlip).selection
        GSBetSlip.goToLadBrokes(selection)
    }
    
    
    
    func oddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var bestSelection:NSDictionary  = matche.bestCorrectScoreSelection
        GSBetSlip.goToLadBrokes(bestSelection)
    }
    
    func firstTeamOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.matchBettingSelections[0] as NSDictionary
        GSBetSlip.goToLadBrokes(selection)
    }
    
    func secondTeamOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.matchBettingSelections[1] as NSDictionary
        GSBetSlip.goToLadBrokes(selection)
    }
    
    func drawOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.matchBettingSelections[2] as NSDictionary
        GSBetSlip.goToLadBrokes(selection)
    }
}