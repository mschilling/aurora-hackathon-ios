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
import FirebaseFirestore
import SwiftyJSON

class MapsViewController2: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapViewSDK: MKMapView!
    @IBOutlet weak var GetPOIFirebaseButton: UIBarButtonItem!
    
    
    
    var locationManager: CLLocationManager!
    let db = Firestore.firestore()
    var firstLaunch = true
    let MaxAllowedDistance = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
       
        mapViewSDK.delegate = self
        mapViewSDK.mapType = MKMapType(rawValue: 0)!
        mapViewSDK.showsUserLocation = true
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        if firstLaunch {
            mapViewSDK.setRegion(coordinateRegion, animated: true)
            firstLaunch = false
        } else {
            mapViewSDK.setRegion(coordinateRegion, animated: false)
        }
    }
    
    
    @IBAction func getPointsOfInterestFireStore(){
        
        db.collection("pointsOfInterest").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let Geolocation = document.data()["geoLocation"] as! GeoPoint
                    let lon = Geolocation.longitude
                    let lat = Geolocation.latitude
                    let location = CLLocation(latitude: lat, longitude: lon)
                    
                    if location.distance(from: self.mapViewSDK.userLocation.location!) < CLLocationDistance(MaxAllowedDistance){
                        let annotation = MKPointAnnotation()
                        let pinAnnotationView:MKPinAnnotationView!
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        annotation.subtitle = document.data()["description"] as? String
                        annotation.title = document.data()["name"] as? String
                        
                        pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                        self.mapViewSDK.addAnnotation(pinAnnotationView.annotation!)
                    } else {
                        print(document.data()["name"] as! String)
                        print("Too far away")
                    }
                    
                    
                    
                    
                }
            }
        }
        
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}






