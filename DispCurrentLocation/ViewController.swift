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
    @IBOutlet var zundamonImage: UIImageView!
    @IBOutlet var zundamonImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var zundamonImageWidthConstraint: NSLayoutConstraint!
    
    // 消して良いかも
    @IBOutlet var zundamonImageTrailingConstraint: NSLayoutConstraint!
    let locationManager = CLLocationManager()
    var audioPlayer: AVAudioPlayer?
    
    var currentPrefecture = ""
    var isBackground = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeLabel.numberOfLines = 0 //折り返し
         placeLabel.text = "Loading..."
        placeLabel.textAlignment = .center
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        locationManager.desiredAccuracy = kCLDistanceFilterNone
        locationManager.distanceFilter =  150
        
        // アプリ使用中の位置情報の許可をユーザに求める
        locationManager.startUpdatingLocation() // 位置情報の取得を開始
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(foreground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(background(notification:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "ja_JP")) {(placemarks, error) in
                guard let pms = placemarks else{
                    return
                }
                guard let place = pms.first else{
                    return
                }
                
                var locationStr = ""
                locationStr.append(place.administrativeArea ?? "")
                locationStr.append(place.subAdministrativeArea ?? "")
                locationStr.append(place.locality ?? "")
                locationStr.append(place.subLocality ?? "")
                // 丁目の概念がない土地の場合、subLocalityとthoroughfareが同じになるため分岐
                if (place.subLocality != place.thoroughfare) {
                    locationStr.append(place.thoroughfare ?? "")
                }

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
    
    // 動作テスト用ボタン
    @IBAction func buttonTapped(_ sender: Any) {
        notifyByZundamon(prefectureName: "石川県")
    }
    
    func notifyByZundamon(prefectureName: String) {
        if (isBackground) {
            sendNotification(prefectureName: prefectureName)
        } else {
            speechZundamon(prefectureName: prefectureName)
        }
    }
    
    func speechZundamon(prefectureName: String) {
        guard let soundURL = getSoundUrl(prefectureName: prefectureName) else {
            print("音声ファイルの読み込みに失敗しました。")
            return;
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("音声ファイルの再生に失敗しました", error)
        }
    }
    
    func sendNotification(prefectureName: String) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "\(prefectureName)に入りました", arguments: nil)
        
        let alphaName = prefectureNameToAlpha(prefectureName: prefectureName)
        if (alphaName != nil) {
            content.sound = UNNotificationSound(named: UNNotificationSoundName("zundamon/\(alphaName!).mp3"))
        } else {
            content.sound = .default
        }

        // トリガーを設定（ここでは3秒後に設定）
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
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
    
    @objc func foreground(notification: Notification) {
        self.isBackground = false
    }
    
    @objc func background(notification: Notification) {
        self.isBackground = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            if UIDevice.current.orientation.isLandscape {
                // 横画面の場合の制約
                self.zundamonImageHeightConstraint.constant = self.view.frame.height * 0.5
                self.zundamonImageWidthConstraint.constant =  self.view.frame.width * 0.2
                self.placeLabel.font = UIFont.systemFont(ofSize: 42)
            } else {
                // 縦画面の場合の制約
                self.zundamonImageHeightConstraint.constant = self.view.frame.height * 0.3
                self.zundamonImageWidthConstraint.constant =  self.view.frame.width * 0.4
                self.placeLabel.font = UIFont.systemFont(ofSize: 36)
            }
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
