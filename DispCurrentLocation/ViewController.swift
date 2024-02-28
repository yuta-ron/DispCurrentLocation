//
//  ViewController.swift
//  DispCurrentLocation
//
//  Created by yutaron on 2024/02/25.
//

import UIKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var testButton: UIButton!
    
    let locationManager = CLLocationManager()
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeLabel.text = "Loading..."
        placeLabel.textAlignment = .center
        placeLabel.font = UIFont.systemFont(ofSize: 28)

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
                var locationStr = ""
                locationStr.append(place.administrativeArea ?? "")
                locationStr.append(place.subAdministrativeArea ?? "")
                locationStr.append(place.locality!)
                locationStr.append(place.thoroughfare!)
                
                self.placeLabel.text = locationStr
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation() // 許可されたら位置情報の取得を開始
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        notifyByZundamon(prefecture: "nagasaki")
    }
    
    
    // Todo: リアルタイム通知的なことをやりたい
    func notifyByZundamon(prefecture: String) {
        if let soundURL = Bundle.main.url(forResource: prefecture, withExtension: "wav", subdirectory: "zundamon") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("音声ファイルの読み込みに失敗しました。", error)
            }
        }
    }
}

