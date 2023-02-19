//
//  LootCanditateViewController.swift
//  Cycle_ConviniMap
//
//  Created by Daisuke Doi on 2023/01/07.
//
// TableView コードのみで実装　-> https://first-code.hatenablog.com/entry/2019/09/22/095301

import UIKit
import MapKit

class RouteCandidateViewController: UIViewController, UISearchBarDelegate  {

    var searchBar = UISearchBar()
    var tableView = UITableView()
    var searchCompleter = MKLocalSearchCompleter()
    var cell = UITableViewCell()
    var searchIdentifier = "" // MainView　検索ボタンのSegue元を識別する
    var locatePoint = ""
    var request = MKLocalSearch.Request()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(searchIdentifier) //　MainViewController どちらからきたかで軽油を変えている
        if searchIdentifier == "departure" {
            locatePoint = " 出発地点のキーワードを入力してください"
            view.backgroundColor = Colors.blueGreen
        } else if searchIdentifier == "arrival" {
            locatePoint = " 到着地点のキーワードを入力してください"
            view.backgroundColor = Colors.bluePurple
        } else {
            print("Identification was not successed")
            return
        }
        
        searchBar.frame = .init(x: 0, y: 20, width: view.frame.size.width, height: 60)
        searchBar.delegate = self
        searchBar.placeholder = locatePoint
        searchBar.tintColor = Colors.blue
        searchBar.backgroundColor = .white
        //searchBar.layer.cornerRadius = 10
        //searchBar.layer.borderWidth = 3
        //searchBar.layer.borderColor = colors.blueGreen.cgColor
        view.addSubview(searchBar)

        
        tableView.frame = .init(x: 0, y: 80, width: view.frame.size.width, height: 999)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderColor = Colors.blue.cgColor
        tableView.rowHeight = 60
        tableView.separatorColor = UIColor.black
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        searchCompleter.resultTypes = .pointOfInterest // override内じゃなきゃプロパティの変更できないよ
        searchCompleter.delegate = self
        
    }
    
    //検索ボタンを押した時に反応するDelegateメソッド、queryFragmentで検索している
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if let searchWord = searchBar.text{
            print(searchWord)
            //searchCompleter.region = mapView.region // 検索結果の範囲　リージョンで指名
            searchCompleter.queryFragment = searchBar.text!

        }
    }
}


//:MARK 検索結果を並べるテーブルビューのためのプロトコル準拠
extension RouteCandidateViewController: UITableViewDelegate, UITableViewDataSource {
    
    //テーブルビューの行数　検索結果にあわせる
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCompleter.results.count
    }
    
    //ここでcellの使用を決定している。検索結果 .resultsに"MKLocationSearchCompletion"が内包、これをテーブルビューに表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) //再利用するセルを生成
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        
        
        let completion = searchCompleter.results[indexPath.row] //searchCompleterを実行、実行結果にindexPath.rowで通し番号を渡す
        print(searchCompleter.results[0])
        cell.textLabel?.text = completion.title //　セルのラベルに、取得データのタイトルを
        cell.detailTextLabel?.text = completion.subtitle // セルのdetailedLabelに、取得データのサブタイトルを生成
        return cell
    }
    
    //cellが選択された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)番セルが押されたよ！")
        //下記　前のビューからMainViewインスタンスを取得(モーダル⇨タブバー⇨メインと入れ子上に取得してる)
        let tab = self.presentingViewController as! UITabBarController
        let vc = tab.selectedViewController as! MainViewController
        let selectedPoint = searchCompleter.results[indexPath.row].title //選択されたセルのタイトルを取得
        vc.searchIdentifier = searchIdentifier // 開始地点と到着地点　どちらを検索したかの識別子をMainViewに返す
        //返す先を選ぶ
        if searchIdentifier == "departure" { //出発地点
            vc.departurePointName = selectedPoint //出発地点の情報　上書き
            vc.departureRequest = MKLocalSearch.Request(completion: searchCompleter.results[indexPath.row])
        } else if searchIdentifier == "arrival" {//到着地点
            vc.arrivalPointName = selectedPoint //到着地点の情報　上書き
            vc.arrivalRequest = MKLocalSearch.Request(completion: searchCompleter.results[indexPath.row])
        } else { //例外処理
            print("Identification was not successed")
            return
        }
        vc.loadView() //dismissだと遷移元のライフサイクルが反応しないので、こっちで動かす
        vc.viewDidLoad()
        self.dismiss(animated: true, completion: nil) // Viewを閉じる。
    }
    
    
    
}

//:MARK　キーワード検索の結果にあわせてテーブルビューを操作するプロトコル準拠
extension RouteCandidateViewController: MKLocalSearchCompleterDelegate {
    
    // 正常に検索結果が更新されたとき
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        tableView.reloadData()
        print("searched \(searchBar.text!)")
    }
    
    // 検索が失敗したとき
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // エラー処理
        print("failed to get search result")
    }
}
