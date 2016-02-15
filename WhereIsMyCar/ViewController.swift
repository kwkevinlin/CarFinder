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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var setLocButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var openMapsButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var mk = MKPointAnnotation()
    var coorLat = 0.0, coorLong = 0.0, carLat = 0.0, carLong = 0.0, oldLat = 0.0, oldLong = 0.0
    var setLocBool = false, resetBool = false
    var route: MKRoute?
    
    /*
        Note: Default will go to didFailWithError unless you specify location in simulator:
        iOS Simulator, Debug -> Location -> Custom Location
        36.1356, -80.279462 for Q parking lot
        Use  74   for demonstration (36.1374)
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func mainButton(sender: AnyObject) { //Set my Location - Button
        print("SetMyLoc pressed!")
        print("Configuring CoreLocation...")
        resetBool = false
        setLocBool = true
        
        mapView.mapType = MKMapType.Hybrid
        segmentControl.selectedSegmentIndex = 1
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print("Complete!")
        
        setLocButton.hidden = true
        openMapsButton.hidden = false
        resetButton.hidden = false
    }

    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //AnyObject->CLLocation
        let latestLocation: CLLocation = locations[locations.count - 1] //AnyObject
        
        //print("Updating Location")
        mapView.delegate = self
        
        coorLat = latestLocation.coordinate.latitude
        coorLong = latestLocation.coordinate.longitude
        if (setLocBool == true) {
            carLat = coorLat
            carLong = coorLong
            setLocBool = false
        }
        let carCoords = CLLocationCoordinate2D(latitude: carLat, longitude: carLong)
        latitude.text = String(format: "%.4f", coorLat)
        longitude.text = String(format: "%.4f", coorLong)
        altitude.text = String(format: "%.4f", latestLocation.altitude)
        
        
        if (resetBool == false) { //When reset is pressed, a different mapView sequence is ran
            
            //If GPS does not move, don't need to update location and mapView
            if (coorLat == oldLat && coorLong == oldLong) {
                return
            } else {
                oldLat = coorLat
                oldLong = coorLong
            }
            
            /*
            When is this function called? Everytime locationManager is used? (ie. locationManager.requestWhenInUseAuthorization())
            */
            
            //Center is the center of where mapview will zone in on, span is the degree of zoom the map will be displayed in
            let region = MKCoordinateRegion(center: carCoords, span: MKCoordinateSpan(latitudeDelta: 0.0035, longitudeDelta: 0.0035))
            
            //mk declared as MKPointAnnotation above global. Adds annotation in current location (when set location button is pressed
            mk.coordinate = carCoords
            mapView.addAnnotation(mk)
            
            //SetRegion sets "center" (the middle-point of where mapview will display) and span to determine how much zoom (how much map to show). Animated will animate the transition of locations instead of just frame A to frame B. showsUserLocation needs to be false here because it is turned on in "else" statement below (when resetButton is pressed, where user's location is continuously tracked).
            //mapView.showsUserLocation = false
            mapView.setRegion(region, animated: true)
            
            //Adding walking directions on map after "Set my Location" enabled
            mapView.showsUserLocation = true
            let directionsRequest = MKDirectionsRequest()
            let carLocation = MKPlacemark(coordinate: carCoords, addressDictionary: nil) //center = current location
            let currentLocation = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coorLat, longitude: coorLong), addressDictionary: nil)
            
            directionsRequest.source = MKMapItem(placemark: currentLocation)
            directionsRequest.destination = MKMapItem(placemark: carLocation)
            directionsRequest.transportType = MKDirectionsTransportType.Walking
            
            let directions = MKDirections(request: directionsRequest)
            directions.calculateDirectionsWithCompletionHandler {
                (response, error) -> Void in
                if error == nil {
                    self.route = response!.routes[0] as MKRoute
                    //Only if GPS location changes (user moves) do we add polyline
                    if (self.carLat != self.coorLat || self.carLong != self.coorLong) {
                        
                        //print("Overlays: ", self.mapView.overlays.count)
                        if (self.mapView.overlays.count > 0) {
                            self.mapView.removeOverlay(self.mapView.overlays[0])
                        }
                        self.mapView.addOverlay((self.route?.polyline)!)
                        
                        //Also re-adjust center and spam so mapView will show complete polyline
                        var regionRect = self.route?.polyline.boundingMapRect
                        regionRect!.size.width += regionRect!.size.width * 0.67 //Space on right
                        regionRect!.size.height += regionRect!.size.height * 0.5
                        regionRect!.origin.x -= ((regionRect!.size.width) * 0.41) / 2 //Even out LR
                        regionRect!.origin.y -= ((regionRect!.size.height) * 0.35) / 2
                        
                        self.mapView.setRegion(MKCoordinateRegionForMapRect(regionRect!), animated: true)
                        
                        /*
                            Should this be in rendererForOverlay so it'll recenter every time user moves?
                        
                            BUG: 1. When showing polyline, if user (GPS) moves, mapView recenters weirdly sometimes.    
                                    Is this still hapenning?
                        
                            FIX: 1. Label constraints
                        */
                    }
                }
            }
            
            //locationManager.stopUpdatingLocation()
       

        } else {
            
            setLocButton.hidden = false
            openMapsButton.hidden = true
            resetButton.hidden = true
            
            mapView.removeAnnotation(mk)
            mapView.removeOverlay((route?.polyline)!)
            
            mapView.showsUserLocation = true
            
            //Refocus map to user's current location. Both "set my location" and "reset" button calls this function, thus the else statement and resetBool boolean
            mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coorLat, longitude: coorLong), span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)), animated: true)
            
            //Re-enable locationManager to update location when resetBool = false
            oldLat = 0.0
            oldLong = 0.0
            
            //locationManager.stopUpdatingLocation()
            
            //resetBool = false moved to mainButton so location will continue to update

        }
    
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        //print("RendererForOverLay")
        let myLineRenderer = MKPolylineRenderer(polyline: (route?.polyline)!)
        //let myLineRenderer = MKPolylineRenderer(overlay: overlay)
        myLineRenderer.strokeColor = UIColor.blueColor()
        myLineRenderer.lineWidth = 3
        
        return myLineRenderer
    }
    
    
    @IBAction func openInMaps(sender: AnyObject) {
        print("Opening in Maps...")
        
        //Send coordinates and name to Apple Maps, then open
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: carLat, longitude: carLong), addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Your Parked Car"
        mapItem.openInMapsWithLaunchOptions(nil)
        
    }
   
    @IBAction func resetFunc(sender: AnyObject) {
        print("Resetting map...")
        
        //Reset to initial state (ie. if user accidentally presses "set my location" without wanting to. Resets everything except what mapview is showing, which now zooms out and tracks the user's current location
        
        resetBool = true
        
        mapView.mapType = MKMapType.Standard
        segmentControl.selectedSegmentIndex = 0
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        latitude.text = String("0.0000")
        longitude.text = String("0.0000")
        altitude.text = String("0.0000")
    }
    
    @IBAction func segmentCtrlFunc(sender: AnyObject) {
        
        switch (segmentControl.selectedSegmentIndex) {
        case 0:
            mapView.mapType = MKMapType.Standard
        case 1:
            mapView.mapType = MKMapType.Hybrid
        case 2:
            mapView.mapType = MKMapType.Satellite
        default:
            print("Error in mapType switch - Segment Control!")
        }
    }
    

    func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError) {
            //print("didFailWithError")
            //NSLog("Error: %@", error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

