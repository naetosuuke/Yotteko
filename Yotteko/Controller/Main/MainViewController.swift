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
//@objc StoryBoardがらみのDelegateメソッドにつける
//クロージャ内でグローバル変数をよぶとき
//selfをつけるとグローバル変数が上書きされる
//selfをつけないと、クロージャ内での変更は破棄される


import UIKit
import MapKit
import CoreLocation


class MainViewController: UIViewController, UISearchBarDelegate {
    
    //MARK: - property
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var mapView = MKMapView()
    
    var searchIdentifier = "blank"
    var departurePointName = "現在地"
    var departureRequest: MKLocalSearch.Request?
    var departureMapItem: MKMapItem?
    var arrivalPointName = "到着地点"
    var arrivalRequest: MKLocalSearch.Request?
    var arrivalMapItem: MKMapItem?

    var latestPinnedPoint:MKPointAnnotation? //最後におされたピンのCoordinateを記録、

    let attributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.systemFont(ofSize: 12.0, weight: .heavy), // 文字色
        .foregroundColor : UIColor.darkGray, // カラー
        .strokeColor : UIColor.gray, // 縁取りの色
    ]
    
    var didStartUpdatingLocation = false //初期値　false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 位置情報取得の許可状況を確認
        initLocation()
        //UI周りを表示
        generateView()
        generateMapView()
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        generateCurrentLocationAnnotation()
        generateAnnotation()
        generateRoute()
    }
    
    private func initLocation() { //invoke 呼び出す:  メインスレッドが動いている時、UIが動かなくなる原因になるかも
        switch CLLocationManager.authorizationStatus() { //現在地取得　許可ステータス　判別
        case .notDetermined: //未許可の場合
            //ユーザーが位置情報の許可をまだしていないので、位置情報許可のダイアログを表示する
            locationManager.requestWhenInUseAuthorization() //quickhelp参照、位置情報の取得前に必ずこれを呼び出さないといけない
        case .restricted, .denied: //断られている場合
            showPermissionAlert() //許可をとるfunc実行
        case .authorizedAlways, .authorizedWhenInUse: //許可済みの場合
            if !didStartUpdatingLocation{ //初期値 falseだったら(一回もアップデートしていなければ)
                didStartUpdatingLocation = true //アップデート済み　へと変換
                locationManager.startUpdatingLocation() //ロケーションの取得を開始
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.distanceFilter = kCLDistanceFilterNone //どれだけ動いたら反応するか
                guard let userLocation: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
                print("initLocation()で取得したlocations (CLLocationCoordinate2D)= \(userLocation.latitude) \(userLocation.longitude)")
                self.userLocation = userLocation
            }
        @unknown default:
            break
        }
    }
    
    //MARK: - configure view
    
    private func generateView() {
        //出発地点表示ビュー
        let departureView = UIView()
        departureView.frame = CGRect(x: 0, y: 60, width: view.frame.size.width, height: 60)
        departureView.backgroundColor = Colors.blueGreen
        view.addSubview(departureView)
        //出発地点 検索ボタン
        let departureSearchButton = UIButton(type: .system)
        departureSearchButton.frame = CGRect(x: 80, y: 70, width: view.frame.size.width - 100, height: 40)
        departureSearchButton.backgroundColor = .white
        departureSearchButton.layer.cornerRadius = 10
        departureSearchButton.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
        let departureAttributedTitle = NSAttributedString(string: departurePointName, attributes: attributes)
        departureSearchButton.setAttributedTitle(departureAttributedTitle, for: .normal)
        //departureSearchButton.textAlignment = NSTextAlignment.center
        view.addSubview(departureSearchButton)
        departureSearchButton.addTarget(self, action: #selector(goDepartureRouteCandidate), for: .touchDown)
        
        //到着地点表示ビュー
        let arrivalView = UIView()
        arrivalView.frame = CGRect(x: 0, y: 120, width: view.frame.size.width, height: 60)
        arrivalView.backgroundColor = Colors.bluePurple
        view.addSubview(arrivalView)
        //到着地点 検索ボタン
        let arrivalSearchButton = UIButton(type: .system)
        arrivalSearchButton.frame = CGRect(x: 80, y: 130, width: view.frame.size.width - 100, height: 40)
        arrivalSearchButton.backgroundColor = .white
        arrivalSearchButton.layer.cornerRadius = 10
        arrivalSearchButton.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
        let arrivalAttributedTitle = NSAttributedString(string: arrivalPointName, attributes: attributes)
        arrivalSearchButton.setAttributedTitle(arrivalAttributedTitle, for: .normal)
        //arrivalSearchButton.textAlignment = NSTextAlignment.center
        view.addSubview(arrivalSearchButton)
        arrivalSearchButton.addTarget(self, action: #selector(goArrivalRouteCandidate), for: .touchDown) //selectorでクロージャ外の関数を呼ぶ時は、シャープ？
        
        //現在地点 currentlocation 表示ボタン
        let currentLocationButton = UIButton(type: .system)
        currentLocationButton.frame = CGRect(x: 20, y: 70, width: 40, height: 40)
        currentLocationButton.backgroundColor = .white
        currentLocationButton.layer.cornerRadius = 10
        currentLocationButton.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        currentLocationButton.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
        view.addSubview(currentLocationButton)
        //currentLocationButton.addTarget(self, action: #selector(****), for: .touchDown)
        //到着地点  randomlocation ランダム表示ボタン
        let randomLocationButton = UIButton(type: .system)
        randomLocationButton.frame = CGRect(x: 20, y: 130, width: 40, height: 40)
        randomLocationButton.backgroundColor = .white
        randomLocationButton.layer.cornerRadius = 10
        randomLocationButton.setImage(UIImage(systemName: "dice"), for: .normal)
        randomLocationButton.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
        view.addSubview(randomLocationButton)
        //currentLocationButton.addTarget(self, action: #selector(****), for: .touchDown)
        //Helpボタン(初回起動時に出る操作方法を、もう一度出す)
        let helpButton = UIButton(type: .system)
        helpButton.frame = CGRect(x: view.frame.size.width - 85, y: view.frame.size.height - 185, width: 100, height: 100)
        helpButton.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        helpButton.tintColor =  .white
        view.addSubview(helpButton)
        helpButton.addTarget(self, action: #selector(goHelp), for: .touchDown) //selectorでクロージャ外の関数を呼ぶ時は、シャープ？
    }
        
    private func generateMapView() { //地図を描写するメソッド
        mapView.frame = CGRect(x: 0, y: 180, width: view.frame.size.width, height: view.frame.size.height - 180)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        //mapView.userTrackingMode = .follow
        
        // Region is the coordinate and span of the map.
        // Region may be modified to fit the aspect ratio of the view using regionThatFits:.
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 0.5, longitudinalMeters: 0.5)//縮尺を設定
        mapView.setRegion(region, animated:true)
        view.addSubview(mapView)
        
    }

    //MARK: - configure currentlocation
    
    private func generateCurrentLocationAnnotation(){
        print("逆ジオコーダーの引数 CLLocation取得前 userLocation \(self.userLocation)")
        let currentLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
        //↓この処理　検索結果(戻り値 -> MKMapItem)がでるより先に処理が飛ばされている
        print("リバースジオコーダー検索開始")
        CLGeocoder().reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks, error) in
            if error == nil {
                //CLLocationで取得している現在地を、Geocoderで検索(最終的に、ルート作成用のMKMapを作りたい)
                print("リバースジオコーダー検索結果")
                
                
                guard var departureMapItem = self.departureMapItem else {return}
                self.searchIdentifier = "departure_currentlocation"  //初期値書き換え
                self.mapView.removeAnnotations(self.mapView.annotations)
                let currentPlacemark:CLPlacemark = (placemarks?[0])! //CLPlacemark型
                print("CKPlacemark 情報 \(currentPlacemark)")
                //検索結果　placemark(CLPlacemark型)を MKPlacemarkにキャスト
                let placemark = MKPlacemark(placemark: currentPlacemark) //CLPlacemarkをMKPlacemarkにコンバートする
                print("MKPlacemark(コンバート後)　情報 \(placemark)")
                departureMapItem = MKMapItem(placemark: placemark)
                print("MKMapItem(コンバート後)　座標情報 \(departureMapItem.placemark.coordinate)")
                departureMapItem.name = "現在地"
                let departurePoint = MKPointAnnotation()
                departurePoint.coordinate = departureMapItem.placemark.coordinate
                departurePoint.title = departureMapItem.name
                self.latestPinnedPoint = departurePoint
                self.mapView.addAnnotation(departurePoint)
                self.mapView.showAnnotations(self.mapView.annotations, animated: true) //アノテーションをMapにのせる
                print("現在地アノテーション設置　完了")
            }
        })
    }
    

    
    
    private func generateAnnotation() {
        
        print(searchIdentifier) //検索結果の座標情報が出発地、到着地のどちらかを確認する
        
        
        
        //出発地点検索結果を表示する
        if searchIdentifier == "departure" { //目的地点検索検索結果
            print("departureRequestの中身確認")
            print(departureRequest)
            guard let departureRequest = self.departureRequest else { return }
            let departureSearch = MKLocalSearch(request: departureRequest)
            print("request入手前　検索前に保存されているアノテーション\(self.mapView.annotations)")
            self.mapView.removeAnnotations(self.mapView.annotations)
            print("request入手後　アノテーションの削除済んんでいる？\(self.mapView.annotations)")
            
            /*
             MKLocalSearch　非同期処理なので、処理が終わるまでawaitさせる
             
            */
            
            print("MKLocalsearch 引数departure 検索開始")
            departureSearch.start(completionHandler: { (response, error) in
                    //エラーハンドリング　表示必要
                    response?.mapItems.forEach { item in //mapItems　responseがもってる
                        //検索結果のDeparturePointを表示
                        print("MKLocalsearch 引数departure 検索完了")
                        print(item)
                        self.departureMapItem = item //MKMapItem型データを代入
                        let departurePoint = MKPointAnnotation()
                        departurePoint.coordinate = item.placemark.coordinate
                        departurePoint.title = item.name
                        self.latestPinnedPoint = departurePoint
                        self.mapView.addAnnotation(departurePoint)
                        //最後に取得したArrivalPointを表示
                        let arrivalPoint = MKPointAnnotation()
                        guard let arrivalMapItem = self.arrivalMapItem else {return}
                        arrivalPoint.coordinate = arrivalMapItem.placemark.coordinate
                        arrivalPoint.title = arrivalMapItem.placemark.title
                        self.mapView.addAnnotation(arrivalPoint)
                        print("出発地アノテーション設置　完了")
                        
                    }
                })
        } else if searchIdentifier == "arrival" { //到着地点検索結果　アノテーションを表示する
            print("arrivalRequestの中身確認")
            guard let arrivalRequest = self.arrivalRequest else {return}
            print(arrivalRequest)
            let arrivalSearch = MKLocalSearch(request: arrivalRequest)
            
            print("request入手前　検索前に保存されているアノテーション\(self.mapView.annotations)")
            self.mapView.removeAnnotations(self.mapView.annotations)
            print("request入手後　アノテーションの削除済んんでいる？\(self.mapView.annotations)")
            
            /*
             MKLocalSearch　非同期処理なので、処理が終わるまでawaitさせる
             */
            
            print("MKLocalsearch 引数arrival 検索開始")
            arrivalSearch.start(completionHandler: { (response, error) in
                //エラーハンドリング　表示必要
                response?.mapItems.forEach { item in //mapItems　responseがもってる
                    print("MKLocalsearch 引数arrival 検索完了")
                    print(item)
                    //検索結果のDeparturePointを表示
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.arrivalMapItem = item //MKMapItem型データを代入
                    let arrivalPoint = MKPointAnnotation()
                    arrivalPoint.coordinate = item.placemark.coordinate
                    arrivalPoint.title = item.name
                    self.latestPinnedPoint = arrivalPoint
                    self.mapView.addAnnotation(arrivalPoint)
                    //最後に取得したArrivalPointを表示
                    let departurePoint = MKPointAnnotation()
                    guard let departureMapItem = self.departureMapItem else {return}
                    departurePoint.coordinate = departureMapItem.placemark.coordinate
                    departurePoint.title = departureMapItem.placemark.title
                    self.mapView.addAnnotation(departurePoint)
                    print("目的地アノテーション設置　完了")
                }
            })
        } else { // searchIdentifierがない場合(画面が遷移されていない場合)
            print("searchIdentifierに値が設定されていないため、出発地(検索結果)、目的地アノテーション設置は行われませんでした。")
        }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true) //アノテーションをMapにのせる
    }
    
    
    private func generateRoute() {
        
        print("route作成前にdepartureMapItemもっているか")
        print(departureMapItem?.name)
        print("route作成前にarrivalMapItemもっているか")
        print(arrivalMapItem?.name)
        
        
        //現在地と到着地点の両方が選択されている場合
        if departureMapItem?.name != "Unknown Location" && arrivalMapItem?.name != "Unknown Location" {
            mapView.removeAnnotations(self.mapView.annotations) //　検索結果のロジックから出てくるアノテーションを初期化
            print("generateRoute annotationsが削除できているか確認")
            print(self.mapView.annotations)
            var placemarks = [MKMapItem]() //MKDirections.Requestインスタンスに渡すMKMapItemの配列を作成
            guard let departureMapItem = self.departureMapItem else {return}
            guard let arrivalMapItem = self.arrivalMapItem else {return}
            placemarks.append(departureMapItem)
            placemarks.append(arrivalMapItem)
            print("placemarksの中身確認")
            print(placemarks)
            var myRoute: MKRoute! //MKPolyLineでなくMKRouteを使用
            let directionsRequest = MKDirections.Request() //MKDirectionsの検索値として渡すMKDirections.Recuestのインスタンス生成
            directionsRequest.transportType = .walking //移動手段は徒歩
            for (k, item) in placemarks.enumerated(){ //k 0からのインクリメント, とitem配列(中身 routeCoordinates)を繰り返し
                if k < (placemarks.count - 1){ //繰り返し回数がplacemarkの数未満なら(まだ呼び出してない配列データがあれば)
                    directionsRequest.source = item //検索値 sourceプロパティにスタート地点情報を渡す routeCoordinate[k]
                    directionsRequest.destination = placemarks[k + 1] //目標地点(配列1つ先の座標情報) MKPlacemark(coordinate: item)[k+1]
                    let direction = MKDirections(request: directionsRequest) //MKDirectionsクラスを初期化
                    direction.calculate(completionHandler: {(response, error) in //calculateメソッドを開始
                        if error == nil { //エラーが出なければ
                            myRoute = response?.routes[0] //respoce?routes[0] を代入
                            self.mapView.addOverlay(myRoute.polyline, level: .aboveRoads) //mapViewに描写
                        }
                    })
                }
            }
        } else {
            print("Route作成用メソッド　起動しませんでした")
            return
        }
    }
    
    
    @objc func goDepartureRouteCandidate(){ //Segueを作動させるメソッド
        performSegue(withIdentifier: "goRouteCandidate", sender: "departure")
    }
    @objc func goArrivalRouteCandidate(){
        performSegue(withIdentifier: "goRouteCandidate", sender: "arrival")
    }
    @objc func goHelp(){
        performSegue(withIdentifier: "goHelp", sender: nil)
    }
    @objc func goRouteResult(){
        performSegue(withIdentifier: "goRouteResult", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //検索ボタンの識別コード(sender)を渡している どっちのボタンかで検索結果を返す先を分岐させる
        // ②Segueの識別子確認
        if segue.identifier == "goRouteCandidate" {
            // ③遷移先ViewCntrollerの取得
            let nextView = segue.destination as! RouteCandidateViewController
            // ④値の設定
            nextView.searchIdentifier = sender as! String
        }
    }
    
    
   
    
    
}


// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate { //位置情報を取得(更新を検知)した際に起動するdelegateメソッド

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("位置の更新を取得")
        guard let userLocation: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //print("locations = \(userLocation.latitude) \(userLocation.longitude)")
        self.userLocation = userLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: nil, message: "位置情報の取得に失敗しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
//MARK: Utility
    private func showPermissionAlert(){ //位置情報の取得
        //位置情報が制限されている/拒否されている
        let alert = UIAlertController(title: "位置情報の取得", message: "設定アプリから位置情報の使用を許可して下さい。", //アラートコントローラ初期化
                                      preferredStyle: .alert)
        let goToSetting = UIAlertAction(title: "設定アプリを開く", style: .default) { _ in //アラートのアクションを初期化
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { //設定画面に遷移するURLを代入
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) { // URLを開けることができれば
                UIApplication.shared.open(settingsUrl, completionHandler: nil) //移動する
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (_) in //通知のキャンセルアクション
            self.dismiss(animated: true, completion: nil) //モーダルを下げる
        }
        alert.addAction(goToSetting) //設定画面にいくアクションを追加
        alert.addAction(cancelAction) //キャンセルするアクションを追加
        
        self.present(alert, animated: true, completion: nil)//アラート画面を表示
    }
    
}


//MARK:MKMapViewDelegate

extension MainViewController:MKMapViewDelegate {
        
    //ピンが押された時のDeleagteメソッド
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("latestPinnedPoint 座標")
        guard let latestPinnedPoint = self.latestPinnedPoint else {return}
        print(latestPinnedPoint.coordinate)
        var region:MKCoordinateRegion = MKCoordinateRegion(center:latestPinnedPoint.coordinate, latitudinalMeters: 0.05, longitudinalMeters: 0.05)//縮尺を設定
        mapView.setRegion(region,animated:false)
        view.addSubview(mapView)
    }
    
    //アノテーションのパラメーターを設定するDelegateメソッド？
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true //吹き出しで情報を表示出来るように
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //経路を引く線のパラメーターを設定するDelegateメソッド？
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let route: MKPolyline = overlay as! MKPolyline
        let routeRenderer = MKPolylineRenderer(polyline: route)
        routeRenderer.strokeColor = UIColor(red:1.00, green:0.35, blue:0.30, alpha:1.0)
        routeRenderer.lineWidth = 3.0
        return routeRenderer
    }
    
}
