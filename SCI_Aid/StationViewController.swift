//
//  StationViewController.swift
//  SCI_Aid
//
//  Created by Dee on 18/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
// external library from https://github.com/SwiftyJSON/SwiftyJSON
import SwiftyJSON
import MapKit
import Foundation

class StationViewController: UIViewController {
    
    @IBOutlet var parkingImage: UIImageView!
    @IBOutlet var phoneImage: UIImageView!
    @IBOutlet var rampImage: UIImageView!
    @IBOutlet var routeType: UILabel!
    
    var currentStopID: String!
    var currentStopName: String!
    
    var url: String!
    
    var hasRamp: Bool?
    var hasPhone: Bool?
    var hasParking: Bool?
    
    var signature: Signature = Signature()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let routeType = currentStopID?.characters.last
        checkRouteType(routeType!)
        
        let stopID = String(currentStopID!.characters.dropLast()).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let reponse = signature.generateURLWithDevIDAndKey("http://timetableapi.ptv.vic.gov.au/v2/stops/?stop_id=" + stopID + "&route_type=" + String(routeType!))
        url = reponse?.absoluteString
        NSLog(url!)

        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        getStopFacility()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkRouteType(routeType: Character) {
        switch routeType {
        case "0":
            self.routeType.text = "Train Station"
            break
        case "1":
            self.routeType.text = "Tram Station"
            break
        case "2":
            self.routeType.text = "Bus Station"
            break
        case "3":
            self.routeType.text = "V/Line Station"
            break
        case "4":
            self.routeType.text = "NightRider"
            break
        default:
            break
        }
    }
    
    // Get accessible facilities information from PTV API   
    func getStopFacility() {
        let url = NSURL(string: self.url)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                self.parseFacilityJSON(data)
                dispatch_async(dispatch_get_main_queue()) {
                    self.title = self.currentStopName
                    if self.hasRamp == true {
                        self.rampImage.image = UIImage(named: "yes")
                    } else {
                        self.rampImage.image = UIImage(named: "no")
                    }
                    if self.hasParking == true {
                        self.parkingImage.image = UIImage(named: "yes")
                    } else {
                        self.parkingImage.image = UIImage(named: "no")
                    }
                    if self.hasPhone == true {
                        self.phoneImage.image = UIImage(named: "yes")
                    } else {
                        self.phoneImage.image = UIImage(named: "no")
                    }
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
        // Download stations
    }
    
    // Parse the received json result
    // solution from: https://github.com/SwiftyJSON/SwiftyJSON
    // and https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
    func parseFacilityJSON(movieJSON:NSData){
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            if let
                ramp = json["accessibility"]["wheelchair"]["accessible_ramp"].bool,
                phone = json["accessibility"]["wheelchair"]["accessible_phone"].bool,
                parking = json["accessibility"]["wheelchair"]["accessible_parking"].bool {
                    self.hasRamp = ramp
                    self.hasPhone = phone
                    self.hasParking = parking
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
