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


class RouteResultViewController: UIViewController {
    
    let colors = Colors()
    private var mapView = MKMapView()
    var departureMapItem = MKMapItem()
    var arrivalMapItem = MKMapItem()
    var latestPinnedPoint = MKPointAnnotation() //最後におされたピンのCoordinateを記録、
    let attributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.systemFont(ofSize: 12.0, weight: .heavy), // 文字色
        .foregroundColor : UIColor.darkGray, // カラー
        .strokeColor : UIColor.gray, // 縁取りの色
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.blue
        //UI周りを表示
        generateView()
        generateMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        generateAnnotation()
        generateRoute()
    }
    
    private func generateView() { // Mapのトップより上の高さ　50  contentviewのトップより下の長さ　200  モーダルで隠れている分　110(筐体でズレあり)
        
        let contentView = UIView()
        contentView.frame = CGRect(x: 10, y: view.frame.size.height - 200 - 100, width: view.frame.size.width - 20, height: 200) //横　view通り、縦340
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 30 //角をまるめる
        view.addSubview(contentView) // viewの上にcontentViewをのせている
        
        let topLabel = UILabel()
        topLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        topLabel.text = "作成済みの経路一覧"
        topLabel.textColor = .white
        topLabel.center.x = view.center.x
        topLabel.textAlignment = .center
        view.addSubview(topLabel)
        
        let labelFont = UIFont.systemFont(ofSize: 15, weight: .heavy) //これからつくるラベルのパラメータを作成

        
        setUpLabel("出発地: ", frame: CGRect(x: 20, y: 0, width: 200, height: 30), font: labelFont, color: .black, contentView)
        setUpLabel("目的地: ", frame: CGRect(x: 20, y: 20, width: 200, height: 30), font: labelFont, color: .black, contentView)
        setUpLabel("経由地 1", frame: CGRect(x: 20, y: 40, width: 200, height: 30), font: labelFont, color: .black, contentView)
        setUpLabel("経由地 2", frame: CGRect(x: 20, y: 60, width: 200, height: 30), font: labelFont, color: .black, contentView)
        setUpLabel("経由地 3", frame: CGRect(x: 20, y: 80, width: 200, height: 30), font: labelFont, color: .black, contentView)
        setUpLabel("経由地 4", frame: CGRect(x: 20, y: 100, width: 200, height: 30), font: labelFont, color: .black, contentView)
        setUpLabel("経由地 5", frame: CGRect(x: 20, y: 120, width: 200, height: 30), font: labelFont, color: .black, contentView)
        
    }
    
    private func generateMapView() { //地図を描写するメソッド
        mapView.frame = CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.frame.size.height - 50 - 200 - 110)
        mapView.delegate = self
        // mapView.showsUserLocation = true
        // mapView.mapType = .standard
        // mapView.userTrackingMode = .follow
        
        // Region is the coordinate and span of the map.
        // Region may be modified to fit the aspect ratio of the view using regionThatFits:.
        // mapView.setRegion(region, animated:true)
        view.addSubview(mapView)
    }
    
    
    private func generateAnnotation() {
        /*
         print(searchIdentifier) //検索結果の座標情報が出発地、到着地のどちらかを確認する
         
         //出発地点検索結果を表示する
         if searchIdentifier == "departure" { //目的地点検索検索結果
         print("departureRequestの中身確認")
         print(departureRequest)
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
         arrivalPoint.coordinate = self.arrivalMapItem.placemark.coordinate
         arrivalPoint.title = self.arrivalMapItem.placemark.title
         self.mapView.addAnnotation(arrivalPoint)
         print("出発地アノテーション設置　完了")
         
         }
         })
         } else if searchIdentifier == "arrival" { //到着地点検索結果　アノテーションを表示する
         print("arrivalRequestの中身確認")
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
         departurePoint.coordinate = self.departureMapItem.placemark.coordinate
         departurePoint.title = self.departureMapItem.placemark.title
         self.mapView.addAnnotation(departurePoint)
         print("目的地アノテーション設置　完了")
         }
         })
         } else { // searchIdentifierがない場合(画面が遷移されていない場合)
         print("searchIdentifierに値が設定されていないため、出発地(検索結果)、目的地アノテーション設置は行われませんでした。")
         }
         self.mapView.showAnnotations(self.mapView.annotations, animated: true) //アノテーションをMapにのせる
         */
        
    }
    
    private func generateRoute() {
        
        print("route作成前にdepartureMapItemもっているか")
        print(departureMapItem)
        print("route作成前にarrivalMapItemもっているか")
        print(arrivalMapItem)
        
        
        //現在地と到着地点の両方が選択されている場合
        mapView.removeAnnotations(self.mapView.annotations) //　検索結果のロジックから出てくるアノテーションを初期化
        print("generateRoute annotationsが削除できているか確認")
        print(self.mapView.annotations)
        var placemarks = [MKMapItem]() //MKDirections.Requestインスタンスに渡すMKMapItemの配列を作成
        placemarks.append(self.departureMapItem)
        // ~~ここに寄り道の検索結果　MapItemを取得
        placemarks.append(self.arrivalMapItem)
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
    }
    
    
    func setUpLabel(_ text: String, frame:CGRect, font:UIFont, color:UIColor, _ parentView: UIView){
        let label = UILabel() //UILabelクラスでラベルを生成できる。
        label.text = text
        label.frame = frame
        label.font = font
        label.textColor = color
        parentView.addSubview(label) //のせる下のViewを宣言
        
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


//MARK:MKMapViewDelegate

extension RouteResultViewController:MKMapViewDelegate {
    //ピンが押された時のDeleagteメソッド
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("latestPinnedPoint 座標")
        print(latestPinnedPoint.coordinate)
        let region:MKCoordinateRegion = MKCoordinateRegion(center:latestPinnedPoint.coordinate, latitudinalMeters: 0.05, longitudinalMeters: 0.05)//縮尺を設定
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
