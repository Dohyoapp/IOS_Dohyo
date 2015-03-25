//
//  AppDelegate.swift
//  GrandSlam
//
//  Created by Explocial 6 on 21/01/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LeagueCaller {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //var objectManager = RestKitConfig.getRestKitShareManager()
        //GSUser.autho(objectManager)
       // GSUser.getClasses(objectManager)
        ParseConfig.initialization()
        Fabric.with([Crashlytics(), Twitter()])
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Clear)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        
        if ((url.scheme == "Dohyo" || url.scheme == "dohyo") && url.path?.componentsSeparatedByString("costumLeagueId").count > 1) {
            GSUser.parseUrl(url.path!)
        }
        
        return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, withSession:PFFacebookUtils.session(), fallbackHandler: { (call:FBAppCall!) -> Void in
            
            /*
            var parsedUrl = BFURL(inboundURL: url, sourceApplication:sourceApplication)
            
            if (parsedUrl.appLinkData != nil && url.scheme == "Dohyo") {
                GSUser.parseUrl(url.path!)
            }*/
        })
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        GSLeague.getLeagues(self)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        dispatch_async(dispatch_get_main_queue(), {
            GSLeague.getMatchResults(self)
        })
        GSMainViewController.getMainViewControllerInstance().getCustomLeagues(false)
        GSCustomLeague.getNewJoinLeagueNumber()
        
        
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

