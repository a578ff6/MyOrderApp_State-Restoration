//
//  MenuTableViewController.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/3.
//

import UIKit

// 菜單表格視圖控制器，用來展示特定分類的菜單項目
@MainActor
class MenuTableViewController: UITableViewController {

    struct PropertyKeys {
        static let menuItem = "MenuItem"
    }

    /// 記錄每個圖片下載任務，，確保在 cell 重用時能正確取消未完成的下載。
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    /// 存放菜單項目的資料
    var menuItems = [MenuItem]()
    /// MenuController的實例，用於處理菜單相關的數據操作。
    // let menuController = MenuController()
    
    /// 保存從 CategoryTableViewController 傳遞過來的分類名稱
    let category: String
    
    init?(coder: NSCoder, category: String) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 視圖加載後的設置
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = category.capitalized
        
        // 異步發起網路請求，取得菜單項目。
        Task.init {
            do {
                // Singleton Pattern
                let menuItems = try await MenuController.shared.fetchMenuItems(forCategory: category)
                updateUI(with: menuItems)
            } catch {
                displayError(error, title: "Failed to Fetch Menu Items for \(self.category)")
            }
        }

    }
    
    // 視圖消失時取消所有圖片下載任務
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageLoadTasks.forEach { _, task in
            task.cancel()
        }
        
    }
    
    /// 當 MenuTableViewController 出現在畫面上時，進行用戶活動更新。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 傳遞當前分類到 MenuController 的共享實例，更新用戶活動。
        MenuController.shared.updateUserActivity(with: .menu(category: category))
    }
    
    /// 使用獲取到的菜單項目更新用戶介面。
    func updateUI(with menuItems: [MenuItem]) {
        self.menuItems = menuItems
        self.tableView.reloadData()
    }

    /// 顯示錯誤訊息的方法
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "關閉", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // 當用戶選擇某個「菜單項目」後，準備跳轉到 MenuItemDetailViewController 。
    @IBSegueAction func showMenuItem(_ coder: NSCoder, sender: Any?) -> MenuItemDetailViewController? {
        
        // 獲取選中的菜單項目。
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        // 獲取對應的菜單項目數據。
        let menuItem = menuItems[indexPath.row]
        // 使用自定義的初始化器創建 MenuItemDetailViewController 實例，並傳遞coder和 menuItem
        return MenuItemDetailViewController(coder: coder, menuItem: menuItem)
    }
    
    // MARK: - Table view delegate
    
    // 當表格視圖停止顯示某個cell時取消對應的圖片下載任務
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageLoadTasks[indexPath]?.cancel()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.menuItem, for: indexPath)
        // 配置單元格
        configureCell(cell, forCategoryAt: indexPath)
        
        return cell
    }

    /// 配置單元格內容
    func configureCell(_ cell: UITableViewCell, forCategoryAt indexPath: IndexPath) {
        
        // 嘗試將傳入的 UITableViewCell 轉換成 MenuItemCell
        guard let cell = cell as? MenuItemCell else { return }
        // 獲取對應索引的菜單項目
        let menuItem = menuItems[indexPath.row]
        
        cell.itemName = menuItem.name
        cell.price = menuItem.price
        // 在圖片還未下載完成時，將單元格的圖片設為nil，這樣MenuItemCell會設定佔位圖片。
        cell.image = nil
        
        // 啟動異步任務下載圖片
        imageLoadTasks[indexPath] = Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                //  檢查 cell 位置是否有變，以確保圖片正確性
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexPath {
                    cell.image = image   // 更新 cell 圖片
                }
            }
            // 下載完成後移除任務記錄
            imageLoadTasks[indexPath] = nil
        }
    }

}



// MARK: - 舊版寫法

/*
/// 配置單元格內容
func configureCell(_ cell: UITableViewCell, forCategoryAt indexPath: IndexPath) {
    // 獲取對應索引的菜單項目
    let menuItem = menuItems[indexPath.row]
    
    var content = cell.defaultContentConfiguration()
    // 設定菜單項目名稱和價格
    content.text = menuItem.name
    content.secondaryText = menuItem.price.formatted(.currency(code: "usd"))
    content.image = UIImage(systemName: "photo.fill.on.rectangle.fill")         // 設定佔位圖片
    cell.contentConfiguration = content
    
    // 啟動異步任務下載圖片
    imageLoadTasks[indexPath] = Task.init {
        if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
            //  檢查 cell 位置是否有變，以確保圖片正確性
            if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexPath {
                var content = cell.defaultContentConfiguration()
                content.text = menuItem.name
                content.secondaryText = menuItem.price.formatted(.currency(code: "usd"))
                content.image = image                                   // 更新 cell 圖片
                cell.contentConfiguration = content
            }
        }
        // 下載完成後移除任務記錄
        imageLoadTasks[indexPath] = nil
    }
}
*/
