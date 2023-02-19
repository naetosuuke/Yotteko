//
//  ViewController.swift
//  Cycle_ConviniMap
//
//  Created by Daisuke Doi on 2023/01/05.
// safe_area y:60
// 検索結果の一覧表示 参照元 -> https://dev.classmethod.jp/articles/location-suggest-use-mapkit/
// TableViewからMapに検索結果を渡す方法　-> https://qiita.com/hanawat/items/1f3f3c277a8f2c4b07d2
// 経路の表示 参照元 -> https://orangelog.site/swift/mapkit-waypoints-route-direction/
//


import UIKit
import MapKit

class MainViewController: UIViewController, UISearchBarDelegate  {
    let colors = Colors()
    // var coordinateArray = [CoordinatesArray]()
    let mapView = MKMapView()
    var searchIdentifier = ""
    
    var departurePointName = "現在地"
    var departureRequest = MKLocalSearch.Request()
    var departureMapItem = MKMapItem()

    var arrivalPointName = "到着地点"
    var arrivalRequest = MKLocalSearch.Request()
    var arrivalMapItem = MKMapItem()


    let attributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.systemFont(ofSize: 12.0, weight: .heavy), // 文字色
        .foregroundColor : UIColor.darkGray, // カラー
        .strokeColor : UIColor.gray, // 縁取りの色
    ]
    
    
    //var coordinatesArray = [ //座標の情報　MKLocalSearchの戻り値 Mapitemsからパースする必要あり？もしくはそのまま入れれる？
    //    ["name":"初期地点",    "lat":35.68124,  "lon": 139.76672],
    //    ["name":"寄り道地点1",   "lat":35.68026,  "lon": 139.75801],
    //    ["name":"寄り道地点2",   "lat":35.6818,   "lon": 139.74326],
    //    ["name":"到着地点",   "lat":35.69555,  "lon": 139.75074]
    //]
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //出発地点表示ビュー
        let departureView = UIView()
        departureView.frame = CGRect(x: 0, y: 60, width: view.frame.size.width, height: 60)
        departureView.backgroundColor = colors.blueGreen
        view.addSubview(departureView)
        
        //現在地点 表示ボタン
        let currentLocationButton = UIButton(type: .system)
        currentLocationButton.frame = CGRect(x: 20, y: 70, width: 40, height: 40)
        currentLocationButton.backgroundColor = .white
        currentLocationButton.layer.cornerRadius = 10
        currentLocationButton.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        currentLocationButton.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
        view.addSubview(currentLocationButton)
        //currentLocationButton.addTarget(self, action: #selector(****), for: .touchDown)
        
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
        arrivalView.backgroundColor = colors.bluePurple
        view.addSubview(arrivalView)
        
        //到着地点 ランダム表示ボタン
        let randomLocationButton = UIButton(type: .system)
        randomLocationButton.frame = CGRect(x: 20, y: 130, width: 40, height: 40)
        randomLocationButton.backgroundColor = .white
        randomLocationButton.layer.cornerRadius = 10
        randomLocationButton.setImage(UIImage(systemName: "dice"), for: .normal)
        randomLocationButton.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
        view.addSubview(randomLocationButton)
        //currentLocationButton.addTarget(self, action: #selector(****), for: .touchDown)
        
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
        
        //MapView
        mapView.frame = CGRect(x: 0, y: 180, width: view.frame.size.width, height: view.frame.size.height - 180)
        mapView.delegate = self //mapview delegate
        view.addSubview(mapView)
        
        
        print(searchIdentifier)
        
        //出発地点検索結果を表示する
        if searchIdentifier == "departure" { //目的地点検索検索結果
            let departureSearch = MKLocalSearch(request: departureRequest)
            departureSearch.start { response, error in
                //エラーハンドリング　表示必要
                response?.mapItems.forEach { item in //mapItems　responseがもってる
                    self.departureMapItem = item //MKMapItem型データを代入
                    //元のコード response内のMKMapItemからplacemark.coordinatem/titleプロパティ を取得してアノテーションを生成
                    let departurePoint = MKPointAnnotation()
                    departurePoint.coordinate = item.placemark.coordinate
                    departurePoint.title = item.placemark.title
                    self.mapView.addAnnotation(departurePoint)
                    //
                }
            }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true) //アノテーションをMapにのせる
            
            
        } else if searchIdentifier == "arrival" { //到着地点検索結果　アノテーションを表示する
            let arrivalSearch = MKLocalSearch(request: arrivalRequest)
            arrivalSearch.start { response, error in
                //エラーハンドリング　表示必要
                response?.mapItems.forEach { item in //mapItems　responseがもってる
                    self.arrivalMapItem = item //MKMapItem型データを代入
                    //元のコード response内のMKMapItemからplacemark.coordinatem/titleプロパティ を取得してアノテーションで表示
                    let arrivalPoint = MKPointAnnotation()
                    arrivalPoint.coordinate = item.placemark.coordinate
                    arrivalPoint.title = item.placemark.title
                    self.mapView.addAnnotation(arrivalPoint)
                }
            }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true) //アノテーションをMapにのせる
            
        } else { // searchIdentifierがない場合(画面が遷移されていない場合)
            print("searchIdentifier doesn`t have a value yet")
        }
        
        
        // マップ情報 初期化
        let coordinate = CLLocationCoordinate2DMake(coordinatesArray[0]["lat"] as! CLLocationDegrees, coordinatesArray[0]["lon"] as! CLLocationDegrees) //CLLocationDegrees　型のx,y座標を入力し、構造体CLLocationCoordinate2Dを作成
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) //X,Y軸の表示範囲を持つ構造体 値1あたり約111km
        let region = MKCoordinateRegion(center: coordinate, span: span) //マップの表示域を設定(座標、表示範囲を渡す)
        self.mapView.setRegion(region, animated: true) //表示範囲をマップに設定
        
        
        //座標情報の型変換 (coordinatesArray -> annotationCoordinate -> [routeCoordinates] -> item) = CLLocationCoordinate2D
        //              placemark = MKPlacemark(coordinate: item)
        //              placemarks = [MKMapItem(placemark: placemark)]
        //              経路作成のfor処理 placemarks = MKMapItemを引数
        //              つまり、MKMapItemの配列を作成すれば、経路作成は可能
        //              また、配列の順番は[開始地点, 寄り道1, 寄り道2, ...寄り道.count, 終了地点と設定るす。]
        //
        /*経由地点のアノテーション表示＋前経由地点の座標情報を配列に追加　引用元コード
        var routeCoordinates: [CLLocationCoordinate2D] = [] //ルートを構成する地点情報(CLLocationCOordinate2D)を入れる配列を初期化
        for i in 0..<coordinatesArray.count { //経由地の数だけ繰り返す
            let annotation = MKPointAnnotation() //アノテーションのインスタンス生成
            let annotationCoordinate = CLLocationCoordinate2DMake(coordinatesArray[i]["lat"] as! CLLocationDegrees, coordinatesArray[i]["lon"] as! CLLocationDegrees) //アノテーションの座標情報を代入
            annotation.title = coordinatesArray[i]["name"] as? String //ピンの吹き出しに名前が出るように
            annotation.coordinate = annotationCoordinate //アノテーション coordinateプロパティに座標情報を渡す
            routeCoordinates.append(annotationCoordinate) //ルート作成に使用するrouteCoodinates配列にアノテーション座標情報を追加
            self.mapView.addAnnotation(annotation) //アノテーションをviewに表示
        }
        print("取得した座標の配列を表示します。\(routeCoordinates)")
        */
        
    
        /* 経路作成に使う情報を投入　　引用元コード
        var myRoute: MKRoute! //MKPolyLineでなくMKRouteを使用
        let directionsRequest = MKDirections.Request() //MKDirectionsの検索値として渡すMKDirections.Recuestのインスタンス生成
        var placemarks = [MKMapItem]() //構造体 MKMapItemを配列としてインスタンス化
        //routeCoordinatesの配列からMKMapItemの配列に変換
        for item in routeCoordinates {
            //↓ routeCoordinate配列のデータが持つcoordinateプロパティをコンバート
            //  **ここでrouteCoordinateをitemとして代入、なのでplacemarkはitemというプロパティを持つことになる（初期化される）
            let placemark = MKPlacemark(coordinate: item, addressDictionary: nil)
            placemarks.append(MKMapItem(placemark: placemark)) //コンバートして代入したplacemarkをMKMapItemに入れ、初期化したものを配列として追加（分けて書けや！）
        }
        */
        
        
        
        
        
        
        // ~~~~~~~~一旦取り消し、実装予定の処理(経路用のMKMapItem配列の作成＋Annotationと経路作成)~~~~~~~~~~
        if self.departureMapItem != nil, self.arrivalMapItem != nil {
            var placemarks = [MKMapItem]() //MKDirections.Requestインスタンスに渡すMKMapItemの配列を作成
            placemarks.append(departureMapItem)
            
            // ~~ここに寄り道の検索結果　MapItemを取得
            
            placemarks.append(arrivalMapItem)
            
            
            var myRoute: MKRoute! //MKPolyLineでなくMKRouteを使用
            let directionsRequest = MKDirections.Request() //MKDirectionsの検索値として渡すMKDirections.Recuestのインスタンス生成
            directionsRequest.transportType = .walking //移動手段は徒歩
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
            return
        }
        //~~~~~~~~一旦取り消し、実装予定の処理(経路用のMKMapItem配列の作成＋Annotationと経路作成)~~~~~~~~~~
        
        
        
        
        
        
        
        /*　全ての経由地を通る経路の表示（人が通る直線ver）　引用元コード
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
        */
        
        //Helpボタン(初回起動時に出る操作方法を、もう一度出す)
        let helpButton = UIButton(type: .system)
        helpButton.frame = CGRect(x: view.frame.size.width - 85, y: view.frame.size.height - 185, width: 100, height: 100)
        helpButton.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        helpButton.tintColor =  .white
        view.addSubview(helpButton)
        helpButton.addTarget(self, action: #selector(goHelp), for: .touchDown) //selectorでクロージャ外の関数を呼ぶ時は、シャープ？
        
        var searchIdentifier = "searchIdentifier:blank(initialized while viewDidLoad)"
        print(searchIdentifier)
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


extension MainViewController:MKMapViewDelegate {
    //アノテーションのパラメーターを設定するDelegateメソッド？
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { //現在地の場合はnil?
            return nil
        }
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
