//
//  ViewController.swift
//  WhereIsMyCar
//
//  Created by 1834 Software on 2/5/16.
//  Copyright © 2016 1834 Software. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var altitude: UILabel!    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    /*
        Note: Default will go to didFailWithError unless you specify location in simulator:
        iOS Simulator, Debug -> Location -> Custom Location
        36.136111, -80.279462 for Q parking lot
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func mainButton(sender: AnyObject) {
        print("Button pressed!")
        print("Configuring CoreLocation...")
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
        print("Complete!")
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [CLLocation]!) { //AnyObject->CLLocation
        var latestLocation: AnyObject = locations[locations.count - 1]
        
        print("Updating Location")
        
        latitude.text = String(format: "%.4f", latestLocation.coordinate.latitude)
        longitude.text = String(format: "%.4f", latestLocation.coordinate.longitude)
        altitude.text = String(format: "%.4f", latestLocation.altitude)
    
    }

    
    func locationManager(manager: CLLocationManager!,
        didFailWithError error: NSError!) {
            print("didFailWithError")
            //NSLog("Error: %@", error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Make function to print when pressed
    


}

