//
//  ViewController.swift
//  DispCurrentLocation
//
//  Created by yutaron on 2024/02/25.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var myLabel: UILabel!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myLabel.text = "Loading..."
        myLabel.textAlignment = .center
        myLabel.font = UIFont.systemFont(ofSize: 28)

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLDistanceFilterNone
        locationManager.distanceFilter = 500;
        
        // アプリ使用中の位置情報の許可をユーザに求める
        locationManager.startUpdatingLocation() // 位置情報の取得を開始
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "ja_JP")) {(placemarks, error) in
                guard let pms = placemarks else{
                    return
                }
                let place = pms.first!
                place
                var locationStr = ""
                locationStr.append(place.administrativeArea ?? "")
                locationStr.append(place.subAdministrativeArea ?? "")
                locationStr.append(place.locality!)
                locationStr.append(place.thoroughfare!)
                
                self.myLabel.text = locationStr
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation() // 許可されたら位置情報の取得を開始
        }
    }
}

