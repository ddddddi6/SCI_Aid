//
//  ToiletViewController.swift
//  SCI_Aid
//
//  Created by Dee on 31/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import Foundation
import FBAnnotationClusteringSwift


class ToiletViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

   
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var latitude: String!
    var longitude: String!
    var address: String!
    
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!

    var ref: FIRDatabaseReference!
    var clusteringManager : FBClusteringManager!
    
    var toilets = [Toilet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference().child("toilet")
        
        clusteringManager = FBClusteringManager()

        self.locationManager = CLLocationManager()
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Ask for Authorisation from the User.
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        self.mapView.delegate = self
        
        searchBar.delegate = self
        
        startObservingDB()
        
      
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // download toilet data from Firebase
    func startObservingDB() {
        ref.observeEventType(.Value, withBlock: { (snapshot: FIRDataSnapshot) -> Void in
            var array:[FBAnnotation] = []
            var newToilets = [Toilet]()
            for toilet in snapshot.children {
                if let name = toilet.value!["Name"] as? String,
                    let latitude = toilet.value!["Latitude"] as? Double,
                    let longitude = toilet.value!["Longitude"] as? Double {
                    let t: Toilet = Toilet(name: name, latitude: latitude, longitude: longitude)
                    newToilets.append(t)
                    let pin = FBAnnotation()
                    pin.coordinate = CLLocationCoordinate2DMake(Double(latitude), Double(longitude))
                    pin.title = name
                    array.append(pin)
                }
            }
            self.toilets = newToilets
            self.clusteringManager.addAnnotations(array)
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            let scale:Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        }) { (error: NSError) in
            print(error.description)
        }
    }

    // display user's current location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        
        NSLog("Found \(location.coordinate.latitude) \(location.coordinate.longitude)")
        
        if (self.latitude == nil && self.longitude == nil) {
            self.latitude = String(location.coordinate.latitude)
            self.longitude = String(location.coordinate.longitude)
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))
            
            self.mapView.setRegion(region, animated: false)
            self.locationManager.stopUpdatingLocation()
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        NSOperationQueue().addOperationWithBlock({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            let scale:Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        })
    }
    
    // show annotation on map
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil
            return nil
        }
        var reuseId = ""
        if annotation.isKindOfClass(FBAnnotationCluster) {
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            return clusterView
        } else {
            reuseId = "pin"
            
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.animatesDrop = true
            } else {
                pinView?.annotation = annotation
            }
            pinView?.annotation = annotation
            pinView!.pinTintColor = UIColor(red: 19/255.0, green: 170/255.0, blue: 65/255.0, alpha: 1.0)
            return pinView
        }
    }
    
    // listen for search bar action
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        address = searchBar.text
        if(address.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "")
        {
            let messageString: String = "Please input valid address"
            // Setup an alert to warn user
            // UIAlertController manages an alert instance
            let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            displayLocation(address)
        }
        
    }
    
    // show search result on map
    func displayLocation(address: String) {
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address + " " + "Victoria Australia"
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            let latitude = localSearchResponse!.boundingRegion.center.latitude
            let longitude = localSearchResponse!.boundingRegion.center.longitude
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.mapView.centerCoordinate = coordinate
            let region = MKCoordinateRegion(center: self.mapView.centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            self.mapView.setRegion(region, animated: true)
        }
    }

    // dismiss keyboard for search bar
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    @IBAction func backToCurrentLocation(sender: UIButton) {
        let center = CLLocationCoordinate2D(latitude:  (self.latitude as NSString).doubleValue, longitude: (self.longitude as NSString).doubleValue)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        self.mapView.setRegion(region, animated: true)
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
