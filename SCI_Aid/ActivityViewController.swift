//
//  ActivityViewController.swift
//  SCI_Aid
//
//  Created by Dee on 19/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import CoreLocation
import FirebaseDatabase
import FirebaseAuth
import Firebase
import Foundation

class ActivityViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var locationButton: UIButton!
    @IBOutlet var segmentedController: UISegmentedControl!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var activityTable: UITableView!
    
    
    var locationManager: CLLocationManager!
    var latitude: String!
    var longitude: String!
    var gpID: String!
    var cellColors = [UIColor.clearColor(), UIColor(red: 106/255.0, green: 84/255.0, blue: 113/255.0, alpha: 1.0)]
    
    var ref: FIRDatabaseReference!
    
    var currentCategory: String!
    var categories = [String]()
    
    var nearbyGP: NSMutableArray
    required init?(coder aDecoder: NSCoder) {
        //initialization of nearby gp array
        self.nearbyGP = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    // listen for segmentContreller value changed
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedController.selectedSegmentIndex
        {
        case 0:
            mapView.hidden = false
            activityTable.hidden = true
            locationButton.hidden = false
            break
        case 1:
            mapView.hidden = true
            activityTable.hidden = false
            locationButton.hidden = true
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.hidden = false
        activityTable.hidden = true
        
        self.locationManager = CLLocationManager()
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Ask for Authorisation from the User.
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        self.mapView.delegate = self
        
        self.activityTable.delegate = self
        self.activityTable.dataSource = self
        self.activityTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.activityTable.rowHeight = 80
        self.activityTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.navigationItem.hidesBackButton = true
        
        ref = FIRDatabase.database().reference().child("activity")
        
        startObservingDB()
        
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // download disbility service data from Firebase
    func startObservingDB() {
        ref.observeEventType(.Value, withBlock: { (snapshot: FIRDataSnapshot) -> Void in
            
            var newCategories = [String]()
            for category in snapshot.children {
                if let name = category.key! as? String {
                    newCategories.append(name)
                }
            }
            self.categories = newCategories
            self.activityTable.reloadData()
        }) { (error: NSError) in
            print(error.description)
        }
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
            
            self.mapView.setRegion(region, animated: false)
            self.locationManager.stopUpdatingLocation()
            
            searchNearbyGP()
        }
    }
    
    @IBAction func backToCurrenLocation(sender: AnyObject) {
        let center = CLLocationCoordinate2D(latitude:  (self.latitude as NSString).doubleValue, longitude: (self.longitude as NSString).doubleValue)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    // add info button for each annotation on map to jump to gp detail controller
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
            self.gpID = self.mapView.selectedAnnotations[0].subtitle!
            self.performSegueWithIdentifier("showGPDetails", sender: self)
        }
    }
    
    // Search nearby gps from google map api and check network connection
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
        // Download gps
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
            
            NSLog("Found \(json["results"].count) gps!")
            
            
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
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section)
        {
        case 0: return self.categories.count
        case 1: return 1
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.activityTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        //cell.backgroundColor = UIColor(red: 63/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0)
        // Configure the cell...
        let c: String = self.categories[indexPath.row]
        cell.textLabel!.text = c
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.textLabel?.font = UIFont.systemFontOfSize(17)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
        cell.textLabel?.numberOfLines = 0
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = cellColors[0]
        } else{
            cell.backgroundColor = cellColors[1]
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if categories.count != 0 {
            let c = self.categories[indexPath.row] as String
            
            currentCategory = c
            
            self.performSegueWithIdentifier("showCategoryDetail", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGPDetails"
        {
            let theDestination : PlaceViewController = segue.destinationViewController as! PlaceViewController
            theDestination.currentPlaceID = self.gpID
        } else if segue.identifier == "showCategoryDetail"
        {
            let controller: ServiceTableViewController = segue.destinationViewController as! ServiceTableViewController
            controller.currentCategory = currentCategory
            // Display movie details screen
        }
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//            }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
