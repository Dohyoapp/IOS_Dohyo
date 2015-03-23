//
//  GSTuttorial.swift
//  GrandSlam
//
//  Created by Mohamed Boumansour on 23/03/15.
//  Copyright (c) 2015 Explocial 6. All rights reserved.
//

import Foundation

class GSTuttorial: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {
    
    var scrollView:UIScrollView!
    var pageControl:SMPageControl!
    
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        scrollView = UIScrollView(frame:CGRectMake(0, 0, 320, self.view.frame.size.height))
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.backgroundColor = UIColor.whiteColor()
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)



        var view1   = UIImageView(frame:CGRectMake(0, 0, 320, self.view.frame.size.height))
        view1.image = UIImage(named:"Dohyo_tutorial_01_plain.jpg")
        scrollView.addSubview(view1)
        
        var view2   = UIImageView(frame:CGRectMake(320, 0, 320, self.view.frame.size.height))
        view2.image = UIImage(named:"Dohyo_tutorial_02_plain.jpg")
        scrollView.addSubview(view2)
        
        var view3   = UIImageView(frame:CGRectMake(640, 0, 320, self.view.frame.size.height))
        view3.image = UIImage(named:"Dohyo_tutorial_03_plain.jpg")
        scrollView.addSubview(view3)
        
        var view4   = UIImageView(frame:CGRectMake(960, 0, 320, self.view.frame.size.height))
        view4.image = UIImage(named:"Dohyo_tutorial_04_plain.jpg")
        scrollView.addSubview(view4)
        
        var view5   = UIImageView(frame:CGRectMake(1280, 0, 320, self.view.frame.size.height))
        view5.image = UIImage(named:"Dohyo_tutorial_05_plain.jpg")
        scrollView.addSubview(view5)
        
        scrollView.contentSize = CGSizeMake(1280+320, scrollView.frame.size.height)
        
        
        pageControl = SMPageControl(frame:CGRectMake(0, scrollView.frame.size.height-60, 320, 40))
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        pageControl.backgroundColor = UIColor.clearColor()
        pageControl.pageIndicatorImage = UIImage(named:"Tutorial_Dot_Empty")
        pageControl.currentPageIndicatorImage = UIImage(named:"Tutorial_Dot_Full")
        pageControl.indicatorDiameter = 15
        self.view.addSubview(pageControl)
        
        var skipButton = UIButton(frame: CGRectMake(220, scrollView.frame.size.height-60, 100, 40))
        skipButton.titleLabel!.font  = UIFont(name:FONT2, size:17)
        //closeButton.backgroundColor   = SPECIALBLUE
        skipButton.setTitleColor(SPECIALBLUE, forState: .Normal)
        skipButton.setTitle("Skip", forState: .Normal)
        skipButton.addTarget(self, action:"skipTap", forControlEvents:.TouchUpInside)
        self.view.addSubview(skipButton)
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var fractionalPage    = scrollView.contentOffset.x / scrollView.frame.size.width
        var page:NSInteger    = lround(Double(fractionalPage))
        if (pageControl.currentPage != page) {
            pageControl.currentPage = page;
        }
    }
    
    
    func skipTap(){
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(true, forKey: "tutorialShown")
        
        self.view.removeFromSuperview()
        GSMainViewController.getMainViewControllerInstance().endGetCustomLeagues(GSMainViewController.getMainViewControllerInstance().leagues)
    }

}