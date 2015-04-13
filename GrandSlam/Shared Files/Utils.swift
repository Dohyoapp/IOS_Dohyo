//
//  Utils.swift
//  GrandSlam
//
//  Created by Explocial 6 on 26/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


class Utils {

    class func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, 100, 100))
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func findPGCD(a: NSInteger, b: NSInteger) -> NSInteger
    {
        if(b == 0){
            return a
        }
        return findPGCD(b, b:a%b)
    }
    
    
    class func isParseNull(obj : AnyObject!) -> Bool {
        if obj == nil {
            return true
        }
        if obj as! NSObject == NSNull() {
            return true
        }
        return false
    }

}