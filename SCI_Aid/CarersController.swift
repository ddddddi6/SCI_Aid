//
//  CarersController.swift
//  SCI_Aid
//
//  Created by Dee on 15/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import CoreLocation

class CarersController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var latitude: String!
    var longitude: String!
    var gpID: String!

    var nearbyGP: NSMutableArray
    required init?(coder aDecoder: NSCoder) {
        self.nearbyGP = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
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
        
        self.view.backgroundColor = UIColor(red: 55/255.0, green: 101/255.0, blue: 170/255.0, alpha: 1.0)

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // get current location and then search nearby gps
    // solution from: https://www.youtube.com/watch?v=qrdIL44T6FQ
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        NSLog("Found \(location.coordinate.latitude) \(location.coordinate.longitude)")
        
        if (self.latitude == nil && self.longitude == nil) {
            self.latitude = String(location.coordinate.latitude)
            self.longitude = String(location.coordinate.longitude)
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            
            self.mapView.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
            
            searchNearbyGP()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    // add info button for each annotation on map to jump to GP detail controller
    // solution from: http://stackoverflow.com/questions/28225296/how-to-add-a-button-to-mkpointannotation
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        
        let button = UIButton(type: .DetailDisclosure) as UIButton // button with info sign in it
        
        pinView?.rightCalloutAccessoryView = button
        
        let titleView = UILabel()
        titleView.textColor = UIColor.clearColor()
        titleView.font = titleView.font.fontWithSize(1)
        titleView.text = annotation.title!
        pinView!.detailCalloutAccessoryView = titleView
        
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.gpID = self.mapView.selectedAnnotations[0].subtitle!
            self.performSegueWithIdentifier("showCarerDetails", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCarerDetails"
        {
            let theDestination : PlaceViewController = segue.destinationViewController as! PlaceViewController
            theDestination.currentPlaceID = self.gpID}
    }

    // Search nearby gp from google map api and check network connection
    // solution from: https://developers.google.com/places/web-service/search#PlaceSearchRequests
    func searchNearbyGP() -> Bool{
        var flag = true as Bool
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + self.latitude + "," + self.longitude + "&radius=50000&keyword=general+practitioner&sensor=true&key=AIzaSyBp1FhLFQV2NCcXkMSO4p4lm3vuFD5g8f8")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                self.parseGPJSON(data)
                dispatch_async(dispatch_get_main_queue()) {
                    // drop pins for each gp on map
                    for gp in self.nearbyGP {
                        let c: Place = gp as! Place
                        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(c.latitude!), Double(c.longitude!))
                        let objectAnnotation = MKPointAnnotation()
                        objectAnnotation.coordinate = pinLocation
                        objectAnnotation.title = c.name
                        objectAnnotation.subtitle = c.id
                        self.mapView.layer.shadowColor = UIColor.clearColor().CGColor;
                        self.mapView.addAnnotation(objectAnnotation)
                    }
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
        // Download GPs
        return flag
    }
    
    // Parse the received json result
    // solution from: https://github.com/SwiftyJSON/SwiftyJSON
    // and https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
    func parseGPJSON(movieJSON:NSData){
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            NSLog("Found \(json["results"].count) GPs!")
            
            
            for gp in json["results"].arrayValue {
                if let
                    latitude = gp["geometry"]["location"]["lat"].double,
                    longitude = gp["geometry"]["location"]["lng"].double,
                    name = gp["name"].string,
                    id = gp["place_id"].string {
                    let c: Place = Place(latitude: latitude, longitude: longitude, name: name, id: id)
                    nearbyGP.addObject(c)
                }
            }
            
        }catch {
            print("JSON Serialization error")
        }
    }
}
