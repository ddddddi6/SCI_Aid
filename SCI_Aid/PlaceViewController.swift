//
//  PlaceViewController.swift
//  SCI_Aid
//
//  Created by Dee on 17/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
// external library from https://github.com/SwiftyJSON/SwiftyJSON
import SwiftyJSON
import MapKit

class PlaceViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var phoneButton: UIButton!
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var addressButton: UIButton!
    
    var currentPlaceID: String?
    var coordinate: CLLocationCoordinate2D?
    
    var placeTitle: String?
    var placePhone: String?
    var placeWeb: String?
    var address: String?
    var photo: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        
        downloadPlaceData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func callNumber(sender: UIButton) {
        let number = self.phoneButton.titleLabel!.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        if let phoneCallURL:NSURL = NSURL(string:"tel://\(number)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    @IBAction func navigateAddress(sender: UIButton) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.coordinate!, addressDictionary:nil))
        mapItem.name = self.placeTitle
        mapItem.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    @IBAction func browseWebsite(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: self.placeWeb!)!)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Download selected place from the source and check network connection
    func downloadPlaceData() {
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + currentPlaceID! + "&key=AIzaSyBpHKu9KGpv-VacWvQOhrI7OVjGVdHQY9Y")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                self.parsePlaceJSON(data)
                dispatch_async(dispatch_get_main_queue()) {
                    self.title = self.placeTitle
                    self.addressButton.setTitle(self.address!, forState: .Normal)
                    self.websiteButton.setTitle(self.placeWeb!, forState: .Normal)
                    self.phoneButton.setTitle(self.placePhone!, forState: .Normal)
                    self.phoneButton.contentHorizontalAlignment = .Left
                    self.websiteButton.contentHorizontalAlignment = .Left
                    self.addressButton.contentHorizontalAlignment = .Left
                    let poster = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + self.photo! + "&key=AIzaSyBpHKu9KGpv-VacWvQOhrI7OVjGVdHQY9Y" as String
                    if let url  = NSURL(string: poster),
                        data = NSData(contentsOfURL: url)
                    {
                        self.placeImage.image = UIImage(data: data)
                    } else {
                        self.placeImage.image = UIImage(named: "noimage")
                    }
                    self.activityIndicator.stopAnimating()
                }
            } else {
                let messageString: String = "Something wrong with the connection"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        task.resume()
        // Download place
    }
    
    // Parse the received json result
    // solution from: https://github.com/SwiftyJSON/SwiftyJSON
    // and https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
    func parsePlaceJSON(movieJSON:NSData){
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            if let
                name = json["result"]["name"].string,
                phone = json["result"]["international_phone_number"].string,
                address = json["result"]["vicinity"].string {
                if let website = json["result"]["website"].string {
                    self.placeWeb = website
                   
                } else {
                    self.placeWeb = "Not avaliable"
                }
                if let photo = json["result"]["photos"][0]["photo_reference"].string{
                    self.photo = photo
                } else {
                    self.photo = "No image"
                }
                
                self.placeTitle = name
                self.placePhone = phone
                
                self.address = address
            }
        }catch {
            print("JSON Serialization error")
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
