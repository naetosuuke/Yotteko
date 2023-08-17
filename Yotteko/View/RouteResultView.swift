//
//  RouteResultView.swift
//  Yotteko
//
//  Created by Daisuke Doi on 2023/08/17.
//

import Foundation
import UIKit
import MapKit

extension RouteResultViewController {
    
    func generateView() { // Mapのトップより上の高さ　50  contentviewのトップより下の長さ　200  モーダルで隠れている分　110(筐体でズレあり)

        let contentView = UIView()
        contentView.frame = CGRect(x: 10, y: view.frame.size.height - 200 - 100 - 100, width: view.frame.size.width - 20, height: 200 + 100) // 横　view通り、縦340
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 30 // 角をまるめる
        self.contentView = contentView
        view.addSubview(contentView) // viewの上にcontentViewをのせている

        let topLabel = UILabel()
        topLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        topLabel.text = "作成済みの経路"
        topLabel.textColor = .white
        topLabel.center.x = view.center.x
        topLabel.textAlignment = .center
        view.addSubview(topLabel)
    }
    
    func generateMapView() { // 地図を描写するメソッド
        mapView.frame = CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.frame.size.height - 50 - 200 - 110 - 100)
        mapView.delegate = self
        view.addSubview(mapView)
    }
    
    func setLabels() {
        
        guard let contentView = self.contentView else { return }
        let labelFont = UIFont.systemFont(ofSize: 15, weight: .heavy) // これからつくるラベルのパラメータを作成
        
        // 経路の距離　型変換+四捨五入
        guard var distance = distance else { return }
        distance = distance as Double
        let distanceKm = round(distance / 10) / 100// round関数は整数の値で四捨五入する。
        
        // 経路の移動時間 徒歩4km/h,自転車12km/h, 車は地図のタイプをかえないといけないので後日実装
        guard let time = self.expectedTravelTime else { return }
        let hour = Int(time/3600)
        let minutes = (time - Double(hour * 3600))/60
        let cycleTime = time / 3
        let cycleHour = Int(cycleTime/3600)
        let cycleMinutes = (cycleTime - Double(cycleHour * 3600))/60
        
        setUpLabel("出発地: \(departurePointName!)", frame: CGRect(x: 20, y: 20, width: contentView.frame.width - 40, height: 40), font: labelFont, color: .black, contentView)
        setUpLabel("目的地: \(arrivalPointName!)", frame: CGRect(x: 20, y: 50, width: contentView.frame.width - 40, height: 40), font: labelFont, color: .black, contentView)
        setUpLabel("距離:\(distanceKm)km", frame: CGRect(x: 20, y: 90, width: 150, height: 20), font: labelFont, color: .black, contentView)
        setUpLabel("時間:徒歩     \(hour) 時間 \(String(format: "%.0f", minutes))分", frame: CGRect(x: view.center.x - 30, y: 90, width: 200, height: 20), font: labelFont, color: .black, contentView)
        setUpLabel("自転車 \(cycleHour) 時間 \(String(format: "%.0f", cycleMinutes))分", frame: CGRect(x: view.center.x + 4, y: 110, width: 200, height: 20), font: labelFont, color: .black, contentView)
        setUpLabel("------------------------------", frame: CGRect(x: 20, y: 160, width: view.frame.width - 40, height: 20), font: labelFont, color: .black, contentView)
    }

}
