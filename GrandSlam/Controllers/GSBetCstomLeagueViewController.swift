//
//  GSBetCstomLeagueViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 17/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation




class GSBetCstomLeagueViewController: UIViewController, LeagueCaller {
    
    var scrollView:UIScrollView!
    
    var customLeague:GSCustomLeague!
    
    var validMatches:NSMutableArray!
    
    let yStart = NAVIGATIONBAR_HEIGHT+20
    
    
    var webViewController:GSWebViewController!
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
        
        var currentBetSlip: PFObject = customLeague.hasBetSlip() as PFObject
        self.loadViewWithMatchs(currentBetSlip["bets"] as NSArray)
    }
    
    
    
    func loadViewWithMatchs(bets: NSArray){
        
        var leagueName = customLeague.pfCustomLeague.valueForKey("leagueTitle") as NSString
        var league = GSLeague.getLeagueFromCache(leagueName)
        
        if(league.matches == nil){
            GSLeague.getLeagues(self)
            return
        }
        
        
        validMatches = NSMutableArray()
        var tempMatches:NSArray = customLeague.getbetMatches(league.matches, bets: bets)
        for matche in tempMatches{
            
            validMatches.addObject(GSMatcheSelection(matche: matche as PFObject, customLeague: customLeague.pfCustomLeague))
        }
        
        var count:CGFloat = 0
        for validMatche in validMatches{
            
            self.createMatcheCell(validMatche as GSMatcheSelection, num:count, selection: bets[Int(count)])
            count += 1
        }
        
        self.scrollView.contentSize = CGSizeMake(320, (CELLHEIGHT*count))
    }
    
    
    
    func createMatcheCell(matche:GSMatcheSelection, num:CGFloat, selection: AnyObject!){
        
        var cell = UIScrollView(frame:CGRectMake(0, num*CELLHEIGHT, 320, CELLHEIGHT))
        cell.pagingEnabled = true
        cell.showsHorizontalScrollIndicator = false
        cell.tag = Int(num)
        scrollView.addSubview(cell)
        
        cell.addSubview(createMatchView(matche, selection:selection))
        
        cell.addSubview(GSCustomLeagueViewControlelr.createCrowdPredictionView(matche))
        
        cell.contentSize = CGSizeMake(640, CELLHEIGHT)
    }
    
    
    func createMatchView(matche:GSMatcheSelection, selection: AnyObject!) -> UIView{
        
        var matchView = UIView(frame:CGRectMake(0, 0, 320, CELLHEIGHT))
        matchView.backgroundColor = UIColor.whiteColor()
        
        GSCustomLeagueViewControlelr.createTopView(matchView, title:matche.pfMatche.valueForKey("title") as NSString, isCrowd:false)
        
        
        
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
        
        return matchView
    }
    
    
    func leaderBoardTap(sender: UIButton!){
        
        gsLeaderBoardViewController = GSLeaderBoardViewController()
        gsLeaderBoardViewController.customLeague = customLeague
        gsLeaderBoardViewController.customLeague.pfCustomLeague.fetch()
        self.view.addSubview(gsLeaderBoardViewController.view)
    }
    
    
}