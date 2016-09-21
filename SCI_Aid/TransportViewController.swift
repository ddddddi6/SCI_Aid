//
//  TransportViewController.swift
//  SCI_Aid
//
//  Created by Dee on 17/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import SwiftyJSON
import CoreLocation


class TransportViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var latitude: String!
    var longitude: String!
    var stopID: Int!
    var routeType: Int!
    var url: String!
    
    var currentStopID: String!
    var currentStopName: String!
    
    var nearbyStop: NSMutableArray
    required init?(coder aDecoder: NSCoder) {
        self.nearbyStop = NSMutableArray()
        super.init(coder: aDecoder)
    }

    var signature: Signature = Signature()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Ask for Authorisation from the User.
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        self.mapView.delegate = self
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        
        self.navigationItem.hidesBackButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showAboutPage(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showAboutSegue", sender: self)
    }
    
    // get current location and then search nearby stops
    // solution from: https://www.youtube.com/watch?v=qrdIL44T6FQ
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        NSLog("Found \(location.coordinate.latitude) \(location.coordinate.longitude)")
        
        if (self.latitude == nil && self.longitude == nil) {
            self.latitude = String(location.coordinate.latitude)
            self.longitude = String(location.coordinate.longitude)
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            
            self.mapView.setRegion(region, animated: false)
            self.locationManager.stopUpdatingLocation()
            
            
            let reponse = signature.generateURLWithDevIDAndKey("http://timetableapi.ptv.vic.gov.au/v2/nearme/latitude/" + self.latitude + "/longitude/" + self.longitude)
            url = reponse?.absoluteString
            NSLog(url!)
            
            searchNearbyStop()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    // go back to current location
    @IBAction func backToCurrentLocation(sender: AnyObject) {
        let center = CLLocationCoordinate2D(latitude:  (self.latitude as NSString).doubleValue, longitude: (self.longitude as NSString).doubleValue)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil
            return nil
        }
        
        let reuseId = "image"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
        } else {
            pinView!.annotation = annotation
        }
        
        let button = UIButton(type: .DetailDisclosure) as UIButton // button with info sign in it
        let customPointAnnotation = annotation as! CustomPointAnnotation
        if customPointAnnotation.pinCustomImageName != nil {
            pinView!.image = UIImage(named: customPointAnnotation.pinCustomImageName!)
        }
        pinView?.rightCalloutAccessoryView = button
        pinView?.rightCalloutAccessoryView?.tintColor = UIColor.blueColor()
        
        let titleView = UILabel()
        titleView.textColor = UIColor.clearColor()
        titleView.font = titleView.font.fontWithSize(1)
        titleView.text = annotation.title!
        pinView!.detailCalloutAccessoryView = titleView
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.currentStopID = self.mapView.selectedAnnotations[0].subtitle!
            self.currentStopName = self.mapView.selectedAnnotations[0].title!
            self.performSegueWithIdentifier("showStationDetails", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showStationDetails"
        {
            let theDestination : StationViewController = segue.destinationViewController as! StationViewController
            theDestination.currentStopID = self.currentStopID
            theDestination.currentStopName = self.currentStopName
        }
    }
    
    // show different annotations according to route type
    func displayStopType(data: NSMutableArray) {
        var pointAnnoation: CustomPointAnnotation!
        var annotationView: MKPinAnnotationView!
        for stop in self.nearbyStop {
            pointAnnoation = CustomPointAnnotation()
            let c: Stop = stop as! Stop
            //let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(c.latitude!), Double(c.longitude!))
            switch c.routeType! {
            case 0:
                pointAnnoation.pinCustomImageName = "train"
                break
            case 1:
                pointAnnoation.pinCustomImageName = "tram"
                break
            case 2:
                pointAnnoation.pinCustomImageName = "bus"
                break
            case 3:
                pointAnnoation.pinCustomImageName = "vline"
                break
            case 1:
                pointAnnoation.pinCustomImageName = "night_bus"
                break
            default:
                break
            }
            //let objectAnnotation = MKPointAnnotation()
            pointAnnoation.coordinate = CLLocationCoordinate2DMake(Double(c.latitude!), Double(c.longitude!))
            pointAnnoation.title = c.name
            pointAnnoation.subtitle = String(c.id!) + " " + String(c.routeType!)
            //objectAnnotation.subtitle = c.id
            //self.mapView.layer.shadowColor = UIColor.clearColor().CGColor;
            annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "image")
            self.mapView.addAnnotation(annotationView.annotation!)
            
        }
    }
    
    // Search nearby stop from google map api and check network connection
    // solution from: https://developers.google.com/places/web-service/search#PlaceSearchRequests
    func searchNearbyStop() -> Bool{
        var flag = true as Bool
        let url = NSURL(string: self.url)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                self.parseStopJSON(data)
                dispatch_async(dispatch_get_main_queue()) {
                    // drop pins for each stop on map
                    self.displayStopType(self.nearbyStop)
                }
                flag = true
            } else {
                let messageString: String = "Something wrong with the connection"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                flag = false
            }
        }
        task.resume()
        // Download stops
        return flag
    }
    
    // Parse the received json result
    // solution from: https://github.com/SwiftyJSON/SwiftyJSON
    // and https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
    func parseStopJSON(movieJSON:NSData){
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            NSLog("Found \(json.count) stops!")
            
            
            for stop in json.arrayValue {
                if let
                    latitude = stop["result"]["lat"].double,
                    longitude = stop["result"]["lon"].double,
                    name = stop["result"]["location_name"].string,
                    id = stop["result"]["stop_id"].int,
                    routeType = stop["result"]["route_type"].int {
                    let c: Stop = Stop(latitude: latitude, longitude: longitude, name: name, id: id, routeType: routeType)
                    nearbyStop.addObject(c)
                }
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
