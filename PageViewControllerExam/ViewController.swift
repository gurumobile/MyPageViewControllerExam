//
//  ViewController.swift
//  PageViewControllerExam
//
//  Created by Bogdan Dimitrov Filov on 10/12/16.
//  Copyright © 2016 Bogdan Dimitrov Filov. All rights reserved.
//

import UIKit

struct PageSettings {
    static let menuScrollViewY : Int = 20
    static let menuScrollViewH : Int = 40
    static let slidingLabelY : Int = 36
    static let slidingLabelH : Int = 2
    
    static let pageScrollNavigationList: [String] = [
        "🔖1Th",
        "🔖2Th",
        "🔖3Th",
        "🔖4Th"
    ]
    
    static let pageControllerIdentifierList : [String] = [
        "FirstVC",
        "SecondVC",
        "ThirdVC",
        "ForthVC"
    ]
    
    static func generateViewControllerList() -> [UIViewController] {
        var viewControllers : [UIViewController] = []
        self.pageControllerIdentifierList.forEach { viewControllerName in
            let viewController = UIStoryboard(name: "Main", bundle: nil) .
                instantiateViewControllerWithIdentifier("\(viewControllerName)")
            viewControllers.append(viewController)
        }
        return viewControllers
    }
}

class ViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate {

    var viewControllerIndex : Int = 0
    var slidingLabel : UILabel!
    var pageViewController : UIPageViewController!
    var pageContentsControllerList : [String] = []
    var menuScrollView : UIScrollView!
    var scrollButtonOffsetX : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.menuScrollView = UIScrollView()
        self.menuScrollView.delegate = self
        self.view.addSubview(self.menuScrollView)
        
        self.slidingLabel = UILabel()
        self.pageViewController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)

        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self

        self.pageViewController.setViewControllers([PageSettings.generateViewControllerList().first!], direction: .Forward, animated: false, completion: nil)
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        self.menuScrollView.frame = CGRectMake(
            CGFloat(0),
            CGFloat(PageSettings.menuScrollViewY),
            CGFloat(self.view.frame.width),
            CGFloat(PageSettings.menuScrollViewH)
        )
        self.pageViewController.view.frame = CGRectMake(
            CGFloat(0),
            CGFloat(self.menuScrollView.frame.origin.y + self.menuScrollView.frame.height),
            CGFloat(self.view.frame.width),
            CGFloat(self.view.frame.height - (self.menuScrollView.frame.origin.y + self.menuScrollView.frame.height))
        )
        self.pageViewController.view.backgroundColor = UIColor.whiteColor()
        self.menuScrollView.backgroundColor = UIColor.brownColor()
        
        self.initContentsScrollViewSettings()
        
        for i in 0...(PageSettings.pageScrollNavigationList.count - 1){
            self.addButtonToButtonScrollView(i)
        }
        self.menuScrollView.addSubview(self.slidingLabel)
        self.menuScrollView.bringSubviewToFront(self.slidingLabel)
        self.slidingLabel.frame = CGRectMake(
            CGFloat(0),
            CGFloat(PageSettings.slidingLabelY),
            CGFloat(self.view.frame.width / 3),
            CGFloat(PageSettings.slidingLabelH)
        )
        self.slidingLabel.backgroundColor = UIColor.whiteColor()
    }
    
    //MARK: - UIPageViewController DataSource Methods...
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let targetViewControllers : [UIViewController] = PageSettings.generateViewControllerList()
        
        if self.viewControllerIndex == targetViewControllers.count - 1 {
            return nil
        } else {
            self.viewControllerIndex = self.viewControllerIndex + 1
        }
        self.moveToCurrentButtonScrollView(self.viewControllerIndex)
        self.moveToCurrentButtonLabel(self.viewControllerIndex)
        
        return targetViewControllers[self.viewControllerIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let targetViewControllers : [UIViewController] = PageSettings.generateViewControllerList()
        
        if self.viewControllerIndex == 0 {
            return nil
        } else {
            self.viewControllerIndex = self.viewControllerIndex - 1
        }
        self.moveToCurrentButtonScrollView(self.viewControllerIndex)
        self.moveToCurrentButtonLabel(self.viewControllerIndex)
        
        return targetViewControllers[self.viewControllerIndex]
    }
    
    //MARK: - Initial Setting of Content Scroll...
    func initContentsScrollViewSettings() {
        
        self.menuScrollView.pagingEnabled = false
        self.menuScrollView.scrollEnabled = true
        self.menuScrollView.directionalLockEnabled = false
        self.menuScrollView.showsHorizontalScrollIndicator = false
        self.menuScrollView.showsVerticalScrollIndicator = false
        self.menuScrollView.bounces = false
        self.menuScrollView.scrollsToTop = false
        
        self.menuScrollView.contentSize = CGSizeMake(
            CGFloat(Int(self.view.frame.width) * PageSettings.pageScrollNavigationList.count / 3),
            CGFloat(PageSettings.menuScrollViewH)
        )
    }
    
    func addButtonToButtonScrollView(i: Int) {
        
        let buttonElement: UIButton! = UIButton()
        self.menuScrollView.addSubview(buttonElement)
        
        let pX: CGFloat = CGFloat(Int(self.view.frame.width) / 3 * i)
        let pY: CGFloat = CGFloat(0)
        let pW: CGFloat = CGFloat(Int(self.view.frame.width) / 3)
        let pH: CGFloat = CGFloat(self.menuScrollView.frame.height)
        
        buttonElement.frame = CGRectMake(pX, pY, pW, pH)
        buttonElement.backgroundColor = UIColor.clearColor()
        buttonElement.setTitle(PageSettings.pageScrollNavigationList[i], forState: .Normal)
        buttonElement.titleLabel!.font = UIFont(name: "Bold", size: CGFloat(16))
        buttonElement.tag = i
        buttonElement.addTarget(self, action: #selector(ViewController.buttonTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    func buttonTapped(button: UIButton){
        let page: Int = button.tag
        
        if self.viewControllerIndex != page {
            self.pageViewController.setViewControllers([PageSettings.generateViewControllerList()[page]], direction: .Forward, animated: true, completion: nil)
            
            self.viewControllerIndex = page
            
            self.moveToCurrentButtonScrollView(page)
            self.moveToCurrentButtonLabel(page)
        }
    }
    
    func moveToCurrentButtonScrollView(page: Int) {
        if page > 0 && page < (PageSettings.pageScrollNavigationList.count - 1) {
            self.scrollButtonOffsetX = Int(self.view.frame.size.width) / 3 * (page - 1)
        } else if page == 0 {
            self.scrollButtonOffsetX = 0
        } else if page == (PageSettings.pageScrollNavigationList.count - 1) {
            self.scrollButtonOffsetX = Int(self.view.frame.size.width)
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: [], animations: {
            self.menuScrollView.contentOffset = CGPointMake(
                CGFloat(self.scrollButtonOffsetX),
                CGFloat(0)
            )
        }, completion: nil)
    }
    
    func moveToCurrentButtonLabel(page: Int) {
        
        UIView.animateWithDuration(0.2, delay: 0, options: [], animations: {
            
            self.slidingLabel.frame = CGRectMake(
                CGFloat(Int(self.view.frame.width) / 3 * page),
                CGFloat(PageSettings.slidingLabelY),
                CGFloat(Int(self.view.frame.width) / 3),
                CGFloat(PageSettings.slidingLabelH)
            )
            
            }, completion: nil)
    }

}

