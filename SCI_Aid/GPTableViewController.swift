//
//  GPTableViewController.swift
//  SCI_Aid
//
//  Created by Dee on 14/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
// external library from https://github.com/SwiftyJSON/SwiftyJSON
import SwiftyJSON
import MapKit

class GPTableViewController: UITableViewController {

    @IBOutlet var image: UITableViewCell!
    @IBOutlet var phone: UITableViewCell!
    @IBOutlet var address: UITableViewCell!
    @IBOutlet var website: UITableViewCell!
    
    var currentPlaceID: String?
    
    var placeTitle: String?
    var placePhone: String?
    var placeWeb: String?
    var placeAddress: String?
    var photo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadPlaceData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
                    self.address.detailTextLabel!.text = self.placeAddress
                    self.website.detailTextLabel!.text = self.placeWeb
                    self.phone.detailTextLabel!.text = self.placePhone
                    let poster = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + self.photo! + "&key=AIzaSyBpHKu9KGpv-VacWvQOhrI7OVjGVdHQY9Y" as String
//                    if let url  = NSURL(string: poster),
//                        data = NSData(contentsOfURL: url)
//                    {
//                        self.image.image = UIImage(data: data)
//                    } else {
//                        self.placeImage.image = UIImage(named: "noimage")
//                    }
//                    self.activityIndicator.stopAnimating()
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
                
                //self.address = address
            }
        }catch {
            print("JSON Serialization error")
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
