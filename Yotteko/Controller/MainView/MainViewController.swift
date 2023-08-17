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

//  gonna implement after release

import UIKit
import MapKit
import CoreLocation
import FloatingPanel

final class MainViewController: UIViewController, UISearchBarDelegate, RouteCandidateViewControllerDelegate {

    // MARK: - property
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    var mapView = MKMapView()
    var fpc = FloatingPanelController()

    // 各種フラグ
    var didStartUpdatingLocation = false // 現在地情報の許可状況を判断　初期値false
    var localGeoSearchFlag = true // GeoSearchをすると出発地点のMKMapItemが上書きされるので、自分で出発地点を選んだ時はfalseにする
    var searchIdentifier = "blank" // 出発、到着地点のどちらを検索したいか判定するIdentifier 初期値blank
    
    // 初期化
    var departureSearchButton: UIButton?
    var departurePointName = "現在地"
    var departureRequest: MKLocalSearch.Request?
    var departureMapItem: MKMapItem?

    var arrivalSearchButton: UIButton?
    var arrivalPointName = "到着地点"
    var arrivalRequest: MKLocalSearch.Request?
    var arrivalMapItem: MKMapItem?

    var latestPinnedPoint: MKPointAnnotation? // 最後におされたピンのCoordinateを記録、

    override func viewDidLoad() {
        super.viewDidLoad()
        // fpc.delegate = self　FloatingPanel デリゲート設定　使ってないのでコメントアウト
        // 位置情報取得の許可状況を確認
        setupViews()
        initLocation()
        // UI周りを表示
        generateView()
        generateMapView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if localGeoSearchFlag == true {
            generateCurrentLocationAnnotation()
        } else {
            generateAnnotation()
        }

        print("このMapが読み込まれた際のlocalGeoSearchFlag = \(localGeoSearchFlag)")
    }

    private func setupViews() {
        locationManager.delegate = self
    }

    // MARK: - configure Annotation & Route

    private func generateCurrentLocationAnnotation() {

        guard let currentLocation = locationManager.location else {return} // 現在地　オプショナルなのでアンラップ
        // ↓この処理　検索結果(戻り値 -> MKMapItem)がでるより先に処理が飛ばされている
        CLGeocoder().reverseGeocodeLocation(currentLocation, completionHandler: {placemarks, error in
            if error == nil {
                // CLLocationで取得している現在地を、Geocoderで検索(最終的に、ルート作成用のMKMapを作りたい)
                self.searchIdentifier = "departure_currentlocation"  // 初期値書き換え
                self.removeAnnotarions()
                let currentPlacemark: CLPlacemark = (placemarks?[0])! // CLPlacemark型
                // 検索結果　placemark(CLPlacemark型)を MKPlacemarkにキャスト
                let placemark = MKPlacemark(placemark: currentPlacemark) // CLPlacemarkをMKPlacemarkにコンバートする
                let departureMapItem = MKMapItem(placemark: placemark)
                departureMapItem.name = "現在地"
                self.departureMapItem = departureMapItem
                let departurePoint = MKPointAnnotation()
                departurePoint.coordinate = departureMapItem.placemark.coordinate
                departurePoint.title = departureMapItem.name
                self.latestPinnedPoint = departurePoint
                self.mapView.addAnnotation(departurePoint)
                let arrivalPoint = MKPointAnnotation()
                if let arrivalMapItem = self.arrivalMapItem {
                    arrivalPoint.coordinate = arrivalMapItem.placemark.coordinate
                    arrivalPoint.title = arrivalMapItem.placemark.title
                    self.mapView.addAnnotation(arrivalPoint)
                }
                self.mapView.showAnnotations(self.mapView.annotations, animated: true) // アノテーションをMapにのせる
                print("現在地アノテーション設置　完了")
                self.generateRoute()
            }
        })
     }

    func centerMapOnUserLocation() { // 現在地ボタンのselectorの中身
        guard let coordinates = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateRegion, animated: true)
        self.generateCurrentLocationAnnotation()
        self.departurePointName = "現在地"
        let departureAttributedTitle = NSAttributedString(string: self.departurePointName, attributes: Character.attributes)
        if let button = self.departureSearchButton {
            button.setAttributedTitle(departureAttributedTitle, for: .normal)
            view.addSubview(button)
        }
    }

    func handleSearch(pointName: String) {
        print("searchIdentifier = \(searchIdentifier)")

        switch self.searchIdentifier {
        case "departure":
            self.departurePointName = pointName
            let departureAttributedTitle = NSAttributedString(string: departurePointName, attributes: Character.attributes)
            self.departureSearchButton?.setAttributedTitle(departureAttributedTitle, for: .normal)

        case "arrival":
            self.arrivalPointName = pointName
            let arrivalAttributedTitle = NSAttributedString(string: arrivalPointName, attributes: Character.attributes)
            self.arrivalSearchButton?.setAttributedTitle(arrivalAttributedTitle, for: .normal)

        default:
            return
        }
        removeAnnotarions()// アノテーション情報を初期化
        print("removing check annotation\(self.mapView.annotations)")
        generateAnnotation()
    }

    private func generateAnnotation() {
        // 出発地点検索結果を表示する
        if self.searchIdentifier == "departure" { // 目的地点検索検索結果
            mapView.showsUserLocation = false // 現在地情報　消す
            let departureRequest = MKLocalSearch.Request()
            departureRequest.naturalLanguageQuery = departurePointName // 検索ワード

            let departureSearch = MKLocalSearch(request: departureRequest)
            departureSearch.start(completionHandler: { response, _ in
                let item = response?.mapItems[0] // mapItems　responseがもってる
                guard let item = item else { return }
                /// 検索結果のDeparturePointを表示
                print("MKLocalsearch departure result \(self.departurePointName)")
                self.departureMapItem = item // MKMapItem型データを代入
                let departurePoint = MKPointAnnotation()
                departurePoint.coordinate = item.placemark.coordinate
                departurePoint.title = item.name
                self.latestPinnedPoint = departurePoint
                self.mapView.addAnnotation(departurePoint)

                // 最後に取得したArrivalPointを表示
                let arrivalPoint = MKPointAnnotation()
                if let arrivalMapItem = self.arrivalMapItem {
                    arrivalPoint.coordinate = arrivalMapItem.placemark.coordinate
                    arrivalPoint.title = arrivalMapItem.placemark.title
                    self.mapView.addAnnotation(arrivalPoint)
                }
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                print("出発地(検索分)アノテーション設置　完了")
                self.generateRoute()
                })
        } else if searchIdentifier == "arrival" { // 到着地点検索結果　アノテーションを表示する

            let arrivalRequest = MKLocalSearch.Request()
            arrivalRequest.naturalLanguageQuery = arrivalPointName // 検索ワード
            let arrivalSearch = MKLocalSearch(request: arrivalRequest)
            arrivalSearch.start(completionHandler: { response, _ in
                    let item = response?.mapItems[0] // mapItems　responseがもってる
                    guard let item = item else { return }
                    // 検索結果のDeparturePointを表示
                    print("MKLocalsearch arrival result \(self.arrivalPointName)")
                    // 検索結果のDeparturePointを表示
                    self.arrivalMapItem = item // MKMapItem型データを代入
                    let arrivalPoint = MKPointAnnotation()
                    arrivalPoint.coordinate = item.placemark.coordinate
                    arrivalPoint.title = item.name
                    self.latestPinnedPoint = arrivalPoint
                    self.mapView.addAnnotation(arrivalPoint)
                    // 最後に取得したArrivalPointを表示
                    let departurePoint = MKPointAnnotation()
                    if let departureMapItem = self.departureMapItem {
                        departurePoint.coordinate = departureMapItem.placemark.coordinate
                        departurePoint.title = departureMapItem.placemark.title
                        self.mapView.addAnnotation(departurePoint)
                    }
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                    print("目的地アノテーション設置　完了")
                    self.generateRoute()
            })
        } else { // searchIdentifierがない場合(画面が遷移されていない場合)
            print("localsearch was not arranged this time")
        }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true) // アノテーションをMapにのせる
    }

    @objc func generateRoute() {

        // 現在地と到着地点の両方が選択されている場合
        if departureMapItem?.name != "Unknown Location" && arrivalMapItem?.name != "Unknown Location" {

            handleRemoveOverlays()
            
            var placemarks = [MKMapItem]() // MKDirections.Requestインスタンスに渡すMKMapItemの配列を作成
            guard let departureMapItem = self.departureMapItem else {return}
            guard let arrivalMapItem = self.arrivalMapItem else {return}
            print("route will generate (dep/arr MapItem are exist)")
            placemarks.append(departureMapItem)
            placemarks.append(arrivalMapItem)
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
                            self.mapView.addOverlay(myRoute.polyline, level: .aboveRoads) // mapViewに描写
                            self.goRouteResult()
                        }
                    })
                }
            }
        } else {
            print("Route作成用メソッド　起動しませんでした")
            return
        }
    }

    func removeAnnotarions() { // アノテーション削除
        mapView.annotations.forEach {annotation in // mapViewがもってるannotationに繰り返し処理　処理はまたクロージャで記載
            if let annotation = annotation as? MKPointAnnotation { // MKPointAnnotation方のアノテーションのみ選択（こうしないと現在地も消える）
                mapView.removeAnnotation(annotation) // mapViewから削除
            }
        }
    }

    func handleRemoveOverlays() {
        if mapView.overlays.count > 0 {
            self.mapView.removeOverlay(mapView.overlays[0])
        }
    }

    // MARK: - selector

    @objc func handleCenterLocation() {
        self.localGeoSearchFlag = true
        print("localGeoSearchFlag is changed to true")
        centerMapOnUserLocation()
    }
    @objc func goDepartureRouteCandidate() { // Segueを作動させるメソッド
        self.localGeoSearchFlag = false
        print("localGeoSearchFlag is changed to \(localGeoSearchFlag)")
        self.searchIdentifier = "departure"
        let modalVC = RouteCandidateViewController()
        modalVC.delegate = self
        modalVC.searchIdentifier = "departure"
        present(modalVC, animated: true, completion: nil)
    }
    @objc func goArrivalRouteCandidate() {
        self.searchIdentifier = "arrival"
        let modalVC = RouteCandidateViewController()
        modalVC.delegate = self
        modalVC.searchIdentifier = "arrival"
        present(modalVC, animated: true, completion: nil)
    }
    // FIXME:　操作方法画面

    @objc func goHelp() {

        let modalVC = HelpViewController()
        fpc.isRemovalInteractionEnabled = true

        fpc.set(contentViewController: modalVC)
        fpc.addPanel(toParent: self)
    }

    @objc func goRouteResult() {
        let modalVC = RouteResultViewController()
        // modalVC.delegate = self
        modalVC.departurePointName = self.departurePointName
        modalVC.arrivalPointName = self.arrivalPointName
        modalVC.departureMapItem = self.departureMapItem!
        modalVC.arrivalMapItem = self.arrivalMapItem!

        present(modalVC, animated: true, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate { // 位置情報を取得(更新を検知)した際に起動するdelegateメソッド
    private func initLocation() { // invoke 呼び出す:  メインスレッドが動いている時、UIが動かなくなる原因になるかも
        switch CLLocationManager().authorizationStatus { // 現在地取得　許可ステータス　判別
        case .notDetermined: // 許可してない
            locationManager.requestWhenInUseAuthorization() // quickhelp参照、位置情報の取得前に必ずこれを呼び出さないといけない
        case .restricted, .denied:
            showPermissionAlert()
        case .authorizedAlways, .authorizedWhenInUse: // 許可済みの場合
            getUserLocation()
        default: fatalError()
        }
    }

    private func getUserLocation() {
        locationManager.startUpdatingLocation() // ロケーションの取得を開始
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // 現在地の精度
        locationManager.distanceFilter = kCLDistanceFilterNone // どれだけ動いたら反応するか
        if let userLocation = locationManager.location?.coordinate {
            self.userLocation = userLocation
            print("initLocation()で取得したlocations (CLLocationCoordinate2D)= \(userLocation.latitude) \(userLocation.longitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            getUserLocation()
            generateView()
            generateMapView()
        case .denied, .restricted, .notDetermined:
            print("🟥位置情報の使用が拒否、制限、未設定です。")
        default: fatalError()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        switch localGeoSearchFlag {
            case false:
                print("位置情報は上書きされませんでした")
                return
            default:    // 出発地点　任意で取得している際は自動更新を止める
                guard let userLocation: CLLocationCoordinate2D = manager.location?.coordinate else { return }
                self.userLocation = userLocation
                print("位置の更新を取得")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: nil, message: "位置情報の取得に失敗しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }

// MARK: - Permission
    private func showPermissionAlert() { // 位置情報の取得
        // 位置情報が制限されている/拒否されている
        let alert = UIAlertController(title: "位置情報の取得", message: "設定アプリから位置情報の使用を許可して下さい。(経路検索時、現在地を表示します。)", // アラートコントローラ初期化
                                      preferredStyle: .alert)
        let goToSetting = UIAlertAction(title: "設定アプリを開く", style: .default) { _ in // アラートのアクションを初期化
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { // 設定画面に遷移するURLを代入
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) { // URLを開けることができれば
                UIApplication.shared.open(settingsUrl, completionHandler: nil) // 移動する
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { _ in // 通知のキャンセルアクション
            self.dismiss(animated: true, completion: nil) // モーダルを下げる
        }
        alert.addAction(goToSetting) // 設定画面にいくアクションを追加
        alert.addAction(cancelAction) // キャンセルするアクションを追加

        self.present(alert, animated: true, completion: nil)// アラート画面を表示
    }
}

// MARK: - MKMapViewDelegate

extension MainViewController: MKMapViewDelegate {

    // ピンが押された時のDeleagteメソッド 現在地が更新されるたびにRegionが変わるのはきつい
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
