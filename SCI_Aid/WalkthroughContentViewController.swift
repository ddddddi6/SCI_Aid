//
//  WalkthroughContentViewController.swift
//  SCI_Aid
//
//  Created by Dee on 19/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit


weak var pageControl: UIPageControl!
class WalkthroughContentViewController: UIViewController {
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var forwardButton: UIButton!
    
    var index = 0
    var heading = ""
    var imageFile = ""
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.currentPage = index
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(WalkthroughContentViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = .Left
        
        forwardButton.backgroundColor = UIColor.clearColor()
        forwardButton.layer.cornerRadius = 10
        forwardButton.layer.borderWidth = 3
        forwardButton.layer.borderColor = UIColor(red: 247/255.0, green: 242/255.0, blue: 119/255.0, alpha: 1.0).CGColor
        
        switch index {
        case 0...6: forwardButton.hidden = true
        case 7:
            forwardButton.setTitle(" OK, got it ", forState: UIControlState.Normal)
            self.view.addGestureRecognizer(swipeLeft)
        default: break
        }
        
        contentImageView.image = UIImage(named: imageFile)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        
        switch index {
        case 7:
            dismissViewControllerAnimated(true, completion: nil)
        default: break
        }
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
