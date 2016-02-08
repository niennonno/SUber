//
//  RequestViewController.swift
//  Uber
//
//  Created by Aditya Vikram Godawat on 08/02/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RequestViewController: UIViewController, CLLocationManagerDelegate {

    
    //MAR :- Global Variables
    
    var requestLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var requestUsername: String = ""
    
    
    //MARK :- IBOutlets
    
    @IBOutlet var map: MKMapView!
    
    
    //MARK :- IBActions
    
    @IBAction func pickUpRider(sender: AnyObject) {
        
        let query = PFQuery(className: "riderRequest")
        query.whereKey("username", equalTo: requestUsername)
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if error != nil {
                
                print(error)
                
            } else {
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        let query = PFQuery(className: "riderRequest")
                        query.getObjectInBackgroundWithId(object.objectId!, block: { (object, error) -> Void in
                            
                            if error != nil {
                                print (error)
                            } else if let object = object{
                                
                                object["driverResponded"] = PFUser.currentUser()?.username
                                print("success")
                                
                                object.saveInBackground()
                                
                                let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)

                                CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) -> Void in
                                    
                                    if error != nil {
                                        print(error!)
                                    } else {
                                        
                                        if placemarks?.count > 0 {
                                            
                                            let pm = placemarks![0] as! CLPlacemark
                                            
                                            let mkPm = MKPlacemark(placemark: pm)
                                            
                                            let mapItem = MKMapItem(placemark: mkPm)
                                            
                                            mapItem.name = self.requestUsername
                                            
                                            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                            
                                            mapItem.openInMapsWithLaunchOptions(launchOptions)

                                        }
                                        
                                    }
                                    
                                })
                                
                                
                            }
                            
                        })
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

        print(requestUsername)
        print(requestLocation)
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        self.map.removeAnnotations(map.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestUsername
        
        self.map.addAnnotation(annotation)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
