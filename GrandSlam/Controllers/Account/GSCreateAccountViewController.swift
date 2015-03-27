//
//  GSCreateAccountViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 28/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

let PLACEHOLDER1 = "User Name"
let PLACEHOLDER2 = "Email"
let PLACEHOLDER3 = "Password"
let PLACEHOLDER4 = "Confirm Password"

let LASTROW_INDEX = 4




class GSCreateAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, EmailValidationDelegate, FaceBookDelegate, UIAlertViewDelegate {
    
    var tableView = UITableView(frame:CGRectZero)
    
    var signInViewController = GSSignInViewController()
    var forgotPasswordViewController = GSForgotPasswordViewController()
    
    var tableViewCell:NSMutableArray!
    
    var isFromCreateLeague:Bool = false
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableViewCell = NSMutableArray()
        tableViewCell.addObject(GSCreateAccountCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"CustomCell"))
        tableViewCell.addObject(GSCreateAccountCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"CustomCell"))
        tableViewCell.addObject(GSCreateAccountCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"CustomCell"))
        tableViewCell.addObject(GSCreateAccountCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"CustomCell"))
        tableViewCell.addObject(GSCreateAccountCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"CustomCell"))
        tableViewCell.addObject(GSCreateAccountCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"CustomCell"))
        //GSMainViewController.getMainViewControllerInstance().viewDidDisappear(false);
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        tableView.frame         = CGRectMake(0, YSTART, self.view.frame.size.width, self.view.frame.size.height-YSTART)
        tableView.dataSource    = self
        tableView.delegate      = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle  = .None
        tableView.addGestureRecognizer( UITapGestureRecognizer(target: self, action:Selector("hideKeyBoard")) )
        self.view.addSubview(tableView)
        
    }
    
    func closeView(){
        
        self.view.removeFromSuperview()
        GSMainViewController.getMainViewControllerInstance().createAccountView = false
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }else{
            return 6
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        if(indexPath.section == 0){
            return 240
        }else if(indexPath.row == 5){
            return 500
        }
        else{
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            
            var cell = UITableViewCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"MainCustomCell")
            createMainCell(cell)
            cell.selectionStyle = .None
            return cell
        }
        else{
            
            var reuseIdentifier = NSString(format: "CustomCell%d", indexPath.row)
            
            var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as GSCreateAccountCell!
            if(cell == nil){
                cell = GSCreateAccountCell(style:UITableViewCellStyle.Value1, reuseIdentifier: reuseIdentifier)
            }
            tableViewCell.replaceObjectAtIndex(indexPath.row, withObject: cell)
                //.insertObject(cell, atIndex: indexPath.row)
            cell.selectionStyle = .None
            
            var placeHolderText = ""
            switch indexPath.row
            {
            case 0:
                placeHolderText = PLACEHOLDER1
            case 1:
                placeHolderText = PLACEHOLDER2
            case 2:
                placeHolderText = PLACEHOLDER3
            case 3:
                placeHolderText = PLACEHOLDER4
            default:
                placeHolderText = ""
            }
            
            cell.textField.attributedPlaceholder = NSAttributedString(string:placeHolderText,
                attributes:[NSForegroundColorAttributeName: SPECIALBLUE])
            cell.textField.delegate = self
            cell.textField.tag = indexPath.row
            
            cell.textField.secureTextEntry = false
            if(indexPath.row == 2 || indexPath.row == 3){
                cell.textField.secureTextEntry = true
            }
            
            cell.viewWithTag(555)?.removeFromSuperview()
            if(indexPath.row == LASTROW_INDEX){
                
                var signInButton = UIButton(frame: CGRectMake(60, 0, 200, 33))
                signInButton.tag = 555
                signInButton.setTitle("Create Account", forState: .Normal)
                signInButton.titleLabel!.font = UIFont(name:FONT3, size:15)
                signInButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                signInButton.backgroundColor = SPECIALBLUE
                signInButton.addTarget(self, action:"createAccountTap", forControlEvents:.TouchUpInside)
                cell.addSubview(signInButton)
            }
            
            cell.textField.hidden = false
            cell.viewWithTag(345)?.removeFromSuperview()
            if(indexPath.row == 5){
                cell.textField.hidden = true
                cell.addSubview(createTermsAndConditions())
                addButtonsToCell(cell)
            }
            
            return cell
        }
    }
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.section == 1 && indexPath.row == LASTROW_INDEX){
            
        }
    }
    
    func createMainCell(cell : UITableViewCell){
        
        var signInButton = UIButton(frame: CGRectMake(60, 25, 200, 33))
        signInButton.setTitle("Sign in", forState: .Normal)
        signInButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        signInButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signInButton.backgroundColor = SPECIALBLUE
        signInButton.addTarget(self, action:"singInTap:", forControlEvents:.TouchUpInside)
        cell.addSubview(signInButton)
        
        var forgotPWButton = UIButton(frame: CGRectMake(60, 60, 200, 33))
        forgotPWButton.setTitle("Forgot my password", forState: .Normal)
        forgotPWButton.titleLabel!.font = UIFont(name:FONT2, size:15)
        forgotPWButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        forgotPWButton.backgroundColor = UIColor.whiteColor()
        forgotPWButton.addTarget(self, action:"forgotPWTap:", forControlEvents:.TouchUpInside)
        cell.addSubview(forgotPWButton)
        
        var fbLoginButton = UIButton(frame: CGRectMake(60, 120, 200, 33))
        fbLoginButton.setTitle("Login with Facebook", forState: .Normal)
        fbLoginButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        fbLoginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        fbLoginButton.backgroundColor = SPECIALBLUE
        fbLoginButton.addTarget(self, action:"fbLoginTap:", forControlEvents:.TouchUpInside)
        cell.addSubview(fbLoginButton)
        
        let orEmailLabel = UILabel(frame: CGRectMake(50, 180, 220, 33))
        orEmailLabel.text = "Or create an account with email"
        orEmailLabel.textAlignment = .Center
        orEmailLabel.font = UIFont(name:FONT3, size:15)
        orEmailLabel.textColor = SPECIALBLUE
        cell.addSubview(orEmailLabel)
    }
    
    
    func singInTap(sender: UIButton!){
        
        self.view.addSubview(signInViewController.view)
    }
    
    func forgotPWTap(sender: UIButton!){
        
        self.view.addSubview(forgotPasswordViewController.view)
    }
    
    func fbLoginTap(sender: UIButton!){

        PFFacebookUtils.unlinkUserInBackground(PFUser.currentUser()) { (success, error) -> Void in
            ParseConfig.fbLogin1(self)
        }
    }
    
    func endFaceBookLogIn(){
        ParseConfig.getFacebookData(self)
    }
    
    func endGetFacebookData(){
        self.closeView()
        GSMainViewController.getMainViewControllerInstance().getCustomLeagues(false, joinedLeague:nil)
        navigationBar.goToCreateViewController()
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        if(buttonIndex == 1){
            hasAcceptedOptEmail = true
            setAcceptOptEmailImage()
            createAccountTap()
        }
    }
    
    
    func createAccountTap(){
        
        //var cell:GSCreateAccountCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow:0, inSection:1)) as GSCreateAccountCell
        
        var cell:GSCreateAccountCell = tableViewCell.objectAtIndex(0) as GSCreateAccountCell
        var name:NSString = cell.textField.text
        
        //var cell1:GSCreateAccountCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow:1, inSection:1)) as GSCreateAccountCell
        var cell1:GSCreateAccountCell = tableViewCell.objectAtIndex(1) as GSCreateAccountCell
        var email:NSString = cell1.textField.text
        
        //var cell2:GSCreateAccountCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow:2, inSection:1)) as GSCreateAccountCell
        var cell2:GSCreateAccountCell = tableViewCell.objectAtIndex(2) as GSCreateAccountCell
        var password:NSString = cell2.textField.text
        
        //var cell3:GSCreateAccountCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow:3, inSection:1)) as GSCreateAccountCell
        var cell3:GSCreateAccountCell = tableViewCell.objectAtIndex(3) as GSCreateAccountCell
        var confirmPassword:NSString = cell3.textField.text
        
        if(name.length < 2){
            var alertView = UIAlertView(title: "", message: "Please enter your user name", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        if(name.length > 40){
            
            var alertView = UIAlertView(title: "", message: "Your user name is too long", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return
        }
        
        if(!FieldsValidator.validateName(name)){
            var alertView = UIAlertView(title: "", message: "Please verify that your user name can only include letters and  special characters like ' and -", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        if(email.length < 2){
            var alertView = UIAlertView(title: "", message: "Please enter your email.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        if(password.length < 2 || confirmPassword.length < 2){
            var alertView = UIAlertView(title: "", message: "Please enter password.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        if(password.length < 6){
            
            var alertView = UIAlertView(title: "", message: "Uh oh...the passwords is too short. \nPlease enter more than 6 characters.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        if ( !password.isEqualToString(confirmPassword) ) {
            
            var alertView = UIAlertView(title: "", message: "Uh oh...the passwords don't match. \nPlease try again.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        if(!hasAcceptedOptEmail){
            var alertView = UIAlertView(title: "", message: "By clicking 'Continue', you agree with the Terms & Conditions and accept the Privacy Policy", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "Continue")
            alertView.show()
            return
        }
        
        self.oldUserName = PFUser.currentUser()["username"]
        self.oldPassword = PFUser.currentUser().password
        PFUser.currentUser()["username"] = name
        PFUser.currentUser().password = password
        
        SVProgressHUD.show()
        FieldsValidator.fullValidationEmail(email, delegate: self)
    }
    
    var oldUserName:AnyObject!
    var oldPassword:String!
    var oldEmail:AnyObject!
    
    func validEmail(email: NSString){
        
        if(email.isEqualToString("")){//failed
            
            SVProgressHUD.dismiss()
            var alertView = UIAlertView(title: "Invalid email", message: "The email address you entered appears to be invalid.", delegate:nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
        else{//success
            
            var user =  PFUser.currentUser()
            
            self.oldEmail = user["email"]
            user["email"] = email
            user["pPTC"]  = hasAcceptedOptEmail
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                SVProgressHUD.dismiss()
                if(error != nil){
                    
                    var userInfoDico:NSDictionary = error.userInfo!
                    var message = userInfoDico.objectForKey("error") as NSString
                    
                    if(self.oldEmail == nil){
                         PFUser.currentUser().removeObjectForKey("email")
                    }else{
                         user["email"] = self.oldEmail
                    }
                    
                    user.password = self.oldPassword
                    
                    var alertView = UIAlertView(title: "", message: message, delegate:nil, cancelButtonTitle: "Ok")
                    alertView.show()
                    
                    if(self.oldUserName == nil){
                        PFUser.currentUser().removeObjectForKey("username")
                    }else{
                        user["username"] = self.oldUserName
                    }
                
                }else{
                    self.closeView()
                    GSMainViewController.getMainViewControllerInstance().getCustomLeagues(false, joinedLeague:nil)
                }
            })
            
            var from = "Profile"
            if(isFromCreateLeague){
                from = "CreateLeague"
            }
            Mixpanel.sharedInstance().track("0101 - Register", properties: [
                "from": from
            ])
        }
    }
    
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        
        var tableViewFrame = tableView.frame
        if(tableViewFrame.size.height > self.view.frame.size.height-KEYBOARD_HEIGHT){
            tableViewFrame.size.height = tableViewFrame.size.height-KEYBOARD_HEIGHT-36
            tableView.frame = tableViewFrame
        }
        
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow:0, inSection:1), atScrollPosition: .Top, animated: false)
        
        if(textField.tag == 2 || textField.tag == 3){
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow:3, inSection:1), atScrollPosition: .Top, animated: false)
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        var indexPath:NSIndexPath = tableView.indexPathForCell(textField.superview as UITableViewCell)! as NSIndexPath
        if(indexPath.row < LASTROW_INDEX-1){
                
            var nextIndexPath = NSIndexPath(forRow:indexPath.row+1, inSection:indexPath.section)
            var cell:GSCreateAccountCell = tableView.cellForRowAtIndexPath(nextIndexPath) as GSCreateAccountCell
            cell.textField.becomeFirstResponder()
        }
        else{
            createAccountTap()
        }
    
        return true;
    }
    
    func hideKeyBoard (){
        self.view.endEditing(true)
        var tableViewFrame = tableView.frame
        tableViewFrame.size.height = self.view.frame.size.height-YSTART
        tableView.frame = tableViewFrame
    }
    
    var acceptTermsImageView:UIImageView!
    var acceptTermsLabel:UILabel!
    
    var hasAcceptedOptEmail = true
    
    func createTermsAndConditions() -> UIView{
        
        var acceptTAndCView = UIView(frame:CGRectMake(0, 0, 320, 40))
        acceptTAndCView.tag = 345
        acceptTAndCView.backgroundColor = UIColor.clearColor()
        
        var tick_boxImageView = UIImageView(frame:CGRectMake(60, 10, 20, 20))
        tick_boxImageView.image = UIImage(named:"box_unticked")
        acceptTAndCView.addSubview(tick_boxImageView)
        
        acceptTermsImageView = UIImageView(frame:CGRectMake(60, 9, 20, 20))
        acceptTermsImageView.image = nil
        acceptTermsImageView.userInteractionEnabled = true
        acceptTAndCView.addSubview(self.acceptTermsImageView)
        
        acceptTermsLabel = UILabel(frame:CGRectMake(80, 6, 260, 30))
        acceptTermsLabel.text = " I have read the"
        acceptTermsLabel.font = UIFont(name:FONT3, size:13)
        acceptTermsLabel.textColor = SPECIALBLUE
        acceptTermsLabel.backgroundColor = UIColor.clearColor()
        acceptTermsLabel.userInteractionEnabled  = true
        acceptTAndCView.addSubview(self.acceptTermsLabel)
        
        var acceptTermsLabel2 = UILabel(frame:CGRectMake(50, 25, 160, 30))
        acceptTermsLabel2.text = "and agree with the"
        acceptTermsLabel2.font = UIFont(name:FONT3, size:13)
        acceptTermsLabel2.textColor = SPECIALBLUE
        acceptTermsLabel2.backgroundColor = UIColor.clearColor()
        acceptTermsLabel2.userInteractionEnabled  = true
        acceptTAndCView.addSubview(acceptTermsLabel2)
        
        acceptTAndCView.addGestureRecognizer( UITapGestureRecognizer(target: self, action:Selector("acceptViewTap")) )
        
        var ppButton = UIButton(frame: CGRectMake(160, 6, 120, 30))
        ppButton.setTitle("Privacy Policy", forState: .Normal)
        ppButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        ppButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        ppButton.backgroundColor = UIColor.clearColor()
        ppButton.addTarget(self, action:"ppTap", forControlEvents:.TouchUpInside)
        acceptTAndCView.addSubview(ppButton)
        
        
        var tcButton = UIButton(frame: CGRectMake(135, 25, 180, 30))
        tcButton.setTitle("Terms & Conditions", forState: .Normal)
        tcButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        tcButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        tcButton.backgroundColor = UIColor.clearColor()
        tcButton.addTarget(self, action:"tcTap", forControlEvents:.TouchUpInside)
        acceptTAndCView.addSubview(tcButton)
        
        setAcceptOptEmailImage()
        
        
        
        var textView = UITextView(frame: CGRectMake(35, 70, 260, 230))
        textView.textAlignment = .Center
        var text = NSMutableAttributedString(string:"Ladbrokes Betting & Gaming Ltd. is licensed (licence no. 1611) and regulated by the British Gambling Commission for persons gambling in Great Britain and Ladbrokes International plc & Ladbrokes Sportsbook LP, Suites 6-8, 5th Floor, Europort, Gibraltar are licensed (RGL Nos. 010, 012 & 044) by the Government of Gibraltar and regulated by the Gibraltar Gambling Commissioner.")
        var font1 = UIFont(name:FONT3, size:12)
        var font2 = UIFont(name:FONT2, size:12)
        text.addAttribute(NSForegroundColorAttributeName, value:SPECIALBLUE, range:NSMakeRange(0, text.length))
        text.addAttribute(NSFontAttributeName, value:font1!, range:NSMakeRange(0, text.length))
        text.addAttribute(NSFontAttributeName, value:font2!, range:NSMakeRange(44, 18))
        textView.attributedText = text;
        acceptTAndCView.addSubview(textView)
        
        
        return acceptTAndCView
    }
    
    
    func addButtonsToCell(cell : GSCreateAccountCell){
        
        var licence1611Button = UIButton(frame: CGRectMake(35, 86, 120, 30))
        licence1611Button.backgroundColor = UIColor.clearColor()
        licence1611Button.addTarget(self, action:"licence1611ButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(licence1611Button)
        
        
        var lbTcButton = UIButton(frame: CGRectMake(35, 240, 120, 30))
        lbTcButton.setTitle("Ladbrokes T&Cs", forState: .Normal)
        lbTcButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        lbTcButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        lbTcButton.backgroundColor = UIColor.clearColor()
        lbTcButton.addTarget(self, action:"lbTcButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(lbTcButton)
        
        var lbPrivacyButton = UIButton(frame: CGRectMake(155, 240, 140, 30))
        lbPrivacyButton.setTitle("Ladbrokes Privacy", forState: .Normal)
        lbPrivacyButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        lbPrivacyButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        lbPrivacyButton.backgroundColor = UIColor.clearColor()
        lbPrivacyButton.addTarget(self, action:"lbPpButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(lbPrivacyButton)
        
        var lbPolicyButton = UIButton(frame: CGRectMake(35, 270, 40, 30))
        lbPolicyButton.setTitle("Policy", forState: .Normal)
        lbPolicyButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        lbPolicyButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        lbPolicyButton.backgroundColor = UIColor.clearColor()
        lbPolicyButton.addTarget(self, action:"lbPpButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(lbPolicyButton)
        
        var lbRGButton = UIButton(frame: CGRectMake(70, 270, 230, 30))
        lbRGButton.setTitle("Ladbrokes Responsible Gambling", forState: .Normal)
        lbRGButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        lbRGButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        lbRGButton.backgroundColor = UIColor.clearColor()
        lbRGButton.addTarget(self, action:"lbRGButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(lbRGButton)
        
        var coockiePButton = UIButton(frame: CGRectMake(35, 300, 180, 30))
        coockiePButton.setTitle("Ladbrokes Cookie Policy", forState: .Normal)
        coockiePButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        coockiePButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        coockiePButton.backgroundColor = UIColor.clearColor()
        coockiePButton.addTarget(self, action:"coockiePButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(coockiePButton)
        
        var gameCareButton = UIButton(frame: CGRectMake(190, 300, 100, 30))
        gameCareButton.setTitle("GamCare", forState: .Normal)
        gameCareButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        gameCareButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        gameCareButton.backgroundColor = UIColor.clearColor()
        gameCareButton.addTarget(self, action:"gameCareButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(gameCareButton)
        
        var rgtButton = UIButton(frame: CGRectMake(35, 330, 260, 30))
        rgtButton.setTitle("Responsible Gambling Trust Remote", forState: .Normal)
        rgtButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        rgtButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        rgtButton.backgroundColor = UIColor.clearColor()
        rgtButton.addTarget(self, action:"rgtButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(rgtButton)
        
        var gfgButton = UIButton(frame: CGRectMake(35, 360, 180, 30))
        gfgButton.setTitle("Gambling form Gibraltar", forState: .Normal)
        gfgButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        gfgButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        gfgButton.backgroundColor = UIColor.clearColor()
        gfgButton.addTarget(self, action:"gfgButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(gfgButton)
        
        var gComissionButton = UIButton(frame: CGRectMake(190, 360, 100, 30))
        gComissionButton.setTitle("Gambling", forState: .Normal)
        gComissionButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        gComissionButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        gComissionButton.backgroundColor = UIColor.clearColor()
        gComissionButton.addTarget(self, action:"gComissionButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(gComissionButton)
        
        var gComissionButton2 = UIButton(frame: CGRectMake(30, 390, 100, 30))
        gComissionButton2.setTitle("Commission", forState: .Normal)
        gComissionButton2.titleLabel!.font = UIFont(name:FONT2, size:13)
        gComissionButton2.setTitleColor(SPECIALBLUE, forState: .Normal)
        gComissionButton2.backgroundColor = UIColor.clearColor()
        gComissionButton2.addTarget(self, action:"gComissionButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(gComissionButton2)
        
        var gTherappyButton = UIButton(frame: CGRectMake(110, 390, 170, 30))
        gTherappyButton.setTitle("Gambling Therapy", forState: .Normal)
        gTherappyButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        gTherappyButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        gTherappyButton.backgroundColor = UIColor.clearColor()
        gTherappyButton.addTarget(self, action:"gTherappyButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(gTherappyButton)
        
        var essaButton = UIButton(frame: CGRectMake(260, 390, 40, 30))
        essaButton.setTitle("Essa", forState: .Normal)
        essaButton.titleLabel!.font = UIFont(name:FONT2, size:13)
        essaButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        essaButton.backgroundColor = UIColor.clearColor()
        essaButton.addTarget(self, action:"essaButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(essaButton)
        
        
        var ageButton = UIButton(frame: CGRectMake(135, 440, 50, 50))
        ageButton.setImage(UIImage(named:"Over_18"), forState: .Normal)
        ageButton.addTarget(self, action:"ageButtonTap", forControlEvents:.TouchUpInside)
        cell.addSubview(ageButton)
    }
    
    
    
    

    func acceptViewTap(){
    
        hasAcceptedOptEmail = !hasAcceptedOptEmail;
        setAcceptOptEmailImage()
    }
    
    func setAcceptOptEmailImage(){
    
        if (hasAcceptedOptEmail){
            acceptTermsImageView.image = UIImage(named:"ticker.png")
        }else{
            acceptTermsImageView.image = nil
        }
    }
    
    func ppTap(){
        
        webViewController = GSWebViewController()
        webViewController.loadViewWithUrl(NSURL(string:appConfigData["PrivacyPolicy"] as NSString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func tcTap(){
        
        webViewController = GSWebViewController()
        webViewController.loadViewWithUrl(NSURL(string:appConfigData["TermsConditions"] as NSString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    
    var webViewController:GSWebViewController!
    
    func licence1611ButtonTap(){
        
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"https://secure.gamblingcommission.gov.uk/gccustomweb/PublicRegister/PRSearch.aspx?ExternalAccountId=1611")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func lbTcButtonTap(){
        
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"http://help.ladbrokes.com/display/4/kb/article.aspx?aid=2665")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func lbPpButtonTap(){
    
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"http://help.ladbrokes.com/display/4/kb/article.aspx?aid=1120")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func lbRGButtonTap(){
        
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"http://help.ladbrokes.com/display/4/kb/article.aspx?aid=1077")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func coockiePButtonTap(){
    
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"http://help.ladbrokes.com/display/4/kb/article.aspx?aid=1120#r5")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func gameCareButtonTap(){
        
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"http://www.gamcare.org.uk")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func rgtButtonTap(){
        
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"http://www.responsiblegamblingtrust.org.uk")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    
    func gfgButtonTap(){
        
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"https://www.gibraltar.gov.gi/new/remote-gambling?w_id=20120704133407")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func gComissionButtonTap(){
        
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"http://www.gamblingcommission.gov.uk/Home.aspx")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func gTherappyButtonTap(){
        
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"https://www.gamblingtherapy.org/?ReferrerID=310")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func essaButtonTap(){
        
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"http://www.ladbrokes.com/essaPopup.html")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
    
    
    func ageButtonTap(){
        
        webViewController = GSWebViewController()
        
        var urlString = NSString(format:"http://help.ladbrokes.com/display/4/kb/article.aspx?aid=1077&n=1&docid=28682&tab=search#r2")
        
        webViewController.loadViewWithUrl(NSURL(string:urlString)!)
        GSMainViewController.getMainViewControllerInstance().presentViewController(webViewController, animated: true, completion: nil)
    }
}