//
//  ViewController.swift
//  Cycle_ConviniMap
//
//  Created by Daisuke Doi on 2023/01/05.
// safe_area y:60
// 検索結果の一覧表示 参照元 -> https://dev.classmethod.jp/articles/location-suggest-use-mapkit/
// 経路の表示 参照元 ->
//


import UIKit
import MapKit

class MainViewController: UIViewController, UISearchBarDelegate  {
    let colors = Colors()
    let mapView = MKMapView()
    var request = MKLocalSearch.Request()
    var departurePoint = "現在地"
    var arrivalPoint = "到着地点"
    
    
    let attributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.systemFont(ofSize: 12.0, weight: .heavy), // 文字色
        .foregroundColor : UIColor.darkGray, // カラー
        .strokeColor : UIColor.gray, // 縁取りの色
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //出発地点表示ビュー
        let departureView = UIView()
        departureView.frame = CGRect(x: 0, y: 60, width: view.frame.size.width, height: 60)
        departureView.backgroundColor = colors.blueGreen
        view.addSubview(departureView)
        
        let currentLocationButton = UIButton(type: .system)
        currentLocationButton.frame = CGRect(x: 20, y: 70, width: 40, height: 40)
        currentLocationButton.backgroundColor = .white
        currentLocationButton.layer.cornerRadius = 10
        currentLocationButton.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        currentLocationButton.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
        view.addSubview(currentLocationButton)
        //currentLocationButton.addTarget(self, action: #selector(****), for: .touchDown)
        
        
        let departureSearchButton = UIButton(type: .system)
        departureSearchButton.frame = CGRect(x: 80, y: 70, width: view.frame.size.width - 100, height: 40)
        departureSearchButton.backgroundColor = .white
        departureSearchButton.layer.cornerRadius = 10
        departureSearchButton.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
        let departureAttributedTitle = NSAttributedString(string: departurePoint, attributes: attributes)
        departureSearchButton.setAttributedTitle(departureAttributedTitle, for: .normal)
        //departureSearchButton.textAlignment = NSTextAlignment.center
        view.addSubview(departureSearchButton)
        departureSearchButton.addTarget(self, action: #selector(goDepartureRouteCandidate), for: .touchDown)
        
        
        
        //到着地点表示ビュー
        let arrivalView = UIView()
        arrivalView.frame = CGRect(x: 0, y: 120, width: view.frame.size.width, height: 60)
        arrivalView.backgroundColor = colors.bluePurple
        view.addSubview(arrivalView)
        
        let randomLocationLabel = UIButton(type: .system)
        randomLocationLabel.frame = CGRect(x: 20, y: 130, width: 40, height: 40)
        randomLocationLabel.backgroundColor = .white
        randomLocationLabel.layer.cornerRadius = 10
        randomLocationLabel.setImage(UIImage(systemName: "dice"), for: .normal)
        randomLocationLabel.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
        view.addSubview(randomLocationLabel)
        //currentLocationButton.addTarget(self, action: #selector(****), for: .touchDown)
        
        let arrivalSearchButton = UIButton(type: .system)
        arrivalSearchButton.frame = CGRect(x: 80, y: 130, width: view.frame.size.width - 100, height: 40)
        arrivalSearchButton.backgroundColor = .white
        arrivalSearchButton.layer.cornerRadius = 10
        arrivalSearchButton.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
        let arrivalAttributedTitle = NSAttributedString(string: arrivalPoint, attributes: attributes)
        arrivalSearchButton.setAttributedTitle(arrivalAttributedTitle, for: .normal)
        //arrivalSearchButton.textAlignment = NSTextAlignment.center
        view.addSubview(arrivalSearchButton)
        arrivalSearchButton.addTarget(self, action: #selector(goArrivalRouteCandidate), for: .touchDown) //selectorでクロージャ外の関数を呼ぶ時は、シャープ？
        
        
        //MapView
        mapView.frame = CGRect(x: 0, y: 180, width: view.frame.size.width, height: view.frame.size.height - 180)
        view.addSubview(mapView)
        
        
        //ROuteCandidate検索結果の場所にアノテーションをおく
        /*search.startWithCompletionHandler { response, error in
            response?.mapItems.forEach { item in
                
                let point = MKPointAnnotation()
                point.coordinate = item.placemark.coordinate
                point.title = item.placemark.title
                self.mapView.addAnnotation(point)
            }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
        */
        
        //検索結果を表示する
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            response?.mapItems.forEach { item in
                
                let point = MKPointAnnotation()
                point.coordinate = item.placemark.coordinate
                point.title = item.placemark.title
                self.mapView.addAnnotation(point)
            }
        }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        
        
        //Helpボタン(初回起動時に出る操作方法を、もう一度出す)
        let helpButton = UIButton(type: .system)
        helpButton.frame = CGRect(x: view.frame.size.width - 85, y: view.frame.size.height - 185, width: 100, height: 100)
        helpButton.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        helpButton.tintColor =  .white
        view.addSubview(helpButton)
        helpButton.addTarget(self, action: #selector(goHelp), for: .touchDown) //selectorでクロージャ外の関数を呼ぶ時は、シャープ？
        
    }
    
    // モーダル遷移から戻った時に起動するメソッド
    
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

