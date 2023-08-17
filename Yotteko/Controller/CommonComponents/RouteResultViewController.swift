//
//  ViewController.swift
//  Cycle_ConviniMap
//
//  Created by Daisuke Doi on 2023/01/05.
// safe_area y:60
// 検索結果の一覧表示 参照元 -> https://dev.classmethod.jp/articles/location-suggest-use-mapkit/
// TableViewからMapに検索結果を渡す方法　-> https://qiita.com/hanawat/items/1f3f3c277a8f2c4b07d2
// 経路の表示 参照元 -> https://orangelog.site/swift/mapkit-waypoints-route-direction/
// 現在地の表示　参照元 -> https://qiita.com/yuta-sasaki/items/3151b3faf2303fe78312
//
// @objc StoryBoardがらみのDelegateメソッドにつける
// クロージャ内でグローバル変数をよぶとき
// selfをつけるとグローバル変数が上書きされる
// selfをつけないと、クロージャ内での変更は破棄される

import UIKit
import MapKit

final class RouteResultViewController: UIViewController {

    var mapView = MKMapView()
    var departurePointName: String?
    var departureMapItem = MKMapItem()
    var arrivalPointName: String?
    var arrivalMapItem = MKMapItem()

    var contentView: UIView?
    var distance: CLLocationDistance?
    var expectedTravelTime: TimeInterval?
    let latestPinnedPoint = MKPointAnnotation() // 最後におされたピンのCoordinateを記録、
    let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 12.0, weight: .heavy), // 文字色
        .foregroundColor: UIColor.darkGray, // カラー
        .strokeColor: UIColor.gray // 縁取りの色
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.blue
        // UI周りを表示
        generateView()
        generateMapView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        generateAnnotation()
    }
    


    private func generateAnnotation() {
         // 前画面から引用したMapItemから、アノテーション設置
         let departurePoint = MKPointAnnotation()
         departurePoint.coordinate = self.departureMapItem.placemark.coordinate
         departurePoint.title = self.departureMapItem.placemark.title
         self.mapView.addAnnotation(departurePoint)

         let arrivalPoint = MKPointAnnotation()
         arrivalPoint.coordinate = self.arrivalMapItem.placemark.coordinate
         arrivalPoint.title = self.arrivalMapItem.placemark.title
         self.mapView.addAnnotation(arrivalPoint)

         self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        self.generateRoute()
    }

    private func generateRoute() {
        var placemarks = [MKMapItem]() // MKDirections.Requestインスタンスに渡すMKMapItemの配列を作成
        placemarks.append(self.departureMapItem)
        // ~~ここに寄り道の検索結果　MapItemを取得
        placemarks.append(self.arrivalMapItem)
        print("placemarksの中身確認")
        print(placemarks)
        var myRoute: MKRoute! // MKPolyLineでなくMKRouteを使用
        let directionsRequest = MKDirections.Request() // MKDirectionsの検索値として渡すMKDirections.Recuestのインスタンス生成
        directionsRequest.transportType = .walking // 移動手段は徒歩
        for (k, item) in placemarks.enumerated() { // k 0からのインクリメント, とitem配列(中身 routeCoordinates)を繰り返し
            if k < (placemarks.count - 1) { // 繰り返し回数がplacemarkの数未満なら(まだ呼び出してない配列データがあれば)
                directionsRequest.source = item // 検索値 sourceプロパティにスタート地点情報を渡す routeCoordinate[k]
                directionsRequest.destination = placemarks[k + 1] // 目標地点(配列1つ先の座標情報) MKPlacemark(coordinate: item)[k+1]
                let direction = MKDirections(request: directionsRequest) // MKDirectionsクラスを初期化
                direction.calculate(completionHandler: {response, error in // calculateメソッドを開始
                    if error == nil { // エラーが出なければ
                        myRoute = response?.routes[0] // respoce?routes[0] を代入
                        self.distance = myRoute.distance
                        self.expectedTravelTime = myRoute.expectedTravelTime
                        self.mapView.addOverlay(myRoute.polyline, level: .aboveRoads) // mapViewに描写
                        print("ルート描写完了")
                        self.setLabels()
                    }
                })
            }
        }
    }

    func setUpLabel(_ text: String, frame: CGRect, font: UIFont, color: UIColor, _ parentView: UIView) {
        let label = UILabel() // UILabelクラスでラベルを生成できる。
        label.text = text
        label.frame = frame
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        parentView.addSubview(label) // のせる下のViewを宣言

    }
}

// MARK: MKMapViewDelegate

extension RouteResultViewController: MKMapViewDelegate {
    // ピンが押された時のDeleagteメソッド
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    }
    // アノテーションのパラメーターを設定するDelegateメソッド？
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true // 吹き出しで情報を表示出来るように
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    // 経路を引く線のパラメーターを設定するDelegateメソッド？
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let route: MKPolyline = overlay as! MKPolyline
        let routeRenderer = MKPolylineRenderer(polyline: route)
        routeRenderer.strokeColor = UIColor(red: 1.00, green: 0.35, blue: 0.30, alpha: 1.0)
        routeRenderer.lineWidth = 3.0
        return routeRenderer
    }
}
