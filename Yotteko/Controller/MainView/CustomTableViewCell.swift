//
//  ViewController.swift
//  Yotteko
//
//  Created by Daisuke Doi on 2023/01/08.
//
//　検索結果要にTableViewCellクラスをオーバーライド(style = .subtitle　が目的)
// https://turedureengineer.hatenablog.com/entry/2018/12/06/170045
//

//  gonna implement after release

import UIKit

final class CustomTableViewCell: UITableViewCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "cell" )
    }

    required init?(coder aDecoder: NSCoder) { // これがないと起動しない。理由は後で調べる
        fatalError("init(coder:) has not been implemented")
    }
}
