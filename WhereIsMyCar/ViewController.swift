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
    var mk = MKPointAnnotation()
    var coorLat = 0.0, coorLong = 0.0
    var resetBool = false
    
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
        resetBool = false
        
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
        
        coorLat = latestLocation.coordinate.latitude
        coorLong = latestLocation.coordinate.longitude
        latitude.text = String(format: "%.4f", coorLat)
        longitude.text = String(format: "%.4f", coorLong)
        altitude.text = String(format: "%.4f", latestLocation.altitude)
        
        let center = CLLocationCoordinate2D(latitude: coorLat, longitude: coorLong)
        
        if (resetBool == false) { //When reset is pressed, a different mapView sequence is ran
            
            /*
            When is this function called? Everytime locationManager is used? (ie. locationManager.requestWhenInUseAuthorization())
            */
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.0035, longitudeDelta: 0.0035))
            
            mk.coordinate = CLLocationCoordinate2D(latitude: coorLat, longitude: coorLong)
            mapView.addAnnotation(mk)
            
            mapView.mapType = MKMapType.Hybrid
            mapView.showsUserLocation = false
            mapView.setRegion(region, animated: true)
            
            locationManager.stopUpdatingLocation()
            
        } else {
            
            print("Reset instance")
            
            setLocButton.hidden = false
            openMapsButton.hidden = true
            resetButton.hidden = true
            
            mapView.removeAnnotation(mk)
            
            mapView.mapType = MKMapType.Standard
            mapView.showsUserLocation = true
            
            mapView.setRegion(MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)), animated: true)
            
            //locationManager.stopUpdatingLocation()
            
            //resetBool = false moved to mainButton so location will continue to update

        }
    
    }
    
    
    @IBAction func openInMaps(sender: AnyObject) {
        print("Openning in Maps")
        
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coorLat, longitude: coorLong), addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Your Parked Car"
        mapItem.openInMapsWithLaunchOptions(nil)
        
    }
   
    @IBAction func resetFunc(sender: AnyObject) {
        print("Reset Button pressed!")
        
        resetBool = true
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        latitude.text = String("0.0000")
        longitude.text = String("0.0000")
        altitude.text = String("0.0000")
    }

    func locationManager(manager: CLLocationManager!,
        didFailWithError error: NSError!) {
            //print("didFailWithError")
            //NSLog("Error: %@", error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

