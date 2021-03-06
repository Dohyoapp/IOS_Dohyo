//
//  GSCreateCustomLeague.swift
//  GrandSlam
//
//  Created by Explocial 6 on 02/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

class GSCreateCustomLeagueViewController: UIViewController, UITextFieldDelegate, LeagueCaller, MainVCgetCustomLeaguesCaller {
    
    var scrollView:UIScrollView!
    
    var premierLeagueLabel:UILabel!
        
    var customLeagueNameTextField:UITextField!
    var numberTextField:UITextField!
    
    //var datePicker:UIDatePicker!
    var datePicker2:UIDatePicker!
    
    //var startDateLabel:UITextField!
    var finishDateLabel:UITextField!
    
    var finishDateLabel2:UILabel!
    
    var mySwitch:UISwitch!
    var prizeLabel:UITextField!
    
    var startButton:UIButton!
    
    
    var inviteLabel:UILabel!
    var socialShareViewController:GSSocialShareViewController!
    
    var dateFormatter = NSDateFormatter()
    
    
    
    var leagues:NSArray!
    var selectedLeague:PFObject!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        dateFormatter.dateFormat = "dd.MM.yyyy"

        scrollView = UIScrollView(frame:CGRectMake(0, YSTART, 320, self.view.frame.size.height - YSTART))
        scrollView.addGestureRecognizer( UITapGestureRecognizer(target: self, action:Selector("hideKeyBoard")) )
        self.view.addSubview(scrollView)
        
        premierLeagueLabel = UILabel(frame:CGRectMake(0, 3, 320, 38))
        premierLeagueLabel.textAlignment = .Center
        premierLeagueLabel.font  = UIFont(name:FONT2, size:18)
        premierLeagueLabel.textColor = SPECIALBLUE
        scrollView.addSubview(premierLeagueLabel)
        
        var blueLine = UIView(frame:CGRectMake(0, 40, 320, 2))
        blueLine.backgroundColor = SPECIALBLUE
        scrollView.addSubview(blueLine)
        
        
        customLeagueNameTextField = UITextField(frame: CGRectMake(70, 55, 180, 33))
        customLeagueNameTextField.font = UIFont(name:FONT1, size:15)
        customLeagueNameTextField.textColor = SPECIALBLUE
        customLeagueNameTextField.layer.borderColor = SPECIALBLUE.CGColor
        customLeagueNameTextField.layer.borderWidth = 1.5
        customLeagueNameTextField.textAlignment = .Center
        customLeagueNameTextField.attributedPlaceholder = NSAttributedString(string:"Name your League",
            attributes:[NSForegroundColorAttributeName: SPECIALBLUE])
        customLeagueNameTextField.delegate = self
        customLeagueNameTextField.keyboardType = UIKeyboardType.Default
        scrollView.addSubview(customLeagueNameTextField)
        
        /*
        var startOnLabel = UILabel(frame:CGRectMake(0, 100, 320, 38))
        startOnLabel.text = "Start on"
        startOnLabel.textAlignment = .Center
        startOnLabel.font  = UIFont(name:FONT2, size:18)
        startOnLabel.textColor = SPECIALBLUE
        scrollView.addSubview(startOnLabel)
        
        
        startDateLabel = UITextField(frame:CGRectMake(70, 140, 180, 38))
        startDateLabel.text = dateFormatter.stringFromDate(NSDate())
        startDateLabel.textAlignment = .Center
        startDateLabel.font  = UIFont(name:FONT3, size:18)
        startDateLabel.layer.borderColor = SPECIALBLUE.CGColor
        startDateLabel.layer.borderWidth = 1.5
        startDateLabel.textColor = SPECIALBLUE
        startDateLabel.delegate = self
        scrollView.addSubview(startDateLabel)
        */
        
        var finishAfterLabelY:CGFloat = 100//200
        
        var finishAfterLabel = UILabel(frame:CGRectMake(0, finishAfterLabelY, 320, 38))
        finishAfterLabel.text = "Finish after"
        finishAfterLabel.textAlignment = .Center
        finishAfterLabel.font  = UIFont(name:FONT2, size:18)
        finishAfterLabel.textColor = SPECIALBLUE
        scrollView.addSubview(finishAfterLabel)
        
        numberTextField = UITextField(frame: CGRectMake(70, finishAfterLabelY+50, 60, 33))
        numberTextField.font = UIFont(name:FONT3, size:15)
        numberTextField.textColor = SPECIALBLUE
        numberTextField.layer.borderColor = SPECIALBLUE.CGColor
        numberTextField.layer.borderWidth = 1.5
        numberTextField.textAlignment = .Center
        numberTextField.attributedPlaceholder = NSAttributedString(string:"3",
            attributes:[NSForegroundColorAttributeName: SPECIALBLUE])
        numberTextField.delegate = self
        numberTextField.keyboardType = UIKeyboardType.NumberPad
        scrollView.addSubview(numberTextField)
        
        var numberMatcheLabel = UILabel(frame:CGRectMake(130, finishAfterLabelY+48, 100, 38))
        numberMatcheLabel.text = "matches"
        numberMatcheLabel.textAlignment = .Center
        numberMatcheLabel.font  = UIFont(name:FONT3, size:18)
        numberMatcheLabel.textColor = SPECIALBLUE
        scrollView.addSubview(numberMatcheLabel)
        
        var orLabel = UILabel(frame:CGRectMake(0, finishAfterLabelY+90, 320, 38))
        orLabel.text = "or"
        orLabel.textAlignment = .Center
        orLabel.font  = UIFont(name:FONT3, size:18)
        orLabel.textColor = SPECIALBLUE
        scrollView.addSubview(orLabel)
        
        
        finishDateLabel = UITextField(frame:CGRectMake(70, finishAfterLabelY+130, 180, 38))
        finishDateLabel.text = dateFormatter.stringFromDate(NSDate())
        finishDateLabel.textAlignment = .Center
        finishDateLabel.font  = UIFont(name:FONT3, size:18)
        finishDateLabel.layer.borderColor = SPECIALBLUE.CGColor
        finishDateLabel.layer.borderWidth = 1.5
        finishDateLabel.textColor = SPECIALBLUE
        finishDateLabel.delegate = self
        scrollView.addSubview(finishDateLabel)
        
        var orLabel2 = UILabel(frame:CGRectMake(0, finishAfterLabelY+180, 320, 38))
        orLabel2.text = "or"
        orLabel2.textAlignment = .Center
        orLabel2.font  = UIFont(name:FONT3, size:18)
        orLabel2.textColor = SPECIALBLUE
        scrollView.addSubview(orLabel2)
        
        finishDateLabel2 = UILabel(frame:CGRectMake(70, finishAfterLabelY+230, 180, 38))
        finishDateLabel2.text = "End of the season"
        finishDateLabel2.textAlignment = .Center
        finishDateLabel2.font  = UIFont(name:FONT3, size:18)
        finishDateLabel2.layer.borderColor = SPECIALBLUE.CGColor
        finishDateLabel2.layer.borderWidth = 1.5
        finishDateLabel2.textColor = SPECIALBLUE
        scrollView.addSubview(finishDateLabel2)
        
        var endOfSeasonBtn = UIButton(frame:finishDateLabel2.frame)
        endOfSeasonBtn.addTarget(self, action:"endOfSeasonTap:", forControlEvents:.TouchUpInside)
        scrollView.addSubview(endOfSeasonBtn)
        
        var blueLine2 = UIView(frame:CGRectMake(0, finishAfterLabelY+290, 320, 2))
        blueLine2.backgroundColor = SPECIALBLUE
        scrollView.addSubview(blueLine2)
        
        
        
        var publicLabel = UILabel(frame:CGRectMake(30, finishAfterLabelY+305, 60, 38))
        publicLabel.text = "Public"
        publicLabel.textAlignment = .Center
        publicLabel.font  = UIFont(name:FONT3, size:18)
        publicLabel.textColor = SPECIALBLUE
        scrollView.addSubview(publicLabel)
        
        var publicLabel2 = UILabel(frame:CGRectMake(0, finishAfterLabelY+330, 130, 38))
        publicLabel2.text = "Anyone can join"
        publicLabel2.textAlignment = .Center
        publicLabel2.font  = UIFont(name:FONT3, size:15)
        publicLabel2.textColor = SPECIALBLUE
        scrollView.addSubview(publicLabel2)
        
        mySwitch = UISwitch(frame:CGRectMake(140, finishAfterLabelY+320, 200, 20))
        mySwitch.onTintColor = SPECIALBLUE
        mySwitch.on = true
        scrollView.addSubview(mySwitch)
        let transform = CGAffineTransformRotate(CGAffineTransformIdentity, 3.14);
        mySwitch.transform = transform;
        
        var privateLabel = UILabel(frame:CGRectMake(220, finishAfterLabelY+305, 60, 38))
        privateLabel.text = "Private"
        privateLabel.textAlignment = .Center
        privateLabel.font  = UIFont(name:FONT3, size:18)
        privateLabel.textColor = SPECIALBLUE
        scrollView.addSubview(privateLabel)
        
        var privateLabel2 = UILabel(frame:CGRectMake(200, finishAfterLabelY+330, 100, 38))
        privateLabel2.text = "Invite only"
        privateLabel2.textAlignment = .Center
        privateLabel2.font  = UIFont(name:FONT3, size:15)
        privateLabel2.textColor = SPECIALBLUE
        scrollView.addSubview(privateLabel2)
        
        
        var blueLine3 = UIView(frame:CGRectMake(0, finishAfterLabelY+380, 320, 2))
        blueLine3.backgroundColor = SPECIALBLUE
        scrollView.addSubview(blueLine3)
        
        
        prizeLabel = UITextField(frame:CGRectMake(70, finishAfterLabelY+405, 180, 38))
        prizeLabel.attributedPlaceholder = NSAttributedString(string:"Add prize",
            attributes:[NSForegroundColorAttributeName: SPECIALBLUE])
        prizeLabel.textAlignment = .Center
        prizeLabel.font  = UIFont(name:FONT3, size:18)
        prizeLabel.layer.borderColor = SPECIALBLUE.CGColor
        prizeLabel.layer.borderWidth = 1.5
        prizeLabel.textColor = SPECIALBLUE
        prizeLabel.delegate = self
        scrollView.addSubview(prizeLabel)
        
        var blueLine4 = UIView(frame:CGRectMake(0, finishAfterLabelY+470, 320, 2))
        blueLine4.backgroundColor = SPECIALBLUE
        scrollView.addSubview(blueLine4)
        
        startButton = UIButton(frame: CGRectMake(70, finishAfterLabelY+500, 180, 33))
        startButton.setTitle("Start League!", forState: .Normal)
        startButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        startButton.backgroundColor = SPECIALBLUE
        startButton.addTarget(self, action:"startTap:", forControlEvents:.TouchUpInside)
        startButton.enabled = false
        startButton.alpha = 0.4
        scrollView.addSubview(startButton)
        
        var blueLine5 = UIView(frame:CGRectMake(0, finishAfterLabelY+560, 320, 2))
        blueLine5.backgroundColor = SPECIALBLUE
        scrollView.addSubview(blueLine5)
        
        inviteLabel = UILabel(frame:CGRectMake(0, finishAfterLabelY+580, 320, 38))
        inviteLabel.text = "Invite your friends"
        inviteLabel.textAlignment = .Center
        inviteLabel.font  = UIFont(name:FONT3, size:18)
        inviteLabel.textColor = SPECIALBLUE
        scrollView.addSubview(inviteLabel)
        inviteLabel.alpha = 0
        
        socialShareViewController = GSSocialShareViewController()
        socialShareViewController.view.frame = CGRectMake(0, finishAfterLabelY+620, 320, 40)
        scrollView.addSubview(socialShareViewController.view)
        socialShareViewController.view.alpha = 0
        
        //scrollView.contentSize = CGSizeMake(320, 900)

        scrollView.contentSize = CGSizeMake(320, blueLine5.frame.origin.y)

        /*
        datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        startDateLabel.inputView = datePicker
        datePicker.addTarget(self, action: Selector("handleDatePicker"), forControlEvents: UIControlEvents.ValueChanged)
        */
        
        var nowDateString = dateFormatter.stringFromDate(NSDate())
        var arrayNowDate = nowDateString.componentsSeparatedByString(".") as NSArray
        var yearString = arrayNowDate.lastObject as! String
        var monthString = arrayNowDate[1] as! String
        if(monthString.toInt() > 5){
            var nextYear = yearString.toInt()!+1
            yearString = String(format:"%d", nextYear)
        }
        var maximumDateString = String(format:"24.05.%@", yearString)
        
        datePicker2 = UIDatePicker()
        datePicker2.maximumDate = dateFormatter.dateFromString(maximumDateString)
        datePicker2.datePickerMode = UIDatePickerMode.Date
        finishDateLabel.inputView = datePicker2
        datePicker2.addTarget(self, action: Selector("handleDatePicker2"), forControlEvents: UIControlEvents.ValueChanged)
        
        if(GSLeague.getCacheLeagues() == nil){
            GSLeague.getLeagues(self)
        }
        else   {
            leagues = GSLeague.getCacheLeagues()
            selectedLeague = (leagues.firstObject as! GSLeague).pfLeague
            premierLeagueLabel.text = String(format:"%@ Football", selectedLeague["title"] as! String)
        }
    }
    
    func endGetLeagues(data : NSArray){
        
        leagues = data
        if(leagues.count > 0){
            selectedLeague = leagues.firstObject as! PFObject
            premierLeagueLabel.text = String(format:"%@ Football", selectedLeague["title"] as! String)
        }
    }
    
    
    
    func closeView(){
        
        
    }
    /*
    func handleDatePicker() {
        
        startDateLabel.text = dateFormatter.stringFromDate(datePicker.date)
    }
    */
    func handleDatePicker2() {
        
        finishDateLabel.text = dateFormatter.stringFromDate(datePicker2.date)
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        
        var autoCorrectorMargin:CGFloat = 36
        //textField == startDateLabel ||
        if(textField == finishDateLabel || textField == numberTextField){
            autoCorrectorMargin = 0
        }
        var scrollViewFrame = scrollView.frame
        scrollViewFrame.size.height = self.view.frame.size.height-YSTART-KEYBOARD_HEIGHT-autoCorrectorMargin
        scrollView.frame = scrollViewFrame
        
        if(textField == numberTextField){
            
            finishDateLabel.alpha   = 0.4
            finishDateLabel2.alpha  = 0.4
            numberTextField.alpha   = 1
            startButton.alpha   = 1
            startButton.enabled = true
            
            numberTextField.text = "3"
            //scrollView.scrollRectToVisible(CGRectMake(0, 240, 320, 400), animated: true)
        }
        
        if(textField == finishDateLabel){
            
            numberTextField.alpha   = 0.4
            finishDateLabel2.alpha  = 0.4
            finishDateLabel.alpha   = 1
            startButton.alpha   = 1
            startButton.enabled = true
            
           // scrollView.scrollRectToVisible(CGRectMake(0, 300, 320, 400), animated: true)
        }
        
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool{
    
        hideKeyBoard()
        return true
    }
    
    func hideKeyBoard (){
        self.view.endEditing(true)
        
        var scrollViewFrame = scrollView.frame
        scrollViewFrame.size.height = self.view.frame.size.height-YSTART
        scrollView.frame = scrollViewFrame
    }
    
    func endOfSeasonTap(sender: UIButton!){
        
        finishDateLabel.alpha = 0.4
        numberTextField.alpha = 0.4
        finishDateLabel2.alpha = 1
        startButton.alpha = 1
        startButton.enabled = true
        
        hideKeyBoard()
    }
    
    
    func startTap(sender: UIButton!){
        
        if( Utils.isParseNull(selectedLeague) ){
            
            var alertView = UIAlertView(title: "", message: "Please select a league", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return
        }
        
        var leagueTitle = selectedLeague["title"] as! String
        
        
        var startDate:NSDate   = NSDate()//dateFormatter.dateFromString(startDateLabel.text)!
        // needed to show the past match in the leaderboard
        var leagueName  = customLeagueNameTextField.text
        var prize       = prizeLabel.text
        var numberOfMatches = numberTextField.text
        var publicLeague = mySwitch.on
        
        if(leagueName == ""){
            
            var alertView = UIAlertView(title: "", message: "Please enter your league name", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return
        }
        
        if(count(leagueName) > 40){
            
            var alertView = UIAlertView(title: "", message: "Your league name is too long", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return
        }
        
        if(!FieldsValidator.validateName(leagueName)){
            var alertView = UIAlertView(title: "", message: "Please verify that your league name can only include letters and  special characters like ' and -", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        if(count(prize) > 40){
            
            var alertView = UIAlertView(title: "", message: "The prize is too long", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return
        }
        
        if(prize != nil && prize != "" && !FieldsValidator.validateName(prize)){
            var alertView = UIAlertView(title: "", message: "Please verify that the prize can only include letters and  special characters like ' and -", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        
        if(startDate.timeIntervalSinceDate(NSDate()) < -24*3600){
            var alertView = UIAlertView(title: "", message: "Please enter a valid start date", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return
        }
        
        if(numberTextField.alpha == 1 && (count(numberOfMatches) == 0 || numberOfMatches == "0") ){
            
            var alertView = UIAlertView(title: "", message: "Please enter a valid number of matches", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return
        }
        
        
        var endDate:NSDate = startDate
        if(finishDateLabel.alpha == 1){
            
            endDate = dateFormatter.dateFromString(finishDateLabel.text)!
            
            if(endDate.timeIntervalSinceDate(startDate) <= 0){
                var alertView = UIAlertView(title: "", message: "Please enter a valid end date", delegate: nil, cancelButtonTitle: "Ok")
                alertView.show()
                return
            }
            
            numberOfMatches = ""
        }
        
        var endOfSeason = false
        if(finishDateLabel2.alpha == 1){
            numberOfMatches = ""
            endOfSeason = true
        }
        
        self.startButton.enabled = false
        hideKeyBoard()
        
        
        var customLeague = PFObject(className:"CustomLeague")
        customLeague["name"]            = leagueName
        customLeague["public"]          = publicLeague
        customLeague["startDate"]       = startDate
        customLeague["numberOfMatches"] = numberOfMatches
        customLeague["endDate"]         = endDate
        customLeague["endOfSeason"]     = endOfSeason
        customLeague["prize"]           = prize
        customLeague["leagueTitle"]     = leagueTitle
        
        
        if( Utils.isParseNull(PFUser.currentUser()["email"]) ){
            GSMainViewController.getMainViewControllerInstance().profileTap(nil)
            GSMainViewController.getMainViewControllerInstance().waitingCreateCustomLeague = customLeague
        }
        else{
            endCreationCustomLeague(customLeague)
        }
    }
    
    func endCreationCustomLeague(customLeague : PFObject){
        
        SVProgressHUD.show()
        var user = PFUser.currentUser()
        customLeague["mainUser"]        = user.objectId
        customLeague.save()
        var relation = user.relationForKey("myCustomLeagues")
        relation.addObject(customLeague)
        user.saveInBackgroundWithBlock { (success, error) -> Void in
            
            GSMainViewController.getMainViewControllerInstance().getCustomLeagues(true, joinedLeague:nil)
            
            self.socialShareViewController.customLeagueId = customLeague.objectId
            
            var publicLeague:Bool = customLeague["public"] as! Bool
            if(publicLeague){
                Mixpanel.sharedInstance().track("0202 - Create Public league")
            }
            else{
                Mixpanel.sharedInstance().track("0201 - Create Private league")
            }
            Mixpanel.sharedInstance().track("0203 - User starts league")
        }
    }
    
    
    func getCustomLeaguesEnd(){
        
        var alertView = UIAlertView(title: "Your league was successfully created", message: "Please invite your friends to join your league", delegate: nil, cancelButtonTitle: "Ok")
        alertView.show()
        
        SVProgressHUD.dismiss()
        self.startButton.alpha = 0.4
        
        self.scrollView.contentSize = CGSizeMake(320, 900)
        self.inviteLabel.alpha = 1
        self.socialShareViewController.view.alpha = 1
        
        
        var endView = UIView(frame:CGRectMake(0, 0, 320, 680))
        endView.backgroundColor = UIColor.whiteColor()
        endView.alpha = 0.4
        self.scrollView.addSubview(endView)
        self.scrollView.scrollRectToVisible(CGRectMake(0, 880, 320, 900), animated: true)
    }

}