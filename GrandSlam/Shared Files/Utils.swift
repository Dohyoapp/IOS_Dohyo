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
    
    class func findPGCD(a: Int, b: Int) -> Int
    {
        if(b == 0){
            return a
        }
        return findPGCD(b, b:a%b)
    }

}