//
//  LootCanditateViewController.swift
//  Cycle_ConviniMap
//
//  Created by Daisuke Doi on 2023/01/07.
//
// TableView コードのみで実装　-> https://first-code.hatenablog.com/entry/2019/09/22/095301

import UIKit
import MapKit

protocol RouteCandidateViewControllerDelegate {
    func handleSearch(pointName: String)
}

final class RouteCandidateViewController: UIViewController, UISearchBarDelegate {

    // MARK: - property
    var searchBar = UISearchBar()
    var tableView = UITableView()
    var searchCompleter = MKLocalSearchCompleter()
    var cell = UITableViewCell()
    var searchIdentifier = "" // MainView　検索ボタンのSegue元を識別する
    var locatePoint = ""
    var request = MKLocalSearch.Request()
    var delegate: RouteCandidateViewControllerDelegate?

    // MARK: init
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

    // MARK: - func

    // 検索ボタンを押した時に反応するDelegateメソッド、queryFragmentで検索している
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if let searchWord = searchBar.text {
            print(searchWord)
            searchCompleter.queryFragment = searchBar.text!
        }
    }
}

// MARK: - tableviewdelegate, datasource
extension RouteCandidateViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCompleter.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell // 再利用するセルを生成
        let completion = searchCompleter.results[indexPath.row] // searchCompleterを実行、実行結果にindexPath.rowで通し番号を渡す
        cell.textLabel?.text = completion.title //　セルのラベルに、取得データのタイトルを
        cell.detailTextLabel?.text = completion.subtitle // セルのdetailedLabelに、取得データのサブタイトルを生成
        return cell
    }

    // cellが選択された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 下記　前のビューからMainViewインスタンスを取得(モーダル⇨タブバー⇨メインと入れ子上に取得してる)

        let selectedPoint = searchCompleter.results[indexPath.row].title // 選択されたセルのタイトルを取得
        print("TableViewCell \(selectedPoint) was selected")

        // FIXME: storyboardの読み込みによる値渡し⇨プロトコルによる値渡しにリファクタリング
        if searchIdentifier == "departure" { // 出発地点
            let departurePointName = selectedPoint // 出発地点の情報　上書き
            delegate?.handleSearch(pointName: departurePointName) // 検索させる
            print("departurePointName transported")
        } else if searchIdentifier == "arrival" {// 到着地点
            let arrivalPointName = selectedPoint
            delegate?.handleSearch(pointName: arrivalPointName) // 検索させる
            print("arrivalPointName transported")
        } else { // 例外処理
            print("Identification was not successed")
            return
        }

        self.dismiss(animated: true, completion: nil) // Viewを閉じる。
    }
}

//: MARK　キーワード検索の結果にあわせてテーブルビューを操作するプロトコル準拠
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
