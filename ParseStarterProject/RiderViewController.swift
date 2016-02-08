//
//  RiderViewController.swift
//  Uber
//
//  Created by Aditya Vikram Godawat on 04/02/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

    
    //MARK :- IBOutlets
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var callUberButton: UIButton!
    
    
    //MARK :- Global Variables
    let locationManager = CLLocationManager()
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var riderRequestActive = false
    var driverOnTheWay = false
    
    //MARK :- IBActions
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
            let riderRequest = PFObject(className: "riderRequest")
            riderRequest["username"] = PFUser.currentUser()?.username
            riderRequest["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            
            riderRequest.saveInBackgroundWithBlock { (success, error) -> Void in
                
                if success {
                
                     self.riderRequestActive = true
                    
                } else {
                    
                    let alert = UIAlertController(title: "Could Not Call Uber", message: "Try Again!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                
            }
       
        } else {
            
            let query = PFQuery(className: "riderRequest")
            query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if error != nil {
                    
                    print(error)
                    
                } else {
                    
                    if let objects = objects {
                        
                        for object in objects {
                            object.deleteInBackground()
                            
                        }
                        
                        self.callUberButton.setTitle("Call an Uber", forState: UIControlState.Normal)
                        self.riderRequestActive = false
                        
                    } else {
                        
                        print(error)
                    
                    }
                }
            })
        }
    }
    //MARK :- Overriden Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutRider" {
        
            PFUser.logOut()
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        let location:CLLocationCoordinate2D = (locationManager.location?.coordinate)!
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        let query = PFQuery(className: "riderRequest")
        query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error != nil {
                print(error)
            } else {
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        if let driverUsername = object["driverResponded"] {
                            
                            let query = PFQuery(className: "driverLocation")
                            query.whereKey("username", equalTo: driverUsername)
                            
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                if error != nil {
                                    print(error)
                                } else {
                                    
                                    if let objects = objects {
                                        
                                        for object in objects {
                                            
                                            if let driverLocation = object["driverLocation"] {
                                                
                                                let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                
                                                let userCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                                
                                                let distance = userCLLocation.distanceFromLocation(driverCLLocation)
                                                let distanceKM = distance / 1000
                                                let roundedDistance = Double(round(distanceKM * 10 ) / 10)
                                                
                                                 self.callUberButton.setTitle("Driver is \(roundedDistance) km Away", forState: UIControlState.Normal)
                                                
                                                self.driverOnTheWay = true
                                                
                                                let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                                
                                                let latDelta = abs(driverLocation.latitude - location.latitude) * 2 + 0.005
                                                let lonDelta = abs(driverLocation.longitude - location.longitude) * 2 + 0.005
                                                
                                                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                                
                                                self.map.setRegion(region, animated: true)
                                                self.map.removeAnnotations(self.map.annotations)
                                                
                                                var pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                                var annotation = MKPointAnnotation()
                                                annotation.title = "Your Location"
                                                annotation.coordinate = pinLocation
                                                
                                                self.map.addAnnotation(annotation)
                                                
                                                pinLocation = CLLocationCoordinate2D(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                annotation.title = "Driver Location"
                                                annotation.coordinate = pinLocation
                                                
                                                self.map.addAnnotation(annotation)
                                            
                                            }
                                        }
                                    }
                                }
                            })
                            
                        }
                    }
                }
            }
        })
        
        if driverOnTheWay == false {
        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        self.map.removeAnnotations(map.annotations)
        
        let pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinLocation
        
        self.map.addAnnotation(annotation)
        }
        
    }
    
}
