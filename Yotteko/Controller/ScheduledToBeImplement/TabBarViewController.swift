//
//  TabBarController.swift
//  Cycle_ConviniMap
//
//  Created by Daisuke Doi on 2023/01/07.
//
//
//  SFSymbol iOS13以降で使用可能。なので最小要件もそう設定する
//
//　ver1.0リリース時点では未使用　今後、タブバーによる画面を追加予定

import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        let mainVC = MainViewController()
        mainVC.tabBarItem = UITabBarItem(title: "マップ", image: UIImage(systemName: "globe.asia.australia.fill"), tag: 0)
        let generatedRouteVC = GeneratedRouteViewController()
        generatedRouteVC.tabBarItem = UITabBarItem(title: "検索履歴", image: UIImage(systemName: "list.bullet"), tag: 1)
        let onlineRouteVC = OnlineRouteViewController()
        onlineRouteVC.tabBarItem = UITabBarItem(title: "みんなの履歴", image: UIImage(systemName: "network"), tag: 2)
        let configureVC = ConfigureViewController()
        configureVC.tabBarItem = UITabBarItem(title: "設定", image: UIImage(systemName: "dial.low"), tag: 3)

        self.viewControllers = [mainVC, generatedRouteVC, onlineRouteVC, configureVC]
    }
}
