//
//  DeviceExtention.swift
//  GrandSlam
//
//  Created by Explocial 6 on 22/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import UIKit


extension UIDevice {
    
    class func isIPad() -> Bool{
        return (UIDevice.currentDevice().userInterfaceIdiom == .Pad)
    }
    
    class func isIPhone5() -> Bool {
        
        return UIScreen.mainScreen().bounds.size.height == 568;
    }
    
    class func isIPhone4() -> Bool {
        
        return UIScreen.mainScreen().bounds.size.height == 480;
    }
    
}