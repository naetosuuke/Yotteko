//
//  GeneratedRouteViewController.swift
//  Yotteko
//
//  Created by Daisuke Doi on 2023/01/07.
//

//  gonna implement after release


import UIKit
import MapKit

class GeneratedRouteViewController: UIViewController {
    
    var tableView = UITableView()
    var cell = UITableViewCell()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.blue
                                                                    
        let topLabel = UILabel()
        topLabel.frame = CGRect(x: 0, y: 80, width: view.frame.size.width, height: 50)
        topLabel.text = "作成済みの経路一覧"
        topLabel.textColor = Colors.white
        topLabel.center.x = view.center.x
        topLabel.textAlignment = .center
        view.addSubview(topLabel)
        
        tableView.frame = .init(x: 0, y: 130, width: view.frame.size.width, height: 999)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderColor = Colors.blue.cgColor
        tableView.rowHeight = 60
        tableView.separatorColor = UIColor.black
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
    }
    
    @objc func goRouteResult(selectedDeparturePointName: String, selectedArrivalPointName: String, selectedDepartureMapItem: MKMapItem, selectedArrivalMapItem: MKMapItem){
        let modalVC = RouteResultViewController()
        //modalVC.delegate = self
        modalVC.departurePointName = selectedDeparturePointName
        modalVC.arrivalPointName = selectedArrivalPointName
        modalVC.departureMapItem = selectedDepartureMapItem
        modalVC.arrivalMapItem = selectedArrivalMapItem
        
        present(modalVC, animated: true, completion: nil)
    }
    
}


//:MARK 検索結果を並べるテーブルビューのためのプロトコル準拠
extension GeneratedRouteViewController: UITableViewDelegate, UITableViewDataSource {
    
    //テーブルビューの行数　検索結果にあわせる
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 // 保持したデータのcountに書き換える
    }
    
    //ここでcellの使用を決定している。検索結果 .resultsに"MKLocationSearchCompletion"が内包、これをテーブルビューに表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) //再利用するセルを生成
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = "新宿革命記念公演" //　セルのラベルに、取得データのタイトルを
        cell.detailTextLabel?.text = "まだまだ遊び足りない" // セルのdetailedLabelに、取得データのサブタイトルを生成
        return cell
    }
    
    //cellが選択された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)番セルが押されたよ！")
        
        //FIXME: Realmに保存した検索結果をフェッチし、キャストしてRouteResultVCに代入する
        
        //goRouteResult(selectedDeparturePointName: <#String#>, selectedArrivalPointName: <#String#>, selectedDepartureMapItem: <#MKMapItem#>, selectedArrivalMapItem: <#MKMapItem#>)
        
        
        //departureSearchButton.addTarget(self, action: #selector(goDepartureRouteCandidate), for: .touchDown)
        //下記　前のビューからMainViewインスタンスを取得(モーダル⇨タブバー⇨メインと入れ子上に取得してる)
        //let tab = self.presentingViewController as! UITabBarController
        //let vc = tab.selectedViewController as! MainViewController
    }
    
}

