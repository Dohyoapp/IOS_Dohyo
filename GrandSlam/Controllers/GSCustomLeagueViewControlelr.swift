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
    
    var validMatches:NSArray!
    
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
        
        
        
        var matches:NSArray = league.matches
        validMatches = customLeague.getValidMatches(matches)
        var count:CGFloat = 0
        for validMatche in validMatches{
            
            self.createMatcheCell(validMatche as PFObject, num:count)
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
        self.view.addSubview(gsLeaderBoardViewController.view)
    }


    
    func createMatcheCell(matche:PFObject, num:CGFloat){
        
        var cell = UIView(frame:CGRectMake(0, num*CELLHEIGHT, 320, CELLHEIGHT))
        cell.tag = Int(num)
        cell.backgroundColor = UIColor.whiteColor()
        scrollView.addSubview(cell)
        
        var teamsNames = GSCustomLeague.getShortTitle(matche.valueForKey("title") as NSString)
        
        var leftName:NSString   = teamsNames.firstObject as NSString
        var rightName:NSString  = teamsNames.lastObject as NSString
        var title = leftName+" V "+rightName
        
        var imageLeft   = TEAMS_IMAGES_URL_ROOT+leftName+".png"
        var imageRight  = TEAMS_IMAGES_URL_ROOT+rightName+".png"
        
        var urlLeftRequest      = NSURLRequest(URL:NSURL(string: imageLeft)!)
        var leftImageTeamView   = UIImageView(frame: CGRectMake(65, 5, 30, 30))
        leftImageTeamView.setImageWithURLRequest( urlLeftRequest, placeholderImage: nil, success: { (url, response, image) -> Void in
            leftImageTeamView.image = image
        }, failure: { (url, response, error) -> Void in
        })
        cell.addSubview(leftImageTeamView)
        
        
        var matcheLabel     = UILabel(frame:CGRectMake(78, 8, 160, 30))
        matcheLabel.text    = title
        matcheLabel.textAlignment = .Center
        matcheLabel.font    = UIFont(name:FONT3, size:18)
        matcheLabel.textColor = SPECIALBLUE
        cell.addSubview(matcheLabel)
        
        
        var urlRighttRequest    = NSURLRequest(URL:NSURL(string: imageRight)!)
        var rightImageTeamView  = UIImageView(frame: CGRectMake(220, 5, 30, 30))
        rightImageTeamView.setImageWithURLRequest( urlRighttRequest, placeholderImage: nil, success: { (url, response, image) -> Void in
            rightImageTeamView.image = image
            }, failure: { (url, response, error) -> Void in
        })
        cell.addSubview(rightImageTeamView)
        
        var leftUpButton = UIButton(frame: CGRectMake(65, 40, 30, 30))
        leftUpButton.tag = 666
        leftUpButton.setImage(UIImage(named:"Button_Up"), forState: .Normal)
        leftUpButton.addTarget(self, action:"leftUpTap:", forControlEvents:.TouchUpInside)
        cell.addSubview(leftUpButton)
        
        var leftDownButton = UIButton(frame: CGRectMake(65, 71, 30, 30))
        leftDownButton.tag = 667
        leftDownButton.setImage(UIImage(named:"Button_Down"), forState: .Normal)
        leftDownButton.addTarget(self, action:"leftDownTap:", forControlEvents:.TouchUpInside)
        cell.addSubview(leftDownButton)
        
        var rightUpButton = UIButton(frame: CGRectMake(220, 40, 30, 30))
        rightUpButton.tag = 668
        rightUpButton.setImage(UIImage(named:"Button_Up"), forState: .Normal)
        rightUpButton.addTarget(self, action:"rightUpTap:", forControlEvents:.TouchUpInside)
        cell.addSubview(rightUpButton)
        
        var righttDownButton = UIButton(frame: CGRectMake(220, 71, 30, 30))
        righttDownButton.tag = 669
        righttDownButton.setImage(UIImage(named:"Button_Down"), forState: .Normal)
        righttDownButton.addTarget(self, action:"rightDownTap:", forControlEvents:.TouchUpInside)
        cell.addSubview(righttDownButton)
        
        
        var leftScoreLabel  = UILabel(frame:CGRectMake(95, 26, 60, 100))
        leftScoreLabel.tag  = 888
        leftScoreLabel.text = "0"
        leftScoreLabel.textAlignment = .Center
        leftScoreLabel.font = UIFont(name:FONT2, size:44)
        leftScoreLabel.textColor = SPECIALBLUE
        cell.addSubview(leftScoreLabel)
        
        var centerScoreLabel    = UILabel(frame:CGRectMake(127, 40, 60, 60))
        centerScoreLabel.text   = "-"
        centerScoreLabel.textAlignment = .Center
        centerScoreLabel.font   = UIFont(name:FONT2, size:44)
        centerScoreLabel.textColor = SPECIALBLUE
        cell.addSubview(centerScoreLabel)
        
        var rightScoreLabel     = UILabel(frame:CGRectMake(160, 26, 60, 100))
        rightScoreLabel.tag     = 999
        rightScoreLabel.text = "0"
        rightScoreLabel.textAlignment = .Center
        rightScoreLabel.font    = UIFont(name:FONT2, size:44)
        rightScoreLabel.textColor = SPECIALBLUE
        cell.addSubview(rightScoreLabel)
        
        var bettButton = UIButton(frame: CGRectMake(90, 115, 140, 43))
        bettButton.backgroundColor = SPECIALBLUE
        bettButton.addTarget(self, action:"bettButtonTap:", forControlEvents:.TouchUpInside)
        cell.addSubview(bettButton)
        
        var bettLabel     = UILabel(frame:CGRectMake(0, 0, bettButton.frame.size.width, bettButton.frame.size.height))
        bettLabel.tag = 777
        bettLabel.numberOfLines = 0
        bettLabel.text    = BETTLABEL_TEXT1
        bettLabel.textAlignment = .Center
        bettLabel.font    = UIFont(name:FONT3, size:13)
        bettLabel.textColor = UIColor.whiteColor()
        bettButton.addSubview(bettLabel)
        
        var score = customLeague.getMatcheScore(matche.objectId)
        var scores:NSArray = score.componentsSeparatedByString(" - ")
        if(scores.count > 1){
            desableBtnsCell(cell)
            leftScoreLabel.text = scores.firstObject as NSString
            rightScoreLabel.text = scores.lastObject as NSString
        }
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
    
    
    func bettButtonTap(sender: UIButton!){
    
        var cell    = (sender as UIView).superview!
        var row     = cell.tag
        
        var matche:PFObject     = validMatches[row] as PFObject
        
        var leftScore:NSString  = (cell.viewWithTag(888) as UILabel).text!
        var rightScore:NSString = (cell.viewWithTag(999) as UILabel).text!
        
        var bettLabel = (cell.viewWithTag(777) as UILabel)
        
        var currentSelectionName:NSString = "Draw "+leftScore+" - "+rightScore
        if(leftScore != rightScore){
            var longTitle = matche.valueForKey("title") as NSString
            var names:NSArray = longTitle.componentsSeparatedByString(" V ")
            
            if(leftScore.intValue > rightScore.intValue ){
                currentSelectionName = (names.firstObject as NSString)+" "+leftScore+" - "+rightScore
            }else{
                currentSelectionName = (names.lastObject as NSString)+" "+rightScore+" - "+leftScore
            }
        }
        
        
        if(bettLabel.text == BETTLABEL_TEXT1){
            var score = leftScore+" - "+rightScore
            saveUserMatchDetails(matche, details:score, cell:cell)
        }
        else{
           getSelection(matche, selectionName: currentSelectionName)
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

    
    func getSelection(matche:PFObject, selectionName:NSString){
        
        var selections: AnyObject! = matche.objectForKey("selection")
        
        if(selections == nil){
            loadMatcheSelection(matche, selectionName: selectionName)
        }
        else{
            
            var selection:NSDictionary
            for selection in (selections as NSArray) {
                
                if(selection.objectForKey("selectionName") as NSString == selectionName){
                    
                    SVProgressHUD.dismiss()
                    
                    
                    self.goToLadBrokes(selection as NSDictionary)
                }
            }
        }
    }
    
    
    
    /*
dispatch_after(1, dispatch_get_main_queue(), {
// your function here
getSelection(matche, selectionName:selectionName)
})*/
    
    
    
    
    func loadMatcheSelection(matche:PFObject, selectionName:NSString){
        
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
            var marketsEventArray:NSArray = ((jsonData["event"] as NSDictionary)["markets"] as NSDictionary)["market"] as NSArray
            
            
            var marketJson:NSDictionary
            for marketJson in marketsEventArray {
                
                if((marketJson["marketName"] as NSString == "Correct score")){
                    
                    matche["selection"] = (marketJson["selections"] as NSDictionary)["selection"] as NSArray
                    matche.saveInBackgroundWithBlock({ (success, error) -> Void in
                        SVProgressHUD.dismiss()
                    })
                    self.getSelection(matche, selectionName:selectionName)
                }
            }
            
            
        }
        
        task.resume()
        
        
    }
    
}