//
//  MenuItem.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/3.
//

import Foundation

// 解析從API獲取的菜單列表的模型
struct MenuItems: Codable {
    var items: [MenuItem]
}

// 菜單項目的細節
struct MenuItem: Codable {
    var id: Int
    var name: String
    var detailText: String
    var price: Double
    var category: String
    var imageURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case detailText = "description"     // 因為"description"在Swift中很常見，改用detailText來避免混淆
        case price
        case category
        case imageURL = "image_url"         // JSON中的"image_url"對應到Swift的imageURL
    }
}
