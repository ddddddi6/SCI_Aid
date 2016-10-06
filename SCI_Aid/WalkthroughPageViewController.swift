//
//  WalkthroughPageViewController.swift
//  SCI_Aid
//
//  Created by Dee on 19/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    
    var pageHeadings = ["Personalize", "Locate", "Discover", "step1", "step2", "step3", "step4"]
    var pageImages = ["SCI-intro-1", "SCI-intro-2", "SCI-intro-3", "SCI-intro-4", "SCI-intro-5", "SCI-intro-6", "SCI-intro-7"]
    var pageContent = ["Pin your favorite restaurants and create your own food guide","Search and locate your favourite restaurant on Maps", "Find restaurants pinned by your friends and other foodies around the world", "step1", "step2", "step3", "step4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        // Create the first walkthrough screen
        if let startingViewController = viewControllerAtIndex(0) {
            setViewControllers([startingViewController], direction: .Forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) ->
        UIViewController? {
            var index = (viewController as! WalkthroughContentViewController).index
            index += 1
            return viewControllerAtIndex(index)
    }
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) ->
        UIViewController? {
            var index = (viewController as! WalkthroughContentViewController).index
            index -= 1
            return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> WalkthroughContentViewController? {
        if index == NSNotFound || index < 0 || index >= pageHeadings.count {
            return nil
        }
        // Create a new view controller and pass suitable data.
        if let pageContentViewController =
            storyboard?.instantiateViewControllerWithIdentifier("WalkthroughContentViewController")
                as? WalkthroughContentViewController {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.content = pageContent[index]
            pageContentViewController.index = index
            return pageContentViewController
        }
        return nil }
    
    func forward(index:Int) {
        if let nextViewController = viewControllerAtIndex(index + 1) {
            setViewControllers([nextViewController], direction: .Forward, animated:
                true, completion: nil)
        }}
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
