//
//  GSFieldsValidator.swift
//  GrandSlam
//
//  Created by Explocial 6 on 29/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

protocol EmailValidationDelegate {
    func validEmail(email: NSString)
}


let KGUARDPOST_MAIL_KEY = "pubkey-9c9c25d3da2c16f8b73a6518d1a10470"



class FieldsValidator {
    
    class func validateName(name: NSString) -> Bool{
        
        if(name.isKindOfClass(NSNull) || name.isEqualToString("")) {
            return false
        }
        
        var allowTest      = NSPredicate(format:"SELF MATCHES %@", "^\\w{1}[\\w ' \\._\\-]{0,40}")
        var illeaglTest    = NSPredicate(format:"SELF MATCHES %@", ".*(\\.|\\-|\\_|\\-_)$")
        var illeaglTest2   = NSPredicate(format:"SELF MATCHES %@", "^[0-9].*")
        if ( !allowTest!.evaluateWithObject(name) || illeaglTest!.evaluateWithObject(name) || illeaglTest2!.evaluateWithObject(name) )
        {
            return false;
        }
        return true;
    }
    
    
    
    
    class func validateEmail(email: NSString) -> Bool{
    
        var emailTest  = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
    
        return emailTest!.evaluateWithObject(email)
    }
    
    class func validateEmailServer(email:NSString, success:(validity:Bool) -> (), failure:(error:NSError) -> () ) {
    
        GPGuardPost.setPublicAPIKey(KGUARDPOST_MAIL_KEY)
        GPGuardPost.validateAddress(email, success: { (validity, suggestion) -> Void in
                success(validity: validity)
            }, failure:{ (error) -> Void in
                failure(error: error)
        })
    }
    
    class func fullValidationEmail(email: NSString, delegate:EmailValidationDelegate) {
        
        if (!self.validateEmail(email)) {
            delegate.validEmail("")
        }
        else{
            
            self.validateEmailServer(email, success: { (validity) -> () in
                
                if(validity){
                    delegate.validEmail(email)
                }else{
                    delegate.validEmail("")
                }
                
            },failure:{ (error) -> () in
                delegate.validEmail(email)
            })
        }

    }

}

