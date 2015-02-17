//
//  GSCustomLeagueViewControlelr.swift
//  GrandSlam
//
//  Created by Explocial 6 on 04/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


let CELLHEIGHT:CGFloat = 181

let BETTLABEL_TEXT1 = "Submit prediction"


class GSCustomLeagueViewControlelr: UIViewController, UITextFieldDelegate, LeagueCaller {
    
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
        
        var accOddsLabel    = UILabel(frame:CGRectMake(0, yStart+33, 320, 38))
        accOddsLabel.text   = NSString(format:"Accumulated odds: %d : %d", 3, 1)
        accOddsLabel.textAlignment = .Center
        accOddsLabel.font   = UIFont(name:FONT2, size:18)
        accOddsLabel.textColor = SPECIALBLUE
        self.view.addSubview(accOddsLabel)
        
        var blueLine = UIView(frame:CGRectMake(0, yStart+71, 320, 2))
        blueLine.backgroundColor = SPECIALBLUE
        self.view.addSubview(blueLine)
        
        
        scrollView = UIScrollView(frame:CGRectMake(0, blueLine.frame.origin.y+2, 320, self.view.frame.size.height - yStart - 68))
        self.view.addSubview(scrollView)
        
        loadMatches()
    }
    
    
    func loadMatches(){
        
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
        
        var count:CGFloat = 0
        for validMatche in validMatches{
            
            self.createMatcheCell(validMatche as GSMatcheSelection, num:count)
            count = count+1
        }
        self.scrollView.contentSize = CGSizeMake(320, CELLHEIGHT*count)
    }
    
    func endGetLeagues(data : NSArray){
        
        loadMatches()
    }
    
    
    
    func closeView(){
        
        self.view.removeFromSuperview()
        //GSMainViewController.getMainViewControllerInstance().dismissViewControllerAnimated(true, nil)
    }
    

    func leaderBoardTap(sender: UIButton!){
        
        gsLeaderBoardViewController = GSLeaderBoardViewController()
        gsLeaderBoardViewController.customLeague = customLeague
        gsLeaderBoardViewController.customLeague.pfCustomLeague.fetch()
        self.view.addSubview(gsLeaderBoardViewController.view)
    }


    
    func createMatcheCell(matche:GSMatcheSelection, num:CGFloat){
        
        var cell = UIScrollView(frame:CGRectMake(0, num*CELLHEIGHT, 320, CELLHEIGHT))
        cell.pagingEnabled = true
        cell.showsHorizontalScrollIndicator = false
        cell.tag = Int(num)
        scrollView.addSubview(cell)
        
        cell.addSubview(createMatchView(matche))
        
        cell.addSubview(createCrowdPredictionView(matche))

        cell.contentSize = CGSizeMake(640, CELLHEIGHT)
    }
    
    
    func createTopView(topView:UIView, title:NSString, isCrowd:Bool){
        
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
        var leftImageTeamView   = UIImageView(frame: CGRectMake(startX-13, 5, 30, 30))
        leftImageTeamView.setImageWithURLRequest( urlLeftRequest, placeholderImage: nil, success: { (url, response, image) -> Void in
            leftImageTeamView.image = image
            }, failure: { (url, response, error) -> Void in
        })
        topView.addSubview(leftImageTeamView)
        
        
        var matcheLabel     = UILabel(frame:CGRectMake(startX, 8, 160, 30))
        matcheLabel.text    = title
        matcheLabel.textAlignment = .Center
        matcheLabel.font    = UIFont(name:FONT3, size:18)
        matcheLabel.textColor = SPECIALBLUE
        if(isCrowd){
            matcheLabel.textColor = UIColor.whiteColor()
        }
        topView.addSubview(matcheLabel)
        
        
        var urlRighttRequest    = NSURLRequest(URL:NSURL(string: imageRight)!)
        var rightImageTeamView  = UIImageView(frame: CGRectMake(138+startX, 5, 30, 30))
        rightImageTeamView.setImageWithURLRequest( urlRighttRequest, placeholderImage: nil, success: { (url, response, image) -> Void in
            rightImageTeamView.image = image
            }, failure: { (url, response, error) -> Void in
        })
        topView.addSubview(rightImageTeamView)
    }
    
    func createMatchView(matche:GSMatcheSelection) -> UIView{
        
        var matchView = UIView(frame:CGRectMake(0, 0, 320, CELLHEIGHT))
        matchView.backgroundColor = UIColor.whiteColor()
        
        createTopView(matchView, title:matche.pfMatche.valueForKey("title") as NSString, isCrowd:false)
        
        
        var leftUpButton = UIButton(frame: CGRectMake(65, 40, 30, 30))
        leftUpButton.tag = 666
        leftUpButton.setImage(UIImage(named:"Button_Up"), forState: .Normal)
        leftUpButton.addTarget(self, action:"leftUpTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(leftUpButton)
        
        var leftDownButton = UIButton(frame: CGRectMake(65, 71, 30, 30))
        leftDownButton.tag = 667
        leftDownButton.setImage(UIImage(named:"Button_Down"), forState: .Normal)
        leftDownButton.addTarget(self, action:"leftDownTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(leftDownButton)
        
        var rightUpButton = UIButton(frame: CGRectMake(220, 40, 30, 30))
        rightUpButton.tag = 668
        rightUpButton.setImage(UIImage(named:"Button_Up"), forState: .Normal)
        rightUpButton.addTarget(self, action:"rightUpTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(rightUpButton)
        
        var righttDownButton = UIButton(frame: CGRectMake(220, 71, 30, 30))
        righttDownButton.tag = 669
        righttDownButton.setImage(UIImage(named:"Button_Down"), forState: .Normal)
        righttDownButton.addTarget(self, action:"rightDownTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(righttDownButton)
        
        
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
        
        var bettButton = UIButton(frame: CGRectMake(90, 115, 140, 43))
        bettButton.backgroundColor = SPECIALBLUE
        bettButton.addTarget(self, action:"bettButtonTap:", forControlEvents:.TouchUpInside)
        matchView.addSubview(bettButton)
        
        var bettLabel     = UILabel(frame:CGRectMake(0, 0, bettButton.frame.size.width, bettButton.frame.size.height))
        bettLabel.tag = 777
        bettLabel.numberOfLines = 0
        bettLabel.text    = BETTLABEL_TEXT1
        bettLabel.textAlignment = .Center
        bettLabel.font    = UIFont(name:FONT3, size:13)
        bettLabel.textColor = UIColor.whiteColor()
        bettButton.addSubview(bettLabel)
        
        var score = customLeague.getMatcheScore(matche.pfMatche.objectId)
        var scores:NSArray = score.componentsSeparatedByString(" - ")
        if(scores.count > 1){
            desableBtnsCell(matchView)
            leftScoreLabel.text = scores.firstObject as NSString
            rightScoreLabel.text = scores.lastObject as NSString
        }
        
        return matchView
    }
    
    
    
    func desableBtnsCell(cell: UIView){
        
        var leftUpButton = (cell.viewWithTag(666) as UIButton)
        leftUpButton.enabled = false
        var leftDownButton = (cell.viewWithTag(667) as UIButton)
        leftDownButton.enabled = false
        var rightUpButton = (cell.viewWithTag(668) as UIButton)
        rightUpButton.enabled = false
        var righttDownButton = (cell.viewWithTag(669) as UIButton)
        righttDownButton.enabled = false
        
        var bettLabel = (cell.viewWithTag(777) as UILabel)
        bettLabel.text = "Now make it real with \nLadbrokes"
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
    
    
    func createCrowdPredictionView(matche:GSMatcheSelection) -> UIView{
        
        var crowdPredictionView = UIView(frame:CGRectMake(280, 0, 360, CELLHEIGHT-40))
        crowdPredictionView.backgroundColor = SPECIALBLUE
        
        createTopView(crowdPredictionView, title:matche.pfMatche.valueForKey("title") as NSString, isCrowd:true)
        
        var crowdLabel  = UILabel(frame:CGRectMake(-50, 50, 140, 40))
        crowdLabel.textAlignment = .Center
        crowdLabel.font = UIFont(name:FONT1, size:14)
        crowdLabel.textColor = UIColor.whiteColor()
        crowdLabel.text = "Crowd prediction"
        let transform = CGAffineTransformRotate(CGAffineTransformIdentity, -3.14/2);
        crowdLabel.transform = transform;
        crowdPredictionView.addSubview(crowdLabel)
        
        var backLabel  = UILabel(frame:CGRectMake(-15, 50, 150, 40))
        backLabel.backgroundColor = UIColor.whiteColor()
        backLabel.textAlignment = .Center
        backLabel.font = UIFont(name:FONT1, size:14)
        backLabel.textColor = SPECIALBLUE
        backLabel.text = "Back"
        backLabel.transform = transform;
        crowdPredictionView.addSubview(backLabel)
        
        if(matche.correctScoreSelections != nil){
            
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
            oddButton.addTarget(self, action:"oddButtonTap:", forControlEvents:.TouchUpInside)
            crowdPredictionView.addSubview(oddButton)
            
            
            
            
            var matchBettingSelections = matche.matchBettingSelections
            
            var teamsNames:NSArray = GSCustomLeague.getShortTitle(matche.pfMatche.valueForKey("title") as NSString)
            
            var firstTeamLabel     = UILabel(frame:CGRectMake(125, 74, 100, 30))
            firstTeamLabel.text    = teamsNames.firstObject as NSString
            firstTeamLabel.font    = UIFont(name:FONT2, size:18)
            firstTeamLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(firstTeamLabel)
            
            var firstTeamSelection = matchBettingSelections[0] as NSDictionary
            var firstTeamCurrentPrice = firstTeamSelection.objectForKey("currentPrice") as NSDictionary
            var firstTeamDenPrice = firstTeamCurrentPrice.objectForKey("denPrice") as CGFloat
            var firstTeamNumPrice = firstTeamCurrentPrice.objectForKey("numPrice") as CGFloat
            
            var firstTeamOdd = String(Int(firstTeamNumPrice))+"/"+String(Int(firstTeamDenPrice))
            
            var firstTeamOddLabel     = UILabel(frame:CGRectMake(240, 70, 50, 40))
            firstTeamOddLabel.text    = firstTeamOdd
            firstTeamOddLabel.textAlignment = .Center
            firstTeamOddLabel.font    = UIFont(name:FONT2, size:18)
            firstTeamOddLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(firstTeamOddLabel)
            
            var firstTeamOddButton = UIButton(frame: CGRectMake(295, 76, 60, 28))
            firstTeamOddButton.titleLabel!.font = UIFont(name:FONT3, size:14)
            firstTeamOddButton.backgroundColor = UIColor.whiteColor()
            firstTeamOddButton.setTitleColor(SPECIALBLUE, forState: .Normal)
            firstTeamOddButton.setTitle("Bet Now", forState: .Normal)
            firstTeamOddButton.addTarget(self, action:"firstTeamOddButtonTap:", forControlEvents:.TouchUpInside)
            crowdPredictionView.addSubview(firstTeamOddButton)
            
            
            
            
            var drawLabel     = UILabel(frame:CGRectMake(125, 94, 100, 30))
            drawLabel.text    = "Draw"
            drawLabel.font    = UIFont(name:FONT2, size:18)
            drawLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(drawLabel)
            
            var drawSelection = matchBettingSelections[2] as NSDictionary
            var drawCurrentPrice = drawSelection.objectForKey("currentPrice") as NSDictionary
            var drawDenPrice = drawCurrentPrice.objectForKey("denPrice") as CGFloat
            var drawNumPrice = drawCurrentPrice.objectForKey("numPrice") as CGFloat
            
            var drawOdd = String(Int(drawNumPrice))+"/"+String(Int(drawDenPrice))
            
            var drawOddLabel     = UILabel(frame:CGRectMake(240, 90, 50, 40))
            drawOddLabel.text    = drawOdd
            drawOddLabel.textAlignment = .Center
            drawOddLabel.font    = UIFont(name:FONT2, size:18)
            drawOddLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(drawOddLabel)
            
            var drawOddButton = UIButton(frame: CGRectMake(295, 96, 60, 28))
            drawOddButton.titleLabel!.font = UIFont(name:FONT3, size:14)
            drawOddButton.backgroundColor = UIColor.whiteColor()
            drawOddButton.setTitleColor(SPECIALBLUE, forState: .Normal)
            drawOddButton.setTitle("Bet Now", forState: .Normal)
            drawOddButton.addTarget(self, action:"drawOddButtonTap:", forControlEvents:.TouchUpInside)
            crowdPredictionView.addSubview(drawOddButton)
            
            
            var secondTeamLabel     = UILabel(frame:CGRectMake(125, 114, 100, 30))
            secondTeamLabel.text    = teamsNames.lastObject as NSString
            secondTeamLabel.font    = UIFont(name:FONT2, size:18)
            secondTeamLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(secondTeamLabel)
            
            var secondTeamSelection = matchBettingSelections[1] as NSDictionary
            var secondTeamCurrentPrice = secondTeamSelection.objectForKey("currentPrice") as NSDictionary
            var secondTeamDenPrice = secondTeamCurrentPrice.objectForKey("denPrice") as CGFloat
            var secondTeamNumPrice = secondTeamCurrentPrice.objectForKey("numPrice") as CGFloat
            
            var secondTeamOdd = String(Int(secondTeamNumPrice))+"/"+String(Int(secondTeamDenPrice))
            
            var secondTeamOddLabel     = UILabel(frame:CGRectMake(240, 110, 50, 40))
            secondTeamOddLabel.text    = secondTeamOdd
            secondTeamOddLabel.textAlignment = .Center
            secondTeamOddLabel.font    = UIFont(name:FONT2, size:18)
            secondTeamOddLabel.textColor = UIColor.whiteColor()
            crowdPredictionView.addSubview(secondTeamOddLabel)
            
            var secondTeamwOddButton = UIButton(frame: CGRectMake(295, 116, 60, 28))
            secondTeamwOddButton.titleLabel!.font = UIFont(name:FONT3, size:14)
            secondTeamwOddButton.backgroundColor = UIColor.whiteColor()
            secondTeamwOddButton.setTitleColor(SPECIALBLUE, forState: .Normal)
            secondTeamwOddButton.setTitle("Bet Now", forState: .Normal)
            secondTeamwOddButton.addTarget(self, action:"secondTeamOddButtonTap:", forControlEvents:.TouchUpInside)
            crowdPredictionView.addSubview(secondTeamwOddButton)
            
        }
        
        return crowdPredictionView
    }

    func oddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var bestSelection:NSDictionary  = matche.bestCorrectScoreSelection
        self.goToLadBrokes(bestSelection)
    }
    
    func firstTeamOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.matchBettingSelections[0] as NSDictionary
        self.goToLadBrokes(selection)
    }
    
    func secondTeamOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.matchBettingSelections[1] as NSDictionary
        self.goToLadBrokes(selection)
    }
    
    func drawOddButtonTap(sender: UIButton!){
        
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection    = validMatches[row] as GSMatcheSelection
        var selection:NSDictionary      = matche.matchBettingSelections[2] as NSDictionary
        self.goToLadBrokes(selection)
    }

    
    
    
    
    func bettButtonTap(sender: UIButton!){
    
        var cell    = (sender as UIView).superview!
        var row     = cell.superview!.tag
        
        var matche:GSMatcheSelection     = validMatches[row] as GSMatcheSelection
        
        var leftScore:NSString  = (cell.viewWithTag(888) as UILabel).text!
        var rightScore:NSString = (cell.viewWithTag(999) as UILabel).text!
        
        var bettLabel = (cell.viewWithTag(777) as UILabel)
        
        
        var currentSelectionName = getSelectionNameFromScore(leftScore, rightScore: rightScore, titleMatche: matche.pfMatche.valueForKey("title") as NSString)
        
        if(bettLabel.text == BETTLABEL_TEXT1){
            var score = leftScore+" - "+rightScore
            saveUserMatchDetails(matche.pfMatche, details:score, cell:cell)
        }
        else{
            
            var selection:NSDictionary = matche.getScoreCorrectSelectionByName(currentSelectionName)
            if(selection.objectForKey("selectionKey") != nil){
                self.goToLadBrokes(selection as NSDictionary)
            }
        }
        
    }
    
    func saveUserMatchDetails(matche:PFObject, details:NSString, cell:UIView){
        
        SVProgressHUD.show()
        
        var cluMatche = PFObject(className:"CLUMatche")
        cluMatche["matcheId"] = matche.objectId
        cluMatche["userId"]   = PFUser.currentUser().objectId
        cluMatche["savePScore"] = details
        cluMatche.save()
        
        var relation = customLeague.pfCustomLeague.relationForKey("lcuMatches")
        relation.addObject(cluMatche)
        customLeague.pfCustomLeague.saveInBackgroundWithBlock({ (success, error) -> Void in
            
            SVProgressHUD.dismiss()
            self.customLeague.getCluMatches()
            self.desableBtnsCell(cell)
        })
    }
    
    
    

    func goToLadBrokes(selection: NSDictionary){
        
        var currentPrice:NSDictionary!  = selection.objectForKey("currentPrice") as NSDictionary //denPrice = 1; numPrice = 100;
        var selectionKey:AnyObject!     = selection.objectForKey("selectionKey")
        
        if(selectionKey != nil){
            var intSelectionKey = Int(selectionKey as NSNumber)
            var urlString = NSString(format:"https://betslip.ladbrokes.com/RemoteBetslip/bets/betslip.html?selections=%d&locale=en-GB&aff-tag=123&aff-id=123",  intSelectionKey)
            
            webViewController = GSWebViewController()
            webViewController.loadViewWithUrl(NSURL(string:urlString)!)
            GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
        }
        else{
            var alertView = UIAlertView(title: "", message: "Sorry, this selection is not possible", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
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
    
    func getScoresFromSelectionName(selectionName:NSString, titleMatche:NSString) -> NSArray{
        
        var arrayDraw = selectionName.componentsSeparatedByString("Draw ") as NSArray
        if(arrayDraw.count > 1){
            var scoreDraw = (arrayDraw.lastObject as NSString).componentsSeparatedByString(" - ") as NSArray
            return [scoreDraw.firstObject as NSString, scoreDraw.firstObject as NSString]
        }
        else{
            
            var names:NSArray = titleMatche.componentsSeparatedByString(" V ")
            
            var arraySpaces = selectionName.componentsSeparatedByString(" ") as NSArray
            var count = arraySpaces.count
            
            var maxScore = (arraySpaces[count-3] as NSString)
            var smallScore = (arraySpaces[count-1] as NSString)
            
            if(selectionName.substringToIndex(selectionName.length-6) == names[0] as NSString){
                
                return [maxScore, smallScore]
            }
            else{
                return [smallScore, maxScore]
            }
        }
    }
    
}