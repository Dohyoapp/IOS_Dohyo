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
    
    
    var totalOdd:Float!
    
    var accumulatorLabel:UILabel!
    var stakeLabel:UILabel!
    var returnLabel:UILabel!
    var sliderStake:UISlider!
    
    var socialShareViewController : GSSocialShareViewController!
    
    
    func sliderValueDidChange(sender: UISlider) {

        var currentValue   = Int(sender.value)
        stakeLabel.text    = String(format:"Stake : £%d", currentValue)
        
        if(totalOdd > 0){
            returnLabel.text   = String(format:"Returns : £%0.2f", totalOdd*Float(currentValue))
        }
    }
    
    
    
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        var leaderBoardButton = UIButton(frame: CGRectMake(0, YSTART, 320, 35))
        leaderBoardButton.setTitle("See Leaderboard & Prize", forState: .Normal)
        leaderBoardButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        leaderBoardButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        leaderBoardButton.backgroundColor = SPECIALBLUE
        leaderBoardButton.addTarget(self, action:"leaderBoardTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(leaderBoardButton)
        

        
        var betSummaryView = UIView(frame:CGRectMake(0, YSTART+35, 320, CELLHEIGHT))
        betSummaryView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(betSummaryView)
        
        var goodLuckLabel    = UILabel(frame:CGRectMake(0, 0, 320, 50))
        goodLuckLabel.text   = "Your accumulator is based on your match result predictions"//"GOOD LUCK!"
        goodLuckLabel.numberOfLines = 2
        goodLuckLabel.textAlignment = .Center
        goodLuckLabel.font   = UIFont(name:FONT3, size:15)
        goodLuckLabel.textColor = SPECIALBLUE
        betSummaryView.addSubview(goodLuckLabel)
        
        var picksLabel    = UILabel(frame:CGRectMake(0, 40, 320, 38))
        picksLabel.text   = "Your picks have been submitted."
        picksLabel.textAlignment = .Center
        picksLabel.font   = UIFont(name:FONT3, size:15)
        picksLabel.textColor = SPECIALBLUE
        betSummaryView.addSubview(picksLabel)

        
        
        accumulatorLabel        = UILabel(frame:CGRectMake(0, 60, 320, 38))
        accumulatorLabel.text   = "Your accumulator odds:"
        accumulatorLabel.textAlignment = .Center
        accumulatorLabel.font   = UIFont(name:FONT3, size:15)
        accumulatorLabel.textColor = SPECIALBLUE
        betSummaryView.addSubview(accumulatorLabel)
        
        
        sliderStake = UISlider(frame: CGRectMake(140, 142, 140, 20))
        sliderStake.layer.borderColor = SPECIALBLUE.CGColor
        sliderStake.layer.borderWidth = 1
        sliderStake.setMaximumTrackImage(Utils.getImageWithColor(UIColor.whiteColor(), size: CGSize(width: 100, height: 20)), forState:.Normal)
        sliderStake.setMinimumTrackImage(Utils.getImageWithColor(UIColor.whiteColor(), size: CGSize(width: 100, height: 20)), forState:.Normal)
        sliderStake.setThumbImage(Utils.getImageWithColor(SPECIALBLUE, size: CGSize(width: 10, height: 26)), forState:.Normal)
        sliderStake.maximumValue = Float(100)
        sliderStake.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
        betSummaryView.addSubview(sliderStake)
        sliderStake.value = Float(5)
        sliderStake.setNeedsDisplay()
        
        
        stakeLabel    = UILabel(frame:CGRectMake(50, 135, 85, 38))
        stakeLabel.text   = String(format:"Stake : £%d", 5)
        stakeLabel.font   = UIFont(name:FONT3, size:15)
        stakeLabel.textColor = SPECIALBLUE
        betSummaryView.addSubview(stakeLabel)

        

        returnLabel        = UILabel(frame:CGRectMake(50, 98, 170, 38))
        returnLabel.text   = "Returns : £20.00"
        returnLabel.font   = UIFont(name:FONT3, size:15)
        returnLabel.textColor = SPECIALBLUE
        betSummaryView.addSubview(returnLabel)
        
        
        /*
        var yourPicksLabel    = UILabel(frame:CGRectMake(0, 122, 320, 34))
        yourPicksLabel.text   = "Your picks"
        yourPicksLabel.textAlignment = .Center
        yourPicksLabel.font   = UIFont(name:FONT3, size:15)
        yourPicksLabel.textColor = SPECIALBLUE
        betSummaryView.addSubview(yourPicksLabel)
        */
        
        var stakeButton = UIButton(frame: CGRectMake(205, 98, 90, 38))
        stakeButton.titleLabel!.font = UIFont(name:FONT2, size:18)
        stakeButton.backgroundColor = UIColor.whiteColor()
        stakeButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        stakeButton.setTitle("Bet Now", forState: .Normal)
        stakeButton.addTarget(self, action:"stakeButtonTap:", forControlEvents:.TouchUpInside)
        betSummaryView.addSubview(stakeButton)
        
        
        var blueLine = UIView(frame:CGRectMake(0, 180, 320, 1))
        blueLine.backgroundColor = SPECIALBLUE
        betSummaryView.addSubview(blueLine)
        
        
        scrollView = UIScrollView(frame:CGRectMake(0, YSTART+52+CELLHEIGHT, 320, self.view.frame.size.height - 52 - YSTART - CELLHEIGHT))
        self.view.addSubview(scrollView)
        
        currentBets = customLeague.hasBetSlip()
        self.loadViewWithMatchs()
    }
    
    
    
    func loadViewWithMatchs(){
        
        var leagueName  = customLeague.pfCustomLeague.valueForKey("leagueTitle") as NSString
        var league      = GSLeague.getLeagueFromCache(leagueName)
        
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
        
        self.scrollView.contentSize = CGSizeMake(320, (CELLHEIGHT*count)+100)
        
        var oddsArray       = GSBetSlip.oddsCalculator(currentBets, validMatches: validMatches)
        var totalOddLeft    = oddsArray.firstObject as Double
        var totalOddRight   = oddsArray.lastObject as Double
        
        totalOdd = Float(totalOddLeft)/Float(totalOddRight)
        
        accumulatorLabel.text   = NSString(format:"Your accumulator odds: %0.0f/%0.0f", totalOddLeft-totalOddRight, totalOddRight)
        sliderValueDidChange(sliderStake)
        
        

        socialShareViewController = GSSocialShareViewController()
        socialShareViewController.customLeagueId = customLeague.pfCustomLeague.objectId
        socialShareViewController.view.frame = CGRectMake(0, 20+(CELLHEIGHT*count), 320, 40)
        self.scrollView.addSubview(socialShareViewController.view)
        
    }
    
    
    
    func createMatcheCell(matche:GSMatcheSelection, num:CGFloat, betSlip: GSBetSlip){
        
        var cell = UIScrollView(frame:CGRectMake(0, num*CELLHEIGHT, 320, CELLHEIGHT))
        cell.pagingEnabled = true
        cell.showsHorizontalScrollIndicator = false
        cell.tag = Int(num)
        scrollView.addSubview(cell)
        
        cell.addSubview(createMatchView(matche, betSlip:betSlip))
        
        cell.addSubview(GSCustomLeagueViewControlelr.createCrowdPredictionView(matche, delegate: self))
        
        var matcheDate = matche.getDateMatche()
        if(matcheDate.timeIntervalSinceDate(NSDate()) < 0){
            
            var greyView = UIView(frame:CGRectMake(0, 1, 640, CELLHEIGHT-2))
            greyView.backgroundColor = UIColor.grayColor()
            greyView.alpha = 0.3
            cell.addSubview(greyView)
        }
        
        cell.contentSize = CGSizeMake(640, CELLHEIGHT)
    }
    
    
    
    
    
    func createMatchView(matche:GSMatcheSelection, betSlip: GSBetSlip) -> UIView{
        
        var matchView = UIView(frame:CGRectMake(0, 0, 320, CELLHEIGHT))
        matchView.backgroundColor = UIColor.whiteColor()
        
        var matchTitle = matche.pfMatche.valueForKey("title") as NSString
        GSCustomLeagueViewControlelr.createTopView(matchView, title: matchTitle, isCrowd:false)
        
        var leftScoreLabel  = UILabel(frame:CGRectMake(95, 44, 60, 100))
        leftScoreLabel.tag  = 888
        leftScoreLabel.text = "0"
        leftScoreLabel.textAlignment = .Center
        leftScoreLabel.font = UIFont(name:FONT2, size:44)
        leftScoreLabel.textColor = SPECIALBLUE
        matchView.addSubview(leftScoreLabel)
        
        var centerScoreLabel    = UILabel(frame:CGRectMake(127, 64, 60, 60))
        centerScoreLabel.text   = "-"
        centerScoreLabel.textAlignment = .Center
        centerScoreLabel.font   = UIFont(name:FONT2, size:44)
        centerScoreLabel.textColor = SPECIALBLUE
        matchView.addSubview(centerScoreLabel)
        
        var rightScoreLabel     = UILabel(frame:CGRectMake(160, 44, 60, 100))
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
        
        
        var selection       = GSBetSlip.getActualisedSelection(betSlip, validMatches: validMatches)
        
        var currentPrice = selection.objectForKey("currentPrice") as NSDictionary
        var denPrice = currentPrice.objectForKey("denPrice") as CGFloat
        var numPrice = currentPrice.objectForKey("numPrice") as CGFloat
        
        var currentOdd = String(Int(numPrice))+"/"+String(Int(denPrice))

        
        var currentOddLabel     = UILabel(frame:CGRectMake(100, 123, 50, 40))
        currentOddLabel.text    = currentOdd
        currentOddLabel.textAlignment = .Center
        currentOddLabel.font    = UIFont(name:FONT2, size:18)
        currentOddLabel.textColor = SPECIALBLUE
        matchView.addSubview(currentOddLabel)
        
        var currentOddButton = UIButton(frame: CGRectMake(165, 123, 70, 40))
        currentOddButton.titleLabel!.font = UIFont(name:FONT2, size:16)
        currentOddButton.backgroundColor = UIColor.whiteColor()
        currentOddButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        currentOddButton.setTitle("Bet Now", forState: .Normal)
        currentOddButton.addTarget(self, action:"currentOddButtonTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(currentOddButton)
        
        return matchView
    }
    
    
    func leaderBoardTap(sender: UIButton!){
        
        var leaderBoardScrollView = GSLeaderBoardScrollView(frame:self.view.frame, customLeague:customLeague)
        self.view.addSubview(leaderBoardScrollView)
    }
    
    func getScoreFromSelection(betSlip: GSBetSlip, matchTitle: NSString) -> NSArray{
    
        var selection       = betSlip.selection
        var selectionName   = selection.objectForKey("selectionName") as NSString
        var winnerTeam      = selectionName
        if(selectionName.length > 6){
            winnerTeam = selectionName.substringToIndex(selectionName.length-6)
        }
        
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
        
        var selection:NSDictionary  = (currentBets[row] as GSBetSlip).selection
        GSBetSlip.goToLadBrokes([selection])
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        matche.track()
    }
    
    
    
    
    func firstTeamOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.getHomeSelection()
        GSBetSlip.goToLadBrokes([selection])
        
        matche.track()
    }
    
    func secondTeamOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.getAwaySelection()
        GSBetSlip.goToLadBrokes([selection])
        
        matche.track()
    }
    
    func drawOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.getDrawSelection()
        GSBetSlip.goToLadBrokes([selection])
        
        matche.track()
    }


    func stakeButtonTap(sender: UIButton!){
        
        var selections = NSMutableArray()
        var matchsId:NSString = ""
        for betSlip in currentBets{
        
            //var selection:NSDictionary  = (betSlip as GSBetSlip).selection
            var selection       = GSBetSlip.getActualisedSelection(betSlip as GSBetSlip, validMatches: validMatches)
            if(!(selection.objectForKey("oldBet") as Bool)){
                selections.addObject(selection)
                if(matchsId.isEqualToString("")){
                    matchsId = (betSlip as GSBetSlip).matchId
                }
                else{
                    matchsId = NSString(format:"%@, %@", matchsId, (betSlip as GSBetSlip).matchId)
                }
            }
        }
        GSBetSlip.goToLadBrokes(selections)
        
        if(!matchsId.isEqualToString("")){
            
            var currentValue   = Int(sliderStake.value)
            var oddString:NSString =  String(format:"%0.2f", totalOdd)
            Mixpanel.sharedInstance().track("0108 - Accumulator Bet Now", properties: [
                "user": PFUser.currentUser()["username"],
                "league": customLeague.pfCustomLeague["name"],
                "match": matchsId,
                "accumulator odds": oddString,
                "accumulator money in": String(format:"%0.2f", totalOdd*Float(currentValue))
            ])
        }
    }

    
    func crowdLabelTap(sender: UIButton!){
        
        var crowdPredictionView = (sender as UIView).superview!
        var cell = crowdPredictionView.superview as UIScrollView
        cell.setContentOffset(CGPointMake(320, 0), animated:true)
    }
    
    func backTap(sender: UIButton!){
        
        var crowdPredictionView = (sender as UIView).superview!
        var cell = crowdPredictionView.superview as UIScrollView
        cell.setContentOffset(CGPointMake(0, 0), animated:true)
    }
}