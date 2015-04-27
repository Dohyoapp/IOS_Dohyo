//
//  GSLeaderBoardScrollView.swift
//  GrandSlam
//
//  Created by Explocial 6 on 27/02/2015.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation


class GSLeaderBoardScrollView: UIScrollView, UIScrollViewDelegate {

    var aCustomLeague:GSCustomLeague!
    
    var leaderBoardViewController:GSLeaderBoardViewController!
    
    var mixpanelTracked = false;
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, customLeague:GSCustomLeague!) {
        
        super.init(frame: frame)
        
        self.delegate = self
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.aCustomLeague = customLeague
        
        mixpanelTracked = false
        
        leaderBoardViewController = GSLeaderBoardViewController()
        leaderBoardViewController.customLeague = customLeague
        leaderBoardViewController.customLeague.pfCustomLeague.fetch()
        self.addSubview(leaderBoardViewController.view)
        
        var pastMatchsViewController = GSPastMatchsViewController()
        pastMatchsViewController.customLeague = customLeague
        self.addSubview(pastMatchsViewController.view)
        pastMatchsViewController.view.frame = CGRectMake(frame.size.width, 0, frame.size.width, pastMatchsViewController.view.frame.size.height)
        
        self.contentSize = CGSizeMake(frame.size.width*2, frame.size.height)
        
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
    }
    
    func closeView(){
        
        if(leaderBoardViewController != nil){
            leaderBoardViewController.closeView()
            leaderBoardViewController.view.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if(scrollView.contentOffset.x < 0){
            self.setContentOffset(CGPointMake(0, 0), animated:false)
        }
        
        if(scrollView.contentOffset.x > 300 && !mixpanelTracked){
            
            Mixpanel.sharedInstance().track("0208 - view past matches")
            mixpanelTracked = true
        }
        
        if(scrollView.contentOffset.x > 640){
            self.setContentOffset(CGPointMake(640, 0), animated:false)
        }
    }

}