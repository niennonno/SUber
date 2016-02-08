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
    
    //MARK :- IBActions
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
            let riderRequest = PFObject(className: "riderRequest")
            riderRequest["username"] = PFUser.currentUser()?.username
            riderRequest["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            
            riderRequest.saveInBackgroundWithBlock { (success, error) -> Void in
                
                if success {
                    
                    self.callUberButton.setTitle("Cancel Uber", forState: UIControlState.Normal)
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
        locationManager.requestWhenInUseAuthorization()
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
