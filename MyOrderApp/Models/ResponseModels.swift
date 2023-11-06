//
//  ResponseModels.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/3.
//

import Foundation

// /menu這個路徑會回傳一個包含MenuItem的items。
struct MenuResponse: Codable {
    let items: [MenuItem]
}

// /categories會回傳一組字串的categories。
struct CategoriesResponse: Codable {
    let categories: [String]
}

// /order會告訴我們準備食物要多久，回傳preparation_time。
struct OrderResponse: Codable {
    let prepTime: Int
    
    enum CodingKeys: String, CodingKey {
        case prepTime = "preparation_time"
    }
}
