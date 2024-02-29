//
//  ViewController.swift
//  DispCurrentLocation
//
//  Created by yutaron on 2024/02/25.
//

import UIKit
import CoreLocation
import AVFoundation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var testButton: UIButton!
    
    let locationManager = CLLocationManager()
    var audioPlayer: AVAudioPlayer?
    
    var currentPrefecture = ""

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
                
                // 都道府県超え検知
                if ((self.currentPrefecture != place.administrativeArea) && (self.currentPrefecture != "")) {
                    self.notifyByZundamon(prefectureName: place.administrativeArea!)                    
                }
                
                self.currentPrefecture = place.administrativeArea!
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation() // 許可されたら位置情報の取得を開始
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        notifyByZundamon(prefectureName: "長崎県")
    }
    
    func notifyByZundamon(prefectureName: String) {
        // フォアグラウンドだったら
//        guard let soundURL = getSoundUrl(prefecture: prefecture) else {
//            print("音声ファイルの読み込みに失敗しました。")
//            return;
//        }
//        
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
//            audioPlayer?.prepareToPlay()
//            audioPlayer?.play()
//        } catch {
//            print("音声ファイルの再生に失敗しました", error)
//        }
        
        // バックグラウンドだったら
        sendNotification(prefectureName: prefectureName)
    }
    
    func sendNotification(prefectureName: String) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "\(prefectureName)に入りました", arguments: nil)
//        content.body = NSString.localizedUserNotificationString(forKey: "メッセージ内容", arguments: nil)
        
        let alphaName = prefectureNameToAlpha(prefectureName: prefectureName)
        if (alphaName != nil) {
            print(alphaName!)
            content.sound = UNNotificationSound(named: UNNotificationSoundName("\(alphaName!).mp3"))
        } else {
            content.sound = .default
        }

        // トリガーを設定（ここでは5秒後に設定）
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // リクエストを作成
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        // リクエストを通知センターに追加
        UNUserNotificationCenter.current().add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    func getSoundUrl(prefectureName: String) -> URL? {
        guard let alphaName = prefectureNameToAlpha(prefectureName: prefectureName) else {
            return nil
        }
        
        return Bundle.main.url(forResource: alphaName, withExtension: "mp3", subdirectory: "zundamon")
    }
    
    func prefectureNameToAlpha(prefectureName: String) -> String? {
        let codes = [
                "北海道": "hokkaido",
                "青森県": "aomori",
                "岩手県": "iwate",
                "宮城県": "miyagi",
                "秋田県": "akita",
                "山形県": "yamagata",
                "福島県": "fukushima",
                "茨城県": "ibaraki",
                "栃木県": "tochigi",
                "群馬県": "gunma",
                "埼玉県": "saitama",
                "千葉県": "chiba",
                "東京都": "tokyo",
                "神奈川県": "kanagawa",
                "新潟県": "niigata",
                "富山県": "toyama",
                "石川県": "ishikawa",
                "福井県": "fukui",
                "山梨県": "yamanashi",
                "長野県": "nagano",
                "岐阜県": "gifu",
                "静岡県": "shizuoka",
                "愛知県": "aichi",
                "三重県": "mie",
                "滋賀県": "shiga",
                "京都府": "kyoto",
                "大阪府": "osaka",
                "兵庫県": "hyogo",
                "奈良県": "nara",
                "和歌山県": "wakayama",
                "鳥取県": "tottori",
                "島根県": "shimane",
                "岡山県": "okayama",
                "広島県": "hiroshima",
                "山口県": "yamaguchi",
                "徳島県": "tokushima",
                "香川県": "kagawa",
                "愛媛県": "ehime",
                "高知県": "kochi",
                "福岡県": "fukuoka",
                "佐賀県": "saga",
                "長崎県": "nagasaki",
                "熊本県": "kumamoto",
                "大分県": "oita",
                "宮崎県": "miyazaki",
                "鹿児島県": "kagoshima",
                "沖縄県": "okinawa"
            ]

            return codes.first(where: { $0.key == prefectureName })?.value
    }
}

