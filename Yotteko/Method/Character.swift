//
//  CharacterAttributes.swift
//  Yotteko
//
//  Created by Daisuke Doi on 2023/08/17.
//

import Foundation
import UIKit

struct Character {
    // 文字の修飾
    static let attributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 12.0, weight: .heavy), // 文字色
        .foregroundColor: UIColor.darkGray, // カラー
        .strokeColor: UIColor.gray // 縁取りの色
    ]
    
    static let attributes2: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 12.0, weight: .heavy), // 文字色
        .foregroundColor: UIColor.darkGray, // カラー
        .strokeColor: UIColor.gray // 縁取りの色
    ]
    
    
}
