//
//  GSPastMatchCustomLeagueViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 27/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation



class GSPastMatchsViewController: UIViewController {
    
    var scrollView:UIScrollView!
    
    var customLeague:GSCustomLeague!

    var matchResults:NSMutableArray!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        var blueLine1 = UIView(frame:CGRectMake(0, YSTART, 320, 1))
        blueLine1.backgroundColor = SPECIALBLUE
        self.view.addSubview(blueLine1)
        
        var pastMatchLabel    = UILabel(frame:CGRectMake(0, YSTART+3, 320, 33))
        pastMatchLabel.text   = "Past Matches"
        pastMatchLabel.textAlignment = .Center
        pastMatchLabel.font   = UIFont(name:FONT2, size:18)
        pastMatchLabel.textColor = SPECIALBLUE
        self.view.addSubview(pastMatchLabel)
        
        var blueLine2 = UIView(frame:CGRectMake(0, YSTART+34, 320, 1))
        blueLine2.backgroundColor = SPECIALBLUE
        self.view.addSubview(blueLine2)
        
        scrollView = UIScrollView(frame:CGRectMake(0, YSTART+35, 320, self.view.frame.size.height - YSTART - 35))
        self.view.addSubview(scrollView)
        
        matchResults = GSLeague.getCacheMatchResultsFromDate(customLeague.pfCustomLeague["startDate"] as! NSDate)
        loadViewWithMatchs()
    }
    
    
    func loadViewWithMatchs(){
        
        var countMatchResult:CGFloat = 0
        for matchResult in matchResults{
            
            createMatcheResultCell(matchResult as! PFObject, num:countMatchResult, startY:0)
            countMatchResult += 1
        }
        
        
        self.scrollView.contentSize = CGSizeMake(320, CELLHEIGHT*countMatchResult)
    }
    
    
    func createMatcheResultCell(matcheResult:PFObject, num:CGFloat, startY:CGFloat){
        
        var matchResultView = UIView(frame:CGRectMake(0, startY+(num*CELLHEIGHT), 320, CELLHEIGHT))
        matchResultView.backgroundColor = UIColor.whiteColor()
        
        var title = String(format: "%@ V %@", matcheResult["homeTeam"] as! String, matcheResult["awayTeam"] as! String)
        GSCustomLeagueViewControlelr.createTopView(matchResultView, title: title, isCrowd:false)
        
        var leftScoreLabel  = UILabel(frame:CGRectMake(95, 50, 60, 100))
        leftScoreLabel.tag  = 888
        leftScoreLabel.text = matcheResult["homeTeamScore"] as? String
        leftScoreLabel.textAlignment = .Center
        leftScoreLabel.font = UIFont(name:FONT2, size:44)
        leftScoreLabel.textColor = SPECIALBLUE
        matchResultView.addSubview(leftScoreLabel)
        
        var centerScoreLabel    = UILabel(frame:CGRectMake(127, 70, 60, 60))
        centerScoreLabel.text   = "-"
        centerScoreLabel.textAlignment = .Center
        centerScoreLabel.font   = UIFont(name:FONT2, size:44)
        centerScoreLabel.textColor = SPECIALBLUE
        matchResultView.addSubview(centerScoreLabel)
        
        var rightScoreLabel     = UILabel(frame:CGRectMake(160, 50, 60, 100))
        rightScoreLabel.tag     = 999
        rightScoreLabel.text    = matcheResult["awayTeamScore"] as? String
        rightScoreLabel.textAlignment = .Center
        rightScoreLabel.font    = UIFont(name:FONT2, size:44)
        rightScoreLabel.textColor = SPECIALBLUE
        matchResultView.addSubview(rightScoreLabel)
        
        scrollView.addSubview(matchResultView)
    }

}