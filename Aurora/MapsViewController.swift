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
import SwiftyJSON

class MapsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var GetPOIButton: UIBarButtonItem!

    var locationManager: CLLocationManager!
    
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
        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = mapView.userLocation.coordinate
        mapCamera.pitch = 45
        mapCamera.altitude = 500 // example altitude
        mapCamera.heading = 45
        
        // set the camera property
        mapView.camera = mapCamera
        
        
       
    
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    let center = self.mapView.userLocation.coordinate
        let region = MKCoordinateRegionMake(center, MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        mapView.setRegion(region, animated: true)
        mapView.centerCoordinate = self.mapView.userLocation.coordinate
        
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
                    
                    print(item["geoLocation"] as Any)
                }
            }
    
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
}





