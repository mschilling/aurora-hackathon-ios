//
//  ViewController.swift
//  Aurora
//
//  Created by Julian van 't Veld on 02-02-18.
//  Copyright © 2018 Julian van 't Veld. All rights reserved.
//

import UIKit
import CoreLocation



class ViewController: UIViewController {
    let locationManager = CLLocationManager()

    
    @IBOutlet weak var GoToAR: UIButton!
    @IBOutlet weak var LatitudeLabel: UILabel!
    @IBOutlet weak var LongitudeLabel: UILabel!
    @IBOutlet weak var GetLocationButton: UIButton!
    var longitude = 0.0
    var latitude = 0.0


    @IBOutlet weak var POIButton: UIButton!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        GetLocationButton.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
   
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func buttonClicked(){
        LongitudeLabel.text = "\(longitude)"
        LatitudeLabel.text = "\(latitude)"
    }
    

}
//MARK: CLLocation
extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        longitude = location.coordinate.longitude
        latitude = location.coordinate.latitude
        
    }
    
    
}

