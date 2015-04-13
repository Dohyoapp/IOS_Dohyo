//
//  GSForgotPasswordViewController.swift
//  GrandSlam
//
//  Created by Explocial 6 on 30/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

class GSForgotPasswordViewController: UIViewController, UITextFieldDelegate, EmailValidationDelegate {
    
    var emailField:UITextField!
    var validateButton:UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        emailField = UITextField(frame: CGRectMake(70, YSTART+30, 180, 33))
        emailField.font = UIFont(name:FONT1, size:15)
        emailField.textColor = SPECIALBLUE
        emailField.layer.borderColor = SPECIALBLUE.CGColor
        emailField.layer.borderWidth = 1.5
        emailField.textAlignment = .Center
        emailField.attributedPlaceholder = NSAttributedString(string:"Email",
            attributes:[NSForegroundColorAttributeName: SPECIALBLUE])
        emailField.delegate = self
        emailField.autocapitalizationType = .None
        self.view.addSubview(emailField)
        
        
        validateButton = UIButton(frame: CGRectMake(70, YSTART+70, 180, 33))
        validateButton.setTitle("Send", forState: .Normal)
        validateButton.titleLabel!.font = UIFont(name:FONT3, size:15)
        validateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        validateButton.backgroundColor = SPECIALBLUE
        validateButton.addTarget(self, action:"validateTap:", forControlEvents:.TouchUpInside)
        self.view.addSubview(validateButton)
    }
    
    func closeView(){
        
        self.view.removeFromSuperview()
        GSMainViewController.getMainViewControllerInstance().createAccountViewController.closeView()
        GSMainViewController.getMainViewControllerInstance().createAccountView = false
    }
    
    func validateTap(sender: UIButton!){
        
        var email:String = emailField.text
        
        if(count(email) < 2){
            var alertView = UIAlertView(title: "", message: "Please enter your email.", delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return;
        }
        
        SVProgressHUD.show()
        FieldsValidator.fullValidationEmail(email, delegate: self)
    }
    
    
    func validEmail(email: String){
        
        if(email == ""){//failed
            
            SVProgressHUD.dismiss()
            var alertView = UIAlertView(title: "Invalid email", message: "The email address you entered appears to be invalid.", delegate:nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
        else{//success
            
            PFUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
                var message = ""
                if success {
                    message = "a password reset email have been send to your email address"
                    self.closeView()
                }
                else{
                    message = "Invalid Email. \nPlease try again."
                }
                SVProgressHUD.dismiss()
                var alertView = UIAlertView(title: "", message: message, delegate:nil, cancelButtonTitle: "Ok")
                alertView.show()
            })
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        if(textField == emailField){
            validateTap(validateButton)
        }
        
        return true
    }
}