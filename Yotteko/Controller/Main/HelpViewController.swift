//
//  HelpViewController.swift
//  Yotteko
//
//  Created by Daisuke Doi on 2023/01/07.
//

import UIKit

class HelpViewController: UIViewController {

    var contentView: UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.orange
        // Do any additional setup after loading the view.
        generateView()
        setLabels()
    }
    
    
    private func generateView() { // Mapのトップより上の高さ　50  contentviewのトップより下の長さ　200  モーダルで隠れている分　110(筐体でズレあり)
        
        let contentView = UIView()
        contentView.frame = CGRect(x: 10, y: 50, width: view.frame.size.width - 20, height: 200 + 100) //横　view通り、縦340
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 30 //角をまるめる
        self.contentView = contentView
        view.addSubview(contentView) // viewの上にcontentViewをのせている
        
        let topLabel = UILabel()
        topLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        topLabel.text = "操作方法"
        topLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        topLabel.textColor = .white
        topLabel.center.x = view.center.x
        topLabel.textAlignment = .center
        view.addSubview(topLabel)
        

    }
    
    private func setLabels() {
        
        guard let contentView = self.contentView else { return }
        let labelFont = UIFont.systemFont(ofSize: 15, weight: .heavy) //これからつくるラベルのパラメータを作成
        
        setUpLabel("使用方法を記載します", frame: CGRect(x: 20, y: 20, width: contentView.frame.width - 40, height: 40), font: labelFont, color: .black, contentView)
        
        func setUpLabel(_ text: String, frame:CGRect, font:UIFont, color:UIColor, _ parentView: UIView){
            let label = UILabel() //UILabelクラスでラベルを生成できる。
            label.text = text
            label.frame = frame
            label.font = font
            label.textColor = color
            label.numberOfLines = 0
            parentView.addSubview(label) //のせる下のViewを宣言
        }
    }


}
