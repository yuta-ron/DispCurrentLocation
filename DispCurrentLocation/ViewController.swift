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
        
        myLabel.text = "神奈川県横浜市都筑区1丁目"
        myLabel.textAlignment = .center
        myLabel.font = UIFont.systemFont(ofSize: 34)

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLDistanceFilterNone
        locationManager.distanceFilter = 500;
        
        // アプリ使用中の位置情報の許可をユーザに求める
        locationManager.startUpdatingLocation() // 位置情報の取得を開始
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("Latitude: \(latitude), Longitude: \(longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation() // 許可されたら位置情報の取得を開始
        }
    }
}

