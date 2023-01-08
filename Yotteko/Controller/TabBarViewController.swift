//
//  TabBarController.swift
//  Cycle_ConviniMap
//
//  Created by Daisuke Doi on 2023/01/07.
//
//
//  SFSymbol iOS13以降で使用可能。なので最小要件もそう設定する
//


import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let mainVC = MainViewController()
        mainVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "globe.asia.australia.fill"), tag:0)
        let generatedRouteVC = GeneratedRouteViewController()
        generatedRouteVC.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "list.bullet"), tag:1)
        let onlineRouteVC = OnlineRouteViewController()
        onlineRouteVC.tabBarItem = UITabBarItem(title: "Online", image: UIImage(systemName: "network"), tag:2)
        let configureVC = ConfigureViewController()
        configureVC.tabBarItem = UITabBarItem(title: "Configure", image: UIImage(systemName: "dial.low"), tag:3)
    
        self.viewControllers = [mainVC, generatedRouteVC, onlineRouteVC, configureVC]
        
    }

    
}
