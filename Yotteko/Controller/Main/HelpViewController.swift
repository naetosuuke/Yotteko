//
//  HelpViewController.swift
//  Yotteko
//
//  Created by Daisuke Doi on 2023/01/07.
//

//  gonna implement after release

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
        
        setUpLabel("<使用方法>", frame: CGRect(x: 20, y: 10, width: contentView.frame.width - 40, height: 40), font: labelFont, color: .black, contentView)
        setUpLabel("上部の出発地点、到着地点ボタンを押し、検索画面から出発地点、到着地点の2点を選択してください。2点間の経路、所要時間、距離を表示します。", frame: CGRect(x: 20, y: 50, width: contentView.frame.width - 40, height: 40), font: labelFont, color: .black, contentView)
        setUpLabel("出発地点は、デフォルトで現在地となっています。", frame: CGRect(x: 20, y: 140, width: contentView.frame.width - 40, height: 40), font: labelFont, color: .black, contentView)
        
        //currentLocationButton
        let _: UIButton = {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 15, y: 250, width: 40, height: 40)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
            button.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
            view.addSubview(button)
        
            return button
        }()
        setUpLabel("出発地点を現在地に設定できます。", frame: CGRect(x: 50, y: 200, width: contentView.frame.width - 40, height: 40), font: labelFont, color: .black, contentView)
            
        //到着地点  randomlocation ランダム表示ボタン
        //GenerateRouteButton
        let _: UIButton = {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 15, y:300, width: 40, height: 40)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.setImage(UIImage(systemName: "repeat"), for: .normal)
            button.clipsToBounds = true //LabelのRadiusを設定する場合は、これ必要
            view.addSubview(button)
            return button

        }()
        setUpLabel("経路 検索結果画面を閉じた後、もう一度開けます。", frame: CGRect(x: 50, y: 250, width: contentView.frame.width - 40, height: 40), font: labelFont, color: .black, contentView)
        
        
        
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
