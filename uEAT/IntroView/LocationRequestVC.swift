//
//  LocationRequestVC.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/11/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit
import CoreLocation

class LocationRequestVC: UIViewController {
    
    
    let locationManager = CLLocationManager()
    var authorizationStatus = CLLocationManager.authorizationStatus()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        
    }
    

    @IBAction func RequestLocationBtn(_ sender: Any) {
        
        
        if authorizationStatus == .notDetermined || authorizationStatus == .denied {
            locationManager.requestWhenInUseAuthorization()
        } else {
            self.performSegue(withIdentifier: "moveToIntro1vc", sender: nil)
        }

        
        
    }
    
    @IBAction func DoItLaterBtn(_ sender: Any) {
        
        
        self.performSegue(withIdentifier: "moveToIntro1vc", sender: nil)
        
    }
    
    
    
}

extension LocationRequestVC: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // get my location with zoom 30
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            
            print("Granted")
            self.performSegue(withIdentifier: "moveToIntro1vc", sender: nil)
            
        } else {
            
            print("Not determined")
            
        }
        
        
        
    }
    
}
