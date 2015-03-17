//
//  GSSignInViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 29/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

class GSSignInViewController: UIViewController, UITextFieldDelegate {
    
    var userNameField:UITextField!
    var passwordField:UITextField!
    
    var signInButton:UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        userNameField = UITextField(frame: CGRectMake(70, YSTART+30, 180, 33))
        userNameField.font = UIFont(name:FONT1, size:15)
        userNameField.textColor = SPECIALBLUE
        userNameField.layer.borderColor = SPECIALBLUE.CGColor
        userNameField.layer.borderWidth = 1.5
        userNameField.textAlignment = .Center
        userNameField.attributedPlaceholder = NSAttributedString(string:"User Name",
            attributes:[NSForegroundColorAttributeName: SPECIALBLUE])
        userNameField.delegate = self
        userNameField.autocapitalizationType = .None
        self.view.addSubview(userNameField)
        
        passwordField = UITextField(frame: CGRectMake(70, YSTART+70, 180, 33))
        passwordField.font = UIFont(name:FONT1, size:15)
        passwordField.textColor = SPECIALBLUE
        passwordField.layer.borderColor = SPECIALBLUE.CGColor
        passwordField.layer.borderWidth = 1.5
        passwordField.textAlignment = .Center
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
            attributes:[NSForegroundColorAttributeName: SPECIALBLUE])
        passwordField.delegate = self
        passwordField.secureTextEntry = true
        passwordField.autocapitalizationType = .None
        self.view.addSubview(passwordField)
        
        signInButton = UIButton(frame: CGRectMake(70, YSTART+110, 180, 33))
        signInButton.setTitle("Sign in", forState: .Normal)
        signInButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        signInButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signInButton.backgroundColor = SPECIALBLUE
        signInButton.addTarget(self, action:"singInTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(signInButton)
    }
    
    func closeView(){
        
        self.view.removeFromSuperview()
        GSMainViewController.getMainViewControllerInstance().createAccountViewController.closeView()
        GSMainViewController.getMainViewControllerInstance().createAccountView = false
    }
    
    
    func singInTap(sender: UIButton!){
        
        var name:NSString       = userNameField.text
        var password:NSString   = passwordField.text
        
        if(name.length < 2){
            var alertView = UIAlertView(title: "", message: "Please enter your user name", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        if(!FieldsValidator.validateName(name)){
            var alertView = UIAlertView(title: "", message: "Please verify that your user name can only include letters and  special characters like ' and -", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        if(password.length < 6){
            
            var alertView = UIAlertView(title: "", message: "Uh oh...the passwords is too short. \nPlease enter more than 6 characters.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        SVProgressHUD.show()
        PFUser.logInWithUsernameInBackground(name, password:password) {
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                // Do stuff after successful login.
                self.closeView()
                GSMainViewController.getMainViewControllerInstance().getCustomLeagues(false)
                navigationBar.goToCreateViewController()
            } else {
                // The login failed. Check error to see why.
                var alertView = UIAlertView(title: "", message: "User name / Password don't match. Please try again.", delegate: nil, cancelButtonTitle: "Ok")
                alertView.show()
            }
            SVProgressHUD.dismiss()
        }
    }
    

    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        if(textField == userNameField){
            passwordField.becomeFirstResponder()
        }
        if(textField == passwordField){
            singInTap(signInButton)
        }

        return true
    }
    
}