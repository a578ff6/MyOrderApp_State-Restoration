//
//  Restoration.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/6.
//

import Foundation

/// 專門處理狀態恢復的細節
/// 為 NSUserActivity 添加了一個名為 `order` 的自定義屬性，用來儲存和恢復使用者的訂單狀態。
extension NSUserActivity {
    
    /// 讓 NSUserActivity 可以直接存取 Order型別 的屬性。
    /// 利用 userInfo字典 的 “order”鍵 來儲存和取得Order的JSON資料。
    var order: Order? {
        get {
            /// 檢查 userInfo 字典中是否含有 key 為 "order" 的資料。
            guard let jsonData = userInfo?["order"] as? Data else {
                return nil
            }
            /// 嘗試解碼 JSON 資料為 Order 型別。如果解碼失敗，返回 nil。
            return try? JSONDecoder().decode(Order.self, from: jsonData)
        }
        set {
            /// 首先檢查新的值是否存在。如果存在，則嘗試將 Order 實例編碼為 JSON Data。
            if let newValue = newValue,
               let jsonData = try? JSONEncoder().encode(newValue) {
                /// 如果編碼成功，將這個 JSON Data 存入 userInfo 字典中，key 仍為 "order"。
                addUserInfoEntries(from: ["order": jsonData])
            } else {
                /// 若編碼失敗或newValue為nil，則將userInfo中的“order”設為nil。
                userInfo?["order"] = nil
            }
        }
    }
    
    /// 存取控制器 Id
    var controllerIdentifier: StateRestorationController.Identifier? {
        get {
            /// 嘗試從 userInfo 字典中讀取鍵為 "controllerIdentifier" 的值，並轉換成對應的Enum型別。
            if let controllerIdentifierString = userInfo?["controllerIdentifier"] as? String {
                return StateRestorationController.Identifier(rawValue: controllerIdentifierString)
            } else {
                return nil
            }
        }
        set {
            /// 將新的識別碼值（如果有的話）儲存為一個字串至 userInfo 字典中。
            userInfo?["controllerIdentifier"] = newValue?.rawValue
        }
    }
    
    /// 存取菜單分類。
    var menuCategory: String? {
        get {
            /// 從 userInfo 字典中直接讀取鍵為 "menuCategory" 的字串值。
            return userInfo?["menuCategory"] as? String
        }
        set {
            /// 將新的菜單分類（如果有的話）儲存至 userInfo 字典中。
            userInfo?["menuCategory"] = newValue
        }
    }
    
    /// 存取菜單項目。
    var menuItem: MenuItem? {
        get {
            /// 檢查 userInfo 字典中是否包含鍵為 "menuItem" 的資料。
            guard let jsonData = userInfo?["menuItem"] as? Data else {
                return nil
            }
            /// 嘗試將 JSON 資料解碼為 MenuItem 型別。若解碼失敗，則回傳 nil。
            return try? JSONDecoder().decode(MenuItem.self, from: jsonData)
        }
        set {
            /// 首先確認新的值是否存在。如存在，嘗試將 MenuItem 實例編碼成 JSON Data。
            if let newValue = newValue,
                let jsonData = try? JSONEncoder().encode(newValue) {
                /// 若編碼成功，則將這份 JSON Data 儲存至 userInfo 字典中，鍵值為 "menuItem"。
                addUserInfoEntries(from: ["menuItem": jsonData])
            } else {
                /// 若編碼失敗或 newValue 為 nil，則將 userInfo 中的 "menuItem" 項目設置為 nil。
                userInfo?["menuItem"] = nil
            }
        }
    }
    
}

/// 用於表示 App 的不同狀態。
enum StateRestorationController {
    case categories
    case menu(category: String)
    case menuItemDetail(MenuItem)
    case order
    
    /// 識別不同狀態的 id 。
    enum Identifier: String {
        case categories, menu, menuItemDetail, order
    }
    
    /// 根據當前狀態返回對應的 id。
    var identifier: Identifier {
        switch self {
        case .categories:
            return Identifier.categories
        case .menu(category: let category):
            return Identifier.menu
        case .menuItemDetail(_):
            return Identifier.menuItemDetail
        case .order:
            return Identifier.order
        }
    }
    
    /// 使用 NSUserActivity 初始化Enum。如果 userActivity 包含有效 controllerIdentifier，則進行匹配並初始化對應的狀態。
    init?(userActivity: NSUserActivity) {
        guard let identifier = userActivity.controllerIdentifier else {
            return nil
        }
        
        // 根據 identifier 初始化對應的狀態
        switch identifier {
        case .categories:
            self = .categories
        case .menu:
            // 如果從 userActivity 獲取到 category 資訊，則初始化 menu 狀態。
            if let category = userActivity.menuCategory {
                self = .menu(category: category)
            } else {
                return nil
            }
        case .menuItemDetail:
            // 如果從 userActivity 獲取到 menuItem 資訊，則初始化 menuItemDetail 狀態。
            if let menuItem = userActivity.menuItem {
                self = .menuItemDetail(menuItem)
            } else {
                return nil
            }
        case .order:
            self = .order
        }
        
    }
}
