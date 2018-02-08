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
    
    
    // @IBOutlet weak var Toggle: UISwitch!
    @IBOutlet weak var mapViewSDK: MKMapView!
    @IBOutlet weak var GetPOIFirebaseButton: UIBarButtonItem!
    
    var locationManager: CLLocationManager!
    let db = Firestore.firestore()
    var firstLaunch = true
    let MaxAllowedDistance = 200
    var pinArray = [Pin]()
    var pinAnnotationView:MKPinAnnotationView!
    
    
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
        
        //if(Toggle.isOn){
        
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        if firstLaunch {
            mapViewSDK.setRegion(coordinateRegion, animated: true)
            firstLaunch = false
        } else {
            mapViewSDK.setRegion(coordinateRegion, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        db.collection("pointsOfInterest")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                for pin in documents{
                    let mapPin = Pin(name: pin.data()["name"] as! String, description: pin.data()["description"] as! String, geopoint: pin.data()["geoLocation"] as! GeoPoint)
                    self.pinArray.append(mapPin)
                }
                querySnapshot?.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        
                    }
                    if (diff.type == .modified) {
                        let allAnnotations = self.mapViewSDK.annotations
                        self.mapViewSDK.removeAnnotations(allAnnotations)
                        self.getPointsOfInterestFireStore()
                    }
                    if (diff.type == .removed) {
                        
                    }
                }
        }
    }
    
    
    @IBAction func getPointsOfInterestFireStore(){
        
        
        for pin in pinArray{
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.geopoint.latitude, longitude: pin.geopoint.longitude)
            annotation.subtitle = pin.description
            annotation.title = pin.name
            
            pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pins")
            
            let location = CLLocation(latitude: pin.geopoint.latitude, longitude: pin.geopoint.longitude)
            if location.distance(from: self.mapViewSDK.userLocation.location!) < CLLocationDistance(self.MaxAllowedDistance){

            self.mapViewSDK.addAnnotation(pinAnnotationView.annotation!)
            } else {
                print("Pin was too far away")
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}






