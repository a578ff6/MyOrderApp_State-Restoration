//
//  MenuController.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/3.
//
    
import Foundation
import UIKit

// 用於處理所有菜單的網路請求。
class MenuController {
    
    /// 靜態屬性 shared，初始化為 MenuController 類別的一個新實例。它屬於類別本身，而不是類別的某個實例。
    static let shared = MenuController()
    
    /// 定義訂單變化通知的名稱
    static let orderUpdatedNotification = Notification.Name("MenuController.orderUpdated")
    
    /// 用於 App狀態恢復的屬性，標示著與用戶點餐相關的活動類型。
    var userActivity = NSUserActivity(activityType: "com.example.OrderApp.order")
    
    /// 存放共享的點餐資訊。(方便跨控制器傳遞資料)
    var order = Order() {
        didSet {
            /// 每當訂單被修改，就通過 NotificationCenter 發送通知，告訴所有的觀察者訂單已經更新了。
            NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
            /// 更新用來記住狀態的 userActivity
            userActivity.order = order
        }
    }
    
    /// 所有的網路請求都使用這個URL為基礎
    let baseURL = URL(string: "http://localhost:8080/")!

    // 用於處理網路請求中可能遇到的各種錯誤情況。
    enum MenuControllerError: Error, LocalizedError {
        case categoriesNotFound
        case menuItemsNotFound
        case orderRequestFailed
        case imageDataMissing
    }
    
    /// 更新用戶活動資訊以支持狀態恢復。
    /// - Parameter controller: 代表 App 當前狀態的控制器Enum，用來設定對應的用戶活動屬性。
    func updateUserActivity(with controller: StateRestorationController) {
        switch controller {
        case .menu(category: let category):
            // 如果是在菜單分類，將所選的分類資訊儲存到用戶活動中。
            userActivity.menuCategory = category
        case .menuItemDetail(let menuItem):
            // 如果是在菜單項目詳情，將詳情資訊儲存到用戶活動中。
            userActivity.menuItem = menuItem
        case .order, .categories:
            // 如果是訂單頁面或菜單分類列表，不需要儲存特定資訊。
            break
        }
        
        // 設定當前控制器的識別碼到用戶活動中。
        userActivity.controllerIdentifier = controller.identifier
    }
    
    
    /// 向伺服器請求餐點分類資料
    func fetchCategories() async throws -> [String] {
        let categoriesURL = baseURL.appendingPathComponent("categories")
        let (data, response) = try await URLSession.shared.data(from: categoriesURL)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.categoriesNotFound
        }
        
        let decoder = JSONDecoder()
        let categoriesResponse = try decoder.decode(CategoriesResponse.self, from: data)
        
        return categoriesResponse.categories
    }
    
    /// 根據提供的餐點分類名稱，向伺服器請求該分類下的菜單項目資料
    func fetchMenuItems(forCategory categoryName: String) async throws -> [MenuItem] {
        // 構建菜單項目的URL，並包含分類查詢參數。
        let baseMenuURL = baseURL.appendingPathComponent("menu")
        var components = URLComponents(url: baseMenuURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        
        let menuURL = components.url!
        let (data, response) = try await URLSession.shared.data(from: menuURL)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.menuItemsNotFound
        }
        
        let decoder = JSONDecoder()
        let menuResponse = try decoder.decode(MenuResponse.self, from: data)
        
        return menuResponse.items
    }
    
    /// 表明返回的是準備訂單所需的時間（以分鐘計）。
    typealias MinutesToPrepare = Int
    /// 提交用戶訂單的菜單項目ID，返回預計的準備時間
    func submitOrder(forMenuIDs menuIDs: [Int]) async throws -> MinutesToPrepare {
        let orderURL = baseURL.appendingPathComponent("order")
        
        // 構建一個POST請求，設置httpMethod和HTTPHeader，指定內容類型為JSON。
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 把菜單ID列表轉換成JSON格式的數據，準備發送。
        let menuIdsDict = ["menuIds": menuIDs]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(menuIdsDict)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.orderRequestFailed
        }
        
        let decoder = JSONDecoder()
        let orderResponse = try decoder.decode(OrderResponse.self, from: data)
        
        return orderResponse.prepTime
    }
    
    /// 取得圖片
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.imageDataMissing
        }
        
        guard let image = UIImage(data: data) else {
            throw MenuControllerError.imageDataMissing
        }
        
        return image
    }
    
}
