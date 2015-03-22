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


class GSCreateAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, EmailValidationDelegate, FaceBookDelegate {
    
    var tableView = UITableView(frame:CGRectZero)
    
    var signInViewController = GSSignInViewController()
    var forgotPasswordViewController = GSForgotPasswordViewController()
    
    var tableViewCell:NSMutableArray!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewCell = NSMutableArray()
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
            return 5
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        if(indexPath.section == 0){
            return 240
        }else{
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
            
            var cell = tableView.dequeueReusableCellWithIdentifier("CustomCell") as GSCreateAccountCell!
            if(cell == nil){
                cell = GSCreateAccountCell(style:UITableViewCellStyle.Value1, reuseIdentifier:"CustomCell")
            }
            tableViewCell.insertObject(cell, atIndex: indexPath.row)
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
                
                var signInButton = UIButton(frame: CGRectMake(70, 0, 180, 33))
                signInButton.tag = 555
                signInButton.setTitle("Create Account", forState: .Normal)
                signInButton.titleLabel!.font = UIFont(name:FONT3, size:15)
                signInButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                signInButton.backgroundColor = SPECIALBLUE
                signInButton.addTarget(self, action:"createAccountTap", forControlEvents:.TouchUpInside)
                cell.addSubview(signInButton)
            }
            
            return cell
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.section == 1 && indexPath.row == LASTROW_INDEX){
            
            var j = 5;
        }
    }
    
    func createMainCell(cell : UITableViewCell){
        
        var signInButton = UIButton(frame: CGRectMake(70, 25, 180, 33))
        signInButton.setTitle("Sign in", forState: .Normal)
        signInButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        signInButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signInButton.backgroundColor = SPECIALBLUE
        signInButton.addTarget(self, action:"singInTap:", forControlEvents:.TouchUpInside)
        cell.addSubview(signInButton)
        
        var forgotPWButton = UIButton(frame: CGRectMake(70, 60, 180, 33))
        forgotPWButton.setTitle("Forgot my password", forState: .Normal)
        forgotPWButton.titleLabel!.font = UIFont(name:FONT2, size:15)
        forgotPWButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        forgotPWButton.backgroundColor = UIColor.whiteColor()
        forgotPWButton.addTarget(self, action:"forgotPWTap:", forControlEvents:.TouchUpInside)
        cell.addSubview(forgotPWButton)
        
        var fbLoginButton = UIButton(frame: CGRectMake(70, 120, 180, 33))
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
        GSMainViewController.getMainViewControllerInstance().getCustomLeagues(false)
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
                    GSMainViewController.getMainViewControllerInstance().getCustomLeagues(false)
                }
            })
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

}