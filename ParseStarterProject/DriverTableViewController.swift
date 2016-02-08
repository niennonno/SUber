//
//  DriverTableTableViewController.swift
//  Uber
//
//  Created by Aditya Vikram Godawat on 05/02/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    //MARK :- Global Variables
    
    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    let locationManager = CLLocationManager()
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var refresher: UIRefreshControl!
    var distances = [CLLocationDistance]()
    
    
    //MARK :- User Defined Functions
    
    func refresh() {
        
        let query = PFQuery(className: "riderRequest")
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error != nil {
                
                print(error)
                
            } else {
                
                if let objects = objects {
                    
                    self.usernames.removeAll(keepCapacity: true)
                    self.locations.removeAll(keepCapacity: true)
                    
                    
                    
                    for object in objects {
                        
                        if let username = object["username"] as? String {
                            
                            self.usernames.append(username)
                            
                        }
                        
                        if let location = object["location"] as? PFGeoPoint {
                            
                            self.locations.append(CLLocationCoordinate2DMake(location.latitude, location.longitude))
                            
                            
                        }
                        
                        self.tableView.reloadData()
                        
                        print(self.usernames)
                        print(self.locations)
                        
                        
                    }
                    
                } else {
                    
                    print(error)
                    
                }
                self.tableView.reloadData()
                
                self.refresher.endRefreshing()
                
            }
        })
        
    }

    
    //MARK :- Location Manager Functions

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = (locationManager.location?.coordinate)!
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        
//        print(location)
        
        let query = PFQuery(className: "riderRequest")
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
        query.limit = 10
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error != nil {
                
                print(error)
                
            } else {
                
                if let objects = objects {
                    
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    
                    for object in objects {
                        
                        if let username = object["username"] as? String {
                            
                            self.usernames.append(username)
                            
                        }
                        
                        if let returnedLocation = object["location"] as? PFGeoPoint {
                            
                            let position = CLLocationCoordinate2DMake(returnedLocation.latitude, returnedLocation.longitude)
                            self.locations.append(position)
                            
                            let requestCLLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
                            
                            let driverLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                            
                            let distance = driverLocation.distanceFromLocation(requestCLLocation)
                            self.distances.append(distance/1000)
                            
                        }
                        
                        self.tableView.reloadData()
                        
                        
                        
                    }
                    
                } else {
                    
                    print(error)
                    
                }
                
                
            }
        })
        
    }
    
    
    
    //MARK :- Overridden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let distanceDouble = Double(distances[indexPath.row])
        let roundedDouble = Double(round(distanceDouble * 10 / 10))
        
        cell.textLabel?.text = usernames[indexPath.row] + " - " + String(roundedDouble) + " km Away"
        
        return cell
    }
    
    
    
    
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutDriver" {
            
            PFUser.logOut()
            
        } else if segue.identifier == "showViewRequest" {
            
            if let destination = segue.destinationViewController as? RequestViewController {
                
                destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                destination.requestUsername = usernames[(tableView.indexPathForSelectedRow?.row)!]
                
            }
            
        }
        
    }
    
    
    
    
    
}











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