//
//  MainView.swift
//  Yotteko
//
//  Created by Daisuke Doi on 2023/08/17.
//

import Foundation
import UIKit
import MapKit

extension MainViewController {
    
    func generateView() {
        // 出発地点表示ビュー
        let departureView = UIView()
        departureView.frame = CGRect(x: 0, y: 60, width: view.frame.size.width, height: 60)
        departureView.backgroundColor = Colors.blueGreen
        view.addSubview(departureView)
        
        // 出発地点 検索ボタン departureSearchButton
        let _: UIButton = {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 80, y: 70, width: view.frame.size.width - 100, height: 40)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.clipsToBounds = true // LabelのRadiusを設定する場合は、これ必要
            let departureAttributedTitle = NSAttributedString(string: departurePointName, attributes: Character.attributes)
            button.setAttributedTitle(departureAttributedTitle, for: .normal)
            view.addSubview(button)
            button.addTarget(self, action: #selector(goDepartureRouteCandidate), for: .touchDown)
            return button
        }()
        
        // 到着地点表示ビュー
        let arrivalView = UIView()
        arrivalView.frame = CGRect(x: 0, y: 120, width: view.frame.size.width, height: 60)
        arrivalView.backgroundColor = Colors.bluePurple
        view.addSubview(arrivalView)
        
        // 到着地点 検索ボタン arrivalSearchButton
        let _: UIButton = {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 80, y: 130, width: view.frame.size.width - 100, height: 40)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.clipsToBounds = true // LabelのRadiusを設定する場合は、これ必要
            let arrivalAttributedTitle = NSAttributedString(string: arrivalPointName, attributes: Character.attributes)
            button.setAttributedTitle(arrivalAttributedTitle, for: .normal)
            view.addSubview(button)
            button.addTarget(self, action: #selector(goArrivalRouteCandidate), for: .touchDown) // selectorでクロージャ外の関数を呼ぶ時は、シャープ？
            return button
        }()
        
        // 現在地点 currentlocation 表示ボタン
        let _: UIButton = {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 20, y: 70, width: 40, height: 40)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
            button.clipsToBounds = true // LabelのRadiusを設定する場合は、これ必要
            view.addSubview(button)
            button.addTarget(self, action: #selector(handleCenterLocation), for: .touchDown)
            self.localGeoSearchFlag = true
            return button
        }()
        
        // 到着地点  randomlocation ランダム表示ボタン
        let _: UIButton = {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 20, y: 130, width: 40, height: 40)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.setImage(UIImage(systemName: "repeat"), for: .normal)
            button.clipsToBounds = true // LabelのRadiusを設定する場合は、これ必要
            view.addSubview(button)
            button.addTarget(self, action: #selector(generateRoute), for: .touchDown)
            return button
        }()
        
        // Helpボタン(初回起動時に出る操作方法を、もう一度出す)
        let _: UIButton = {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 20, y: 10, width: 40, height: 40)
            button.backgroundColor = Colors.lightblue
            button.tintColor = .white
            button.layer.cornerRadius = 10
            button.clipsToBounds = true // LabelのRadiusを設定する場合は、これ必要
            button.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
            button.addTarget(self, action: #selector(goHelp), for: .touchDown) // selectorでクロージャ外の関数を呼ぶ時は、シャープ？
            mapView.addSubview(button)
            return button
        }()
    }
    
    func generateMapView() { // 地図を描写するメソッド
        mapView.frame = CGRect(x: 0, y: 180, width: view.frame.size.width, height: view.frame.size.height - 180)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        guard let userLocation = userLocation else { return } // 現在地　アンラップ
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 2000, longitudinalMeters: 2000)// 縮尺を設定
        mapView.setRegion(region, animated: true)
        view.addSubview(mapView)
    }
    
}
