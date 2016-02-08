//
//  RequestViewController.swift
//  Uber
//
//  Created by Aditya Vikram Godawat on 08/02/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit

class RequestViewController: UIViewController, CLLocationManagerDelegate {

    
    //MAR :- Global Variables
    
    var requestLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var requestUsername: String = ""
    
    
    //MARK :- IBOutlets
    
    @IBOutlet var map: MKMapView!
    
    
    //MARK :- IBActions
    
    @IBAction func pickUpRider(sender: AnyObject) {
    }
    
    //MARK :- Overridden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(requestUsername)
        print(requestLocation)
        
        
        // Do any additional setup after loading the view.
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
