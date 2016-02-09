//
//  ViewController.swift
//  WhereIsMyCar
//
//  Created by Kevin Lin on 2/5/16.
//  Copyright © 2016 Kevin Lin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var setLocButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var openMapsButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    /*
        Note: Default will go to didFailWithError unless you specify location in simulator:
        iOS Simulator, Debug -> Location -> Custom Location
        36.136111, -80.279462 for Q parking lot
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func mainButton(sender: AnyObject) { //Set my Location - Button
        print("Button pressed!")
        print("Configuring CoreLocation...")
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print("Complete!")
        
        setLocButton.hidden = true
        openMapsButton.hidden = false
        resetButton.hidden = false
    }

    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [CLLocation]!) { //AnyObject->CLLocation
        let latestLocation: CLLocation = locations[locations.count - 1] //AnyObject
        
        print("Updating Location")
        
        let coorLat = latestLocation.coordinate.latitude
        let coorLong = latestLocation.coordinate.longitude
        latitude.text = String(format: "%.4f", coorLat)
        longitude.text = String(format: "%.4f", coorLong)
        altitude.text = String(format: "%.4f", latestLocation.altitude)
        
        let center = CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.0035, longitudeDelta: 0.0035))
        
        /*
        Change to:
            1). Open in Maps
            2). Reset
        */
        
        let mk = MKPointAnnotation()
        mk.coordinate = CLLocationCoordinate2D(latitude: coorLat, longitude: coorLong)
        mapView.addAnnotation(mk)
        
        mapView.mapType = MKMapType.Hybrid
        //mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
    
    }

    
    func locationManager(manager: CLLocationManager!,
        didFailWithError error: NSError!) {
            print("didFailWithError")
            //NSLog("Error: %@", error)
    }
    
    
    @IBAction func openInMaps(sender: AnyObject) {
        print("Open in Maps pressed!")
        
        
    }
   
    @IBAction func resetFunc(sender: AnyObject) {
        print("Reset Button pressed!")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Make function to print when pressed
    


}

