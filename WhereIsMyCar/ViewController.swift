//
//  ViewController.swift
//  WhereIsMyCar
//
//  Created by 1834 Software on 2/5/16.
//  Copyright © 2016 1834 Software. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var altitude: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    var coorLat = 0.0, coorLong = 0.0
    
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
        var latestLocation: CLLocation = locations[locations.count - 1] //AnyObject
        
        print("Updating Location")
        
        coorLat = latestLocation.coordinate.latitude
        coorLong = latestLocation.coordinate.longitude
        latitude.text = String(format: "%.4f", coorLat)
        longitude.text = String(format: "%.4f", coorLong)
        altitude.text = String(format: "%.4f", latestLocation.altitude)
        
        var coords = CLLocationCoordinate2DMake(coorLat, coorLong)
        
        let center = CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
    
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

