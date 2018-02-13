//
//  MapsViewController.swift
//  Aurora
//
//  Created by Julian van 't Veld on 05-02-18.
//  Copyright © 2018 Julian van 't Veld. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire

class MapsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var GetPOIButton: UIBarButtonItem!
    
    @IBOutlet weak var Toggle: UISwitch!
    
    
    var locationManager: CLLocationManager!
    var firstLaunch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self
       
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
   
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        mapView.delegate = self
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.showsUserLocation = true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (Toggle.isOn){
    
            let location = locations.first!
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,  300, 300)
        
            if firstLaunch {
                mapView.setRegion(coordinateRegion, animated: true)
                firstLaunch = false
            } else {
                mapView.setRegion(coordinateRegion, animated: false)
            }
        } else {

        }
    }
    
    @IBAction func getPOI(){
        var _longitude = 0.0
        var _latitude = 0.0
        
        Alamofire.request("https://us-central1-aurora-hackathon.cloudfunctions.net/api/v1/pointsOfInterest/", method: .get)
        .responseJSON { response in
            let parsedData = response.result.value as! [[String :Any]]
            for item in parsedData{
                DispatchQueue.main.async {
                    print(item["name"] as! String)
                    
                    if let geolocatie = item["geoLocation"] as? [String : AnyObject]{
                        _longitude = (geolocatie["_longitude"] as? Double)!
                        _latitude = (geolocatie["_latitude"] as? Double)!
                    }
                    
                    let annotation = MKPointAnnotation()
                    let pinAnnotationView:MKPinAnnotationView!
                    annotation.coordinate = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
                    annotation.subtitle = (item["description"] as? String)!
                    annotation.title = (item["name"] as? String)!
                   
                    pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                    self.mapView.addAnnotation(pinAnnotationView.annotation!)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}





