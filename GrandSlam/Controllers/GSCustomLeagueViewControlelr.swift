//
//  GSCustomLeagueViewControlelr.swift
//  GrandSlam
//
//  Created by Explocial 6 on 04/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation



@objc protocol CrowdPredictionProtocol {
    
    func oddButtonTap(sender: UIButton!)
    func firstTeamOddButtonTap(sender: UIButton!)
    func secondTeamOddButtonTap(sender: UIButton!)
    func drawOddButtonTap(sender: UIButton!)
}


let CELLHEIGHT:CGFloat = 164




class GSCustomLeagueViewControlelr: UIViewController, LeagueCaller, UserCaller, CrowdPredictionProtocol {
    
    var scrollView:UIScrollView!
    
    var customLeague:GSCustomLeague!
    
    var validMatches:NSMutableArray!
    
    var betCstomLeagueViewController:GSBetCstomLeagueViewController!
    
    var dateLeagueLabel:UILabel!
    
    var leaderBoardScrollView:GSLeaderBoardScrollView!
    
    
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        
       // NSException(name:NSGenericException, reason:"Everything is ok. This is just a test crash.", userInfo:nil).raise()
        
        
        var leaderBoardButton = UIButton(frame: CGRectMake(0, YSTART, 320, 35))
        leaderBoardButton.setTitle("See Leaderboard", forState: .Normal)
        leaderBoardButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        leaderBoardButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        leaderBoardButton.backgroundColor = SPECIALBLUE
        leaderBoardButton.addTarget(self, action:"leaderBoardTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(leaderBoardButton)
        
        
        
        dateLeagueLabel    = UILabel(frame:CGRectMake(0, YSTART+33, 320, 38))
        dateLeagueLabel.textAlignment = .Center
        dateLeagueLabel.font   = UIFont(name:FONT2, size:18)
        dateLeagueLabel.textColor = SPECIALBLUE
        self.view.addSubview(dateLeagueLabel)
        
        var blueLine = UIView(frame:CGRectMake(0, YSTART+70, 320, 1))
        blueLine.backgroundColor = SPECIALBLUE
        self.view.addSubview(blueLine)
        
        
        scrollView = UIScrollView(frame:CGRectMake(0, blueLine.frame.origin.y+1, 320, self.view.frame.size.height - YSTART - 68))
        self.view.addSubview(scrollView)
        
        
        if(customLeague.hasBetSlip().count > 0){
            self.endGetUserBetSlips()
        }else{
            
            SVProgressHUD.show()
            dispatch_async(dispatch_get_main_queue(), {
                self.loadViewWithMatchs()
            })
        }
        
    }
    
    func refreshDateLeagueLabel(){
        
        dateLeagueLabel.text   = cacheNumberGameWeek
    }
    
    
    func loadViewWithMatchs(){
        
        var leagueName = customLeague.pfCustomLeague.valueForKey("leagueTitle") as NSString
        var league = GSLeague.getLeagueFromCache(leagueName)
        
        if(league.matches == nil){
            GSLeague.getLeagues(self)
            return
        }
        
        
        validMatches = NSMutableArray()
        var tempMatches:NSArray = customLeague.getValidMatches(league.matches)
        for matche in tempMatches{
            
            validMatches.addObject(GSMatcheSelection(matche: matche as PFObject, customLeague: customLeague.pfCustomLeague))
        }
        
        /*
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        
        var startDate   = customLeague.pfCustomLeague["startDate"] as NSDate
        
        if(tempMatches.count > 0){
            
            var lastMatche = tempMatches.lastObject as PFObject
            var lastMatcheDate = lastMatche["eventDateTime"] as NSString
            lastMatcheDate = lastMatcheDate.substringWithRange(NSMakeRange(5, 5))
            var dateArray = lastMatcheDate.componentsSeparatedByString("-") as NSArray
        
            dateLeagueLabel.text   = NSString(format:"Matches: %@ - %@/%@", dateFormatter.stringFromDate(startDate), dateArray.lastObject as NSString, dateArray.firstObject as NSString)
        }*/
        
        if(cacheNumberGameWeek != nil){
            refreshDateLeagueLabel()
        }
        
        
        var count:CGFloat = 0
        for validMatche in validMatches{
            
            self.createMatcheCell(validMatche as GSMatcheSelection, num:count)
            count += 1
        }
        
            
        var bettButton = UIButton(frame: CGRectMake(85, (count*CELLHEIGHT)+8, 150, 43))
        bettButton.titleLabel!.font = UIFont(name:FONT3, size:14)
        bettButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        bettButton.setTitle("SUBMIT PICKS", forState: .Normal)
        bettButton.backgroundColor = SPECIALBLUE
        bettButton.addTarget(self, action:"bettButtonTap:", forControlEvents:.TouchUpInside)
        self.scrollView.addSubview(bettButton)
        
            
        self.scrollView.contentSize = CGSizeMake(320, (CELLHEIGHT*count)+60)
        SVProgressHUD.dismiss()
    }
    
    
    func endGetLeagues(data : NSArray){
        
        loadViewWithMatchs()
    }
    
    
    
    func closeView(){
        
        backToMainView()
        self.view.removeFromSuperview()
        //GSMainViewController.getMainViewControllerInstance().dismissViewControllerAnimated(true, completion: nil)
    }
    
    func backToMainView(){
        
        if(leaderBoardScrollView != nil){
            leaderBoardScrollView.closeView()
        }
    }
    

    func leaderBoardTap(sender: UIButton!){
        
        backToMainView()
        leaderBoardScrollView = GSLeaderBoardScrollView(frame:self.view.frame, customLeague:customLeague)
        self.view.addSubview(leaderBoardScrollView)
    }
    
    
    


    
    func createMatcheCell(matche:GSMatcheSelection, num:CGFloat){
        
        var cell = UIScrollView(frame:CGRectMake(0, num*CELLHEIGHT, 320, CELLHEIGHT))
        cell.pagingEnabled = true
        cell.showsHorizontalScrollIndicator = false
        cell.tag = Int(num)
        scrollView.addSubview(cell)
        
        cell.addSubview(createMatchView(matche))
        
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
    
    
    class func createTopView(topView:UIView, title:NSString, isCrowd:Bool){
        
        var startX:CGFloat = 78
        if(isCrowd){
            startX = 118
        }
        
        var teamsNames = GSCustomLeague.getShortTitle(title)
        
        var leftName:NSString   = teamsNames.firstObject as NSString
        var rightName:NSString  = teamsNames.lastObject as NSString
        var title = leftName+" V "+rightName
        
        var imageLeft   = TEAMS_IMAGES_URL_ROOT+leftName+".png"
        var imageRight  = TEAMS_IMAGES_URL_ROOT+rightName+".png"
        
        var urlLeftRequest      = NSURLRequest(URL:NSURL(string: imageLeft)!)
        var leftImageTeamView   = UIImageView(frame: CGRectMake(startX-33, 12, 45, 45))
        leftImageTeamView.setImageWithURLRequest( urlLeftRequest, placeholderImage: nil, success: { (url, response, image) -> Void in
            leftImageTeamView.image = image
            }, failure: { (url, response, error) -> Void in
        })
        topView.addSubview(leftImageTeamView)
        
        
        var matcheLabel     = UILabel(frame:CGRectMake(startX, 12, 160, 50))
        matcheLabel.text    = title
        matcheLabel.textAlignment = .Center
        matcheLabel.font    = UIFont(name:FONT3, size:18)
        matcheLabel.textColor = SPECIALBLUE
        if(isCrowd){
            matcheLabel.textColor = UIColor.whiteColor()
        }
        topView.addSubview(matcheLabel)
        
        
        var urlRighttRequest    = NSURLRequest(URL:NSURL(string: imageRight)!)
        var rightImageTeamView  = UIImageView(frame: CGRectMake(155+startX, 12, 45, 45))
        rightImageTeamView.setImageWithURLRequest( urlRighttRequest, placeholderImage: nil, success: { (url, response, image) -> Void in
            rightImageTeamView.image = image
            }, failure: { (url, response, error) -> Void in
        })
        topView.addSubview(rightImageTeamView)
    }
    
    
    func createMatchView(matche:GSMatcheSelection) -> UIView{
        
        var matchView = UIView(frame:CGRectMake(0, 0, 320, CELLHEIGHT))
        matchView.backgroundColor = UIColor.whiteColor()
        
        GSCustomLeagueViewControlelr.createTopView(matchView, title:matche.pfMatche.valueForKey("title") as NSString, isCrowd:false)
        
        
        var leftUpButton = UIButton(frame: CGRectMake(50, 60, 35, 35))
        leftUpButton.tag = 666
        leftUpButton.setImage(UIImage(named:"Button_Up"), forState: .Normal)
        leftUpButton.addTarget(self, action:"leftUpTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(leftUpButton)
        
        var leftDownButton = UIButton(frame: CGRectMake(50, 97, 35, 35))
        leftDownButton.tag = 667
        leftDownButton.setImage(UIImage(named:"Button_Down"), forState: .Normal)
        leftDownButton.addTarget(self, action:"leftDownTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(leftDownButton)
        
        var rightUpButton = UIButton(frame: CGRectMake(237, 60, 35, 35))
        rightUpButton.tag = 668
        rightUpButton.setImage(UIImage(named:"Button_Up"), forState: .Normal)
        rightUpButton.addTarget(self, action:"rightUpTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(rightUpButton)
        
        var righttDownButton = UIButton(frame: CGRectMake(237, 97, 35, 35))
        righttDownButton.tag = 669
        righttDownButton.setImage(UIImage(named:"Button_Down"), forState: .Normal)
        righttDownButton.addTarget(self, action:"rightDownTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(righttDownButton)
        
        
        var leftScoreLabel  = UILabel(frame:CGRectMake(95, 46, 60, 110))
        leftScoreLabel.tag  = 888
        leftScoreLabel.text = "0"
        leftScoreLabel.textAlignment = .Center
        leftScoreLabel.font = UIFont(name:FONT2, size:44)
        leftScoreLabel.textColor = SPECIALBLUE
        matchView.addSubview(leftScoreLabel)
        
        var centerScoreLabel    = UILabel(frame:CGRectMake(134, 70, 60, 60))
        centerScoreLabel.text   = "-"
        centerScoreLabel.textAlignment = .Center
        centerScoreLabel.font   = UIFont(name:FONT2, size:44)
        centerScoreLabel.textColor = SPECIALBLUE
        matchView.addSubview(centerScoreLabel)
        
        var rightScoreLabel     = UILabel(frame:CGRectMake(170, 46, 60, 110))
        rightScoreLabel.tag     = 999
        rightScoreLabel.text = "0"
        rightScoreLabel.textAlignment = .Center
        rightScoreLabel.font    = UIFont(name:FONT2, size:44)
        rightScoreLabel.textColor = SPECIALBLUE
        matchView.addSubview(rightScoreLabel)
        
        return matchView
    }
    
    
    
    
    func leftUpTap(sender: UIButton!){
        
        var cell = (sender as UIView).superview!
        var leftScoreLabel:UILabel = cell.viewWithTag(888) as UILabel
        var score = leftScoreLabel.text!.toInt()!+1
        if(score < 10){
            leftScoreLabel.text = String(score)
        }
    }
    
    func leftDownTap(sender: UIButton!){
        
        var cell = (sender as UIView).superview!
        var leftScoreLabel:UILabel = cell.viewWithTag(888) as UILabel
        var score = leftScoreLabel.text!.toInt()!-1
        if(score >= 0){
            leftScoreLabel.text = String(score)
        }
    }
    
    func rightUpTap(sender: UIButton!){
        
        var cell = (sender as UIView).superview!
        var rightScoreLabel:UILabel = cell.viewWithTag(999) as UILabel
        var score = rightScoreLabel.text!.toInt()!+1
        if(score < 10){
            rightScoreLabel.text = String(score)
        }
    }
    
    func rightDownTap(sender: UIButton!){
        
        var cell = (sender as UIView).superview!
        var rightScoreLabel:UILabel = cell.viewWithTag(999) as UILabel
        var score = rightScoreLabel.text!.toInt()!-1
        if(score >= 0){
            rightScoreLabel.text = String(score)
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
    
    
    
    class func createCrowdPredictionView(matche:GSMatcheSelection, delegate: CrowdPredictionProtocol) -> UIView{
        
        var crowdPredictionView = UIView(frame:CGRectMake(297, 0, 347, CELLHEIGHT-10))
        crowdPredictionView.backgroundColor = SPECIALBLUE
        
        //createTopView(crowdPredictionView, title:matche.pfMatche.valueForKey("title") as NSString, isCrowd:true)
        
        var crowdLabel  = UIButton(frame:CGRectMake(-57, 67, 140, 23))
        
        crowdLabel.titleLabel!.font  = UIFont(name:FONT4, size:11)
        crowdLabel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        crowdLabel.setTitle("Crowd Predictions & Odds", forState: .Normal)
        crowdLabel.addTarget(delegate, action:"crowdLabelTap:", forControlEvents:.TouchUpInside)
        //crowdLabel.textAlignment = .Center
        let transform = CGAffineTransformRotate(CGAffineTransformIdentity, -3.14/2);
        crowdLabel.transform = transform;
        crowdPredictionView.addSubview(crowdLabel)
        

        var backLabel  = UIButton(frame:CGRectMake(-48, 60, 166, 23))
        backLabel.backgroundColor = UIColor.whiteColor()
        
        backLabel.titleLabel!.font  = UIFont(name:FONT4, size:13)
        backLabel.setTitleColor(SPECIALBLUE, forState: .Normal)
        backLabel.setTitle("Back", forState: .Normal)
        backLabel.addTarget(delegate, action:"backTap:", forControlEvents:.TouchUpInside)
        //backLabel.textAlignment = .Center
        backLabel.transform = transform;
        crowdPredictionView.addSubview(backLabel)
        
        if(matche.correctScoreSelections != nil){
            /*
            var bestSelection:NSDictionary = matche.bestCorrectScoreSelection
            
            
            var scoreArray:NSArray = getScoresFromSelectionName(bestSelection.objectForKey("selectionName") as NSString, titleMatche: matche.pfMatche.valueForKey("title") as NSString)
            
            var leftScore:NSString  = scoreArray.firstObject as NSString
            var rightScore:NSString = scoreArray.lastObject as NSString
            
            
            var leftScoreLabel  = UILabel(frame:CGRectMake(125, 6, 60, 100))
            leftScoreLabel.text = leftScore
            leftScoreLabel.textAlignment = .Center
            leftScoreLabel.font = UIFont(name:FONT2, size:44)
            leftScoreLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(leftScoreLabel)
            
            var centerScoreLabel    = UILabel(frame:CGRectMake(157, 20, 60, 60))
            centerScoreLabel.text   = "-"
            centerScoreLabel.textAlignment = .Center
            centerScoreLabel.font   = UIFont(name:FONT2, size:44)
            centerScoreLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(centerScoreLabel)
            
            var rightScoreLabel     = UILabel(frame:CGRectMake(190, 6, 60, 100))
            rightScoreLabel.text    = rightScore
            rightScoreLabel.textAlignment = .Center
            rightScoreLabel.font    = UIFont(name:FONT2, size:44)
            rightScoreLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(rightScoreLabel)
            
            
            var currentPrice = bestSelection.objectForKey("currentPrice") as NSDictionary
            var denPrice = currentPrice.objectForKey("denPrice") as CGFloat
            var numPrice = currentPrice.objectForKey("numPrice") as CGFloat
            
            var odd = String(Int(numPrice))+"/"+String(Int(denPrice))
            
            var oddLabel     = UILabel(frame:CGRectMake(240, 36, 50, 40))
            oddLabel.text    = odd
            oddLabel.textAlignment = .Center
            oddLabel.font    = UIFont(name:FONT2, size:18)
            oddLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(oddLabel)
            
            var oddButton = UIButton(frame: CGRectMake(295, 42, 60, 28))
            oddButton.titleLabel!.font = UIFont(name:FONT3, size:14)
            oddButton.backgroundColor = UIColor.whiteColor()
            oddButton.setTitleColor(SPECIALBLUE, forState: .Normal)
            oddButton.setTitle("Bet Now", forState: .Normal)
            oddButton.addTarget(delegate, action:"oddButtonTap:", forControlEvents:.TouchUpInside)
            crowdPredictionView.addSubview(oddButton)
            */
            
            
            
            
            var teamsNames:NSArray = GSCustomLeague.getShortTitle(matche.pfMatche.valueForKey("title") as NSString)
            
            var firstTeamLabel     = UILabel(frame:CGRectMake(45, 0, 60, 60))
            firstTeamLabel.numberOfLines = 2
            firstTeamLabel.textAlignment = .Center
            firstTeamLabel.text    = (teamsNames.firstObject as NSString)+"\nwin"
            firstTeamLabel.font    = UIFont(name:FONT4, size:15)
            firstTeamLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(firstTeamLabel)
            

            var firstTeamPView = UIView(frame:CGRectMake(110, 15, 80, 16))
            firstTeamPView.backgroundColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(firstTeamPView)
            
            var firstTeamValue = matche.percentThinkHomeTeamWin()

            var firstTeamProgressView = UIProgressView(frame:CGRectMake(1, 7, 78, 6))
            var transformPV = CGAffineTransformMakeScale(1.0, 7.0)
            firstTeamProgressView.transform = transformPV
            firstTeamProgressView.trackTintColor    = SPECIALBLUE
            firstTeamProgressView.progressTintColor = UIColor.whiteColor()
            if(firstTeamValue > 0){
                firstTeamProgressView.progress = Float(firstTeamValue)
            }
            firstTeamPView.addSubview(firstTeamProgressView)
            
            var firstTeamThinkLabel     = UILabel(frame:CGRectMake(120, 26, 80, 30))
            var value = 0
            if(firstTeamValue > 0){
                value = Int(firstTeamValue*100)
            }
            firstTeamThinkLabel.text    = String(value).stringByAppendingString("% think")
            firstTeamThinkLabel.font    = UIFont(name:FONT4, size:12)
            firstTeamThinkLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(firstTeamThinkLabel)
            

            var firstTeamSelection = matche.getHomeSelection()
            var firstTeamCurrentPrice = firstTeamSelection.objectForKey("currentPrice") as NSDictionary
            var firstTeamDenPrice = firstTeamCurrentPrice.objectForKey("denPrice") as CGFloat
            var firstTeamNumPrice = firstTeamCurrentPrice.objectForKey("numPrice") as CGFloat
            
            var firstTeamOdd = String(Int(firstTeamNumPrice))+"/"+String(Int(firstTeamDenPrice))
            
            var firstTeamOddLabel     = UILabel(frame:CGRectMake(200, 9, 50, 40))
            firstTeamOddLabel.text    = firstTeamOdd
            firstTeamOddLabel.textAlignment = .Center
            firstTeamOddLabel.font    = UIFont(name:FONT2, size:12)
            firstTeamOddLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(firstTeamOddLabel)
            
            var firstTeamOddButton = UIButton(frame: CGRectMake(270, 9, 70, 40))
            firstTeamOddButton.titleLabel!.font = UIFont(name:FONT2, size:15)
            firstTeamOddButton.backgroundColor  = SPECIALBLUE
            firstTeamOddButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            firstTeamOddButton.setTitle("Bet Now", forState: .Normal)
            firstTeamOddButton.addTarget(delegate, action:"firstTeamOddButtonTap:", forControlEvents:.TouchUpInside)
            crowdPredictionView.addSubview(firstTeamOddButton)
            
            
            
            
            
            
            var drawLabel     = UILabel(frame:CGRectMake(45, 47, 60, 60))
            drawLabel.text    = "Draw"
            drawLabel.textAlignment = .Center
            drawLabel.font    = UIFont(name:FONT4, size:15)
            drawLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(drawLabel)
            
            
            var drawPView = UIView(frame:CGRectMake(110, 63, 80, 16))
            drawPView.backgroundColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(drawPView)
            
            var drawValue = matche.percentThinkDraw()
            
            var drawProgressView = UIProgressView(frame:CGRectMake(1, 7, 78, 6))
            drawProgressView.transform = transformPV
            drawProgressView.trackTintColor    = SPECIALBLUE
            drawProgressView.progressTintColor = UIColor.whiteColor()
            if(drawValue > 0){
                drawProgressView.progress = Float(drawValue)
            }
            drawPView.addSubview(drawProgressView)
            
            var drawThinkLabel     = UILabel(frame:CGRectMake(120, 74, 80, 30))
            value = 0
            if(drawValue > 0){
                value = Int(drawValue*100)
            }
            drawThinkLabel.text    = String(value).stringByAppendingString("% think")
            drawThinkLabel.font    = UIFont(name:FONT4, size:12)
            drawThinkLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(drawThinkLabel)
            
            
            var drawSelection = matche.getDrawSelection()
            var drawCurrentPrice = drawSelection.objectForKey("currentPrice") as NSDictionary
            var drawDenPrice = drawCurrentPrice.objectForKey("denPrice") as CGFloat
            var drawNumPrice = drawCurrentPrice.objectForKey("numPrice") as CGFloat
            
            var drawOdd = String(Int(drawNumPrice))+"/"+String(Int(drawDenPrice))
            
            var drawOddLabel     = UILabel(frame:CGRectMake(200, 56, 50, 40))
            drawOddLabel.text    = drawOdd
            drawOddLabel.textAlignment = .Center
            drawOddLabel.font    = UIFont(name:FONT2, size:12)
            drawOddLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(drawOddLabel)
            
            var drawOddButton = UIButton(frame: CGRectMake(270, 56, 70, 40))
            drawOddButton.titleLabel!.font  = UIFont(name:FONT2, size:15)
            drawOddButton.backgroundColor   = SPECIALBLUE
            drawOddButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            drawOddButton.setTitle("Bet Now", forState: .Normal)
            drawOddButton.addTarget(delegate, action:"drawOddButtonTap:", forControlEvents:.TouchUpInside)
            crowdPredictionView.addSubview(drawOddButton)
            
            
            
            
            
            
            var secondTeamLabel     = UILabel(frame:CGRectMake(45, 94, 60, 60))
            secondTeamLabel.numberOfLines = 2
            secondTeamLabel.textAlignment = .Center
            secondTeamLabel.text    = (teamsNames.lastObject as NSString)+"\nwin"
            secondTeamLabel.font    = UIFont(name:FONT4, size:15)
            secondTeamLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(secondTeamLabel)
            
            var secondTeamPView = UIView(frame:CGRectMake(110, 110, 80, 16))
            secondTeamPView.backgroundColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(secondTeamPView)
            
            var secondTeamValue = matche.percentThinkAwayTeamWin()
            
            var secondTeamProgressView = UIProgressView(frame:CGRectMake(1, 7, 78, 6))
            secondTeamProgressView.transform = transformPV
            secondTeamProgressView.trackTintColor    = SPECIALBLUE
            secondTeamProgressView.progressTintColor = UIColor.whiteColor()
            if(secondTeamValue > 0){
                secondTeamProgressView.progress = Float(secondTeamValue)
            }
            secondTeamPView.addSubview(secondTeamProgressView)
            
            var secondTeamThinkLabel     = UILabel(frame:CGRectMake(120, 121, 80, 30))
            value = 0
            if(secondTeamValue > 0){
                value = Int(secondTeamValue*100)
            }
            secondTeamThinkLabel.text    = String(value).stringByAppendingString("% think")
            secondTeamThinkLabel.font    = UIFont(name:FONT4, size:12)
            secondTeamThinkLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(secondTeamThinkLabel)
            
            
            var secondTeamSelection = matche.getAwaySelection()
            var secondTeamCurrentPrice = secondTeamSelection.objectForKey("currentPrice") as NSDictionary
            var secondTeamDenPrice = secondTeamCurrentPrice.objectForKey("denPrice") as CGFloat
            var secondTeamNumPrice = secondTeamCurrentPrice.objectForKey("numPrice") as CGFloat
            
            var secondTeamOdd = String(Int(secondTeamNumPrice))+"/"+String(Int(secondTeamDenPrice))
            
            var secondTeamOddLabel     = UILabel(frame:CGRectMake(200, 103, 50, 40))
            secondTeamOddLabel.text    = secondTeamOdd
            secondTeamOddLabel.textAlignment = .Center
            secondTeamOddLabel.font    = UIFont(name:FONT2, size:12)
            secondTeamOddLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(secondTeamOddLabel)
            
            var secondTeamwOddButton = UIButton(frame: CGRectMake(270, 103, 70, 40))
            secondTeamwOddButton.titleLabel!.font   = UIFont(name:FONT2, size:15)
            secondTeamwOddButton.backgroundColor    = SPECIALBLUE
            secondTeamwOddButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            secondTeamwOddButton.setTitle("Bet Now", forState: .Normal)
            secondTeamwOddButton.addTarget(delegate, action:"secondTeamOddButtonTap:", forControlEvents:.TouchUpInside)
            crowdPredictionView.addSubview(secondTeamwOddButton)
            
        }
        
        
        return crowdPredictionView
    }

    func oddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var bestSelection:NSDictionary  = matche.bestCorrectScoreSelection
        GSBetSlip.goToLadBrokes([bestSelection])
    }
    
    func firstTeamOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.getHomeSelection()
        GSBetSlip.goToLadBrokes([selection])
    }
    
    func secondTeamOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.getAwaySelection()
        GSBetSlip.goToLadBrokes([selection])
    }
    
    func drawOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.getDrawSelection()
        GSBetSlip.goToLadBrokes([selection])
    }

    
    
    //Your accumulator is based on your match result predictions
    
    func bettButtonTap(sender: UIButton!){
    
        var betSelections = NSMutableArray()
        
        var count:Int = 0
        for matche in validMatches{
            
            var cellScrollView = scrollView.viewWithTag(count) as UIScrollView
            var cell    =   cellScrollView.subviews[0] as UIView
            
            var leftScore:NSString  = (cell.viewWithTag(888) as UILabel).text!
            var rightScore:NSString = (cell.viewWithTag(999) as UILabel).text!
            
            if(leftScore != "0" || rightScore != "0"){
                
                var currentSelectionName = getSelectionNameFromScore(leftScore, rightScore: rightScore, titleMatche: (matche as GSMatcheSelection).pfMatche.valueForKey("title") as NSString)
                
                
                var selection:NSDictionary = (matche as GSMatcheSelection).getScoreCorrectSelectionByName(currentSelectionName)
                if(selection.objectForKey("selectionKey") != nil){
                    var bet = NSMutableDictionary()
                    bet.setObject(selection, forKey: "selection")
                    bet.setObject((matche as GSMatcheSelection).pfMatche.objectId , forKey: "matchId")
                    betSelections.addObject(bet)
                }
                
                (matche as GSMatcheSelection).setPredictionTeamWin(leftScore, rightScore: rightScore)
            }
            count += 1
        }
        
        if(betSelections.count > 0){
            
            SVProgressHUD.show()
            
            var betSlip = PFObject(className:"BetSlip")
            betSlip["customLeagueId"] = customLeague.pfCustomLeague.objectId
            betSlip["bets"] = betSelections
            betSlip.save()
            
            var user = PFUser.currentUser()
            var relation = user.relationForKey("betSlips")
            relation.addObject(betSlip)
            user.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                SVProgressHUD.dismiss()
                
                GSUser.loadUserBetSlips(user, delegate: self)
            })
            
           // GSBetSlip.buildSlip(betSelections)
        }
    }
    
    func endGetUserBetSlips(){
        
        betCstomLeagueViewController = GSBetCstomLeagueViewController()
        betCstomLeagueViewController.customLeague = self.customLeague
        self.view.addSubview(betCstomLeagueViewController.view)
    }
    
    
    

    
    
    
    
    
    func getSelectionNameFromScore(leftScore:NSString, rightScore:NSString, titleMatche:NSString) -> NSString{
        
        var selectionName:NSString = "Draw "+leftScore+" - "+rightScore
        if(leftScore != rightScore){
            
            var names:NSArray = titleMatche.componentsSeparatedByString(" V ")
            
            if(leftScore.intValue > rightScore.intValue ){
                selectionName = (names.firstObject as NSString)+" "+leftScore+" - "+rightScore
            }else{
                selectionName = (names.lastObject as NSString)+" "+rightScore+" - "+leftScore
            }
        }
        return selectionName
    }
    
    class func getScoresFromSelectionName(selectionName:NSString, titleMatche:NSString) -> NSArray{
        
        var arrayDraw = selectionName.componentsSeparatedByString("Draw ") as NSArray
        if(arrayDraw.count > 1){
            var scoreDraw = (arrayDraw.lastObject as NSString).componentsSeparatedByString(" - ") as NSArray
            return [scoreDraw.firstObject as NSString, scoreDraw.firstObject as NSString]
        }
        else{
            
            var names:NSArray = titleMatche.componentsSeparatedByString(" V ")
            
            var arraySpaces = selectionName.componentsSeparatedByString(" ") as NSArray
            var count = arraySpaces.count
            
            var maxScore    = (arraySpaces[count-3] as NSString)
            var smallScore  = (arraySpaces[count-1] as NSString)
            
            if(selectionName.substringToIndex(selectionName.length-6) == names[0] as NSString){
                
                return [maxScore, smallScore]
            }
            else{
                return [smallScore, maxScore]
            }
        }
    }
    
}