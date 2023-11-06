//
//  Order.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/3.
//

import Foundation

/// 代表用戶訂單的結構，可以包含多個菜單項目。
struct Order: Codable {
    // 用來存放多個菜單項目的陣列
    var menuItems: [MenuItem]
    
    // 初始化方法，允許創建一個訂單時可選地傳入一組菜單項目。
    // 如果創建時沒有提供菜單項目，則會以空陣列進行初始化。
    init(menuItems: [MenuItem] = []) {
        self.menuItems = menuItems
    }
}


