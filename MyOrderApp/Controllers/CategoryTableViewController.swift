//
//  CategoryTableViewController.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/3.
//

import UIKit

@MainActor
class CategoryTableViewController: UITableViewController {

    struct PropertyKeys {
        static let category = "Category"
    }
    
    /// MenuController的實例，用於處理菜單相關的數據操作。
    // let menuController = MenuController()
    /// 用來儲存菜單的分類。
    var categories = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 異步任務
        Task.init {
            do {
                // 嘗試從 menuController 獲取分類的資料。(使用 Singleton Pattern )
                let categories = try await MenuController.shared.fetchCategories()
                updateUI(with: categories)
            } catch {
                displayError(error, title: "Failed to Fetch Categories")
            }
        }
    }
    
    /// 當 CategoryTableViewController 出現在畫面上時，進行用戶活動更新。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 呼叫 MenuController 的共享實例，使用「categories」狀態更新用戶活動。
        MenuController.shared.updateUserActivity(with: .categories)
    }
    
    /// 使用取得的分類資料來更新用戶介面。
    func updateUI(with categories: [String]) {
        // 將取得的分類資料賦值給本地變數。
        self.categories = categories
        self.tableView.reloadData()
    }
    
    /// 顯示錯誤訊息的方法
    func displayError(_ error: Error, title: String) {
        // 確保視圖已經載入且存在於視窗中
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "關閉", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    // 當一個分類被選中，並且將要進行跳轉時調用
    @IBSegueAction func showMenu(_ coder: NSCoder, sender: Any?) -> MenuTableViewController? {
        // 判斷觸發跳轉的發送者是否為UITableViewCell
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        
        // 根據被選中的單元格的位置，取出對應的分類名稱
        let category = categories[indexPath.row]
        // 使用自定義的初始化器創建 MenuTableViewController 實例，並傳遞coder和分類名稱
        return MenuTableViewController(coder: coder, category: category)
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    // 配置並返回每個行的單元格。
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.category, for: indexPath)
        // 設定單元格的內容。
        configureCell(cell, forCategoryAt: indexPath)
        
        return cell
    }
    
    /// 設定特定行的單元格內容。
    func configureCell(_ cell: UITableViewCell, forCategoryAt indexPath: IndexPath) {
        // 獲取該行對應的分類名稱。
        let category = categories[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = category.capitalized
        cell.contentConfiguration = content
    }

}
