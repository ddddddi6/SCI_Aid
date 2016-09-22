//
//  TabBarViewController.swift
//  SCI_Aid
//
//  Created by Dee on 2/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import BFPaperTabBarController

class TabBarViewController: BFPaperTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().barTintColor = UIColor(red: 159/255.0, green: 122/255.0, blue: 148/255.0, alpha: 1.0)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(11)], forState: UIControlState.Selected)
        
        self.tapCircleColor = UIColor(red: 247/255.0, green: 191/255.0, blue: 107/255.0, alpha: 1.0)
    // Set this to customize the tap-circle color.
        
        self.backgroundFadeColor = UIColor(red: 247/255.0, green: 191/255.0, blue: 107/255.0, alpha: 1.0)

        self.underlineColor = UIColor.whiteColor()
        self.underlineThickness = 4
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        var tabFrame: CGRect = self.tabBar.frame
        tabFrame.size.height = 60
        tabFrame.origin.y = self.view.frame.size.height - 60
        self.tabBar.frame = tabFrame
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
