//
//  OrderTableViewController.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/3.
//

import UIKit

/// 訂單
class OrderTableViewController: UITableViewController {

    struct PropertyKeys {
        static let order = "Order"
        static let confirmOrder = "confirmOrder"
        static let dismissConfirmation = "DismissConfirmation"
    }
    
    /// 儲存從伺服器獲得的準備時間
    var minutesToPrepareOrder = 0
    
    /// 記錄每個圖片下載任務，，確保在 cell 重用時能正確取消未完成的下載。
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 啟用按鈕
        navigationItem.leftBarButtonItem = editButtonItem
        
        // 設定 NotificationCenter，收到 MenuController 發出的 orderUpdatedNotification 通知時，讓 tableView 調用 reloadData ，顯示最新的訂單項目。
        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdatedNotification, object: nil)
    }
    
    // 視圖消失時取消所有圖片下載任務
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageLoadTasks.forEach { _, task in
            task.cancel()
        }
    }
    
    /// 當 OrderTableViewController 出現在畫面上時，進行用戶活動更新。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 傳遞當前訂單到 MenuController 的共享實例，更新用戶活動。
        MenuController.shared.updateUserActivity(with: .order)
    }
    
    // 送出訂單
    @IBAction func submitTapped(_ sender: UIBarButtonItem) {
        // 計算訂單總金額
        let orderTotal = MenuController.shared.order.menuItems.reduce(0.0) { (result, menuItem) -> Double in
            return result + menuItem.price
        }
        
        // 格式化總金額顯示
        let formattedTotal = orderTotal.formatted(.currency(code: "usd"))
        
        // 彈出確認訂單的提示框
        let alertController = UIAlertController(title: "訂單的確認", message: "您即將提交的訂單總金額為\(formattedTotal)", preferredStyle: .actionSheet)
        // 確認送出
        alertController.addAction(UIAlertAction(title: "提交", style: .default, handler: { _ in
            self.uploadOrder()  // 呼叫上傳訂單方法
        }))
        // 取消送出
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    /// 上傳訂單方法
    func uploadOrder() {
        // 獲取訂單中餐點的id列表
        let menuIds = MenuController.shared.order.menuItems.map { $0.id }
        Task.init {
            do {
                // 呼叫API提交訂單並獲取「準備時間」
                let minutesToPrepare = try await MenuController.shared.submitOrder(forMenuIDs: menuIds)
                // 儲存準備時間
                minutesToPrepareOrder = minutesToPrepare
                // 跳轉到「訂單確認頁面」
                performSegue(withIdentifier: PropertyKeys.confirmOrder, sender: nil)
            } catch {
                // 出錯時顯示錯誤資訊
                displayError(error, title: "提交訂單失敗")
            }
        }
    }
    
    /// 顯示錯誤訊息
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "關閉", style: .default, handler: nil))
    }
    
    
    // 在Storyboard進行跳轉時，準備傳遞資料給確認畫面（OrderConfirmationViewController）。
    @IBSegueAction func confirmOrder(_ coder: NSCoder) -> OrderConfirmationViewController? {
        // 建立並返回「訂單確認視圖」控制器的實例，並傳遞「準備時間」。
        return OrderConfirmationViewController(coder: coder, minutesToPrepare: minutesToPrepareOrder)
    }
    
    // 從「訂單確認畫面」返回時觸發
    @IBAction func unwindToOrderList(_ unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == PropertyKeys.dismissConfirmation {
            MenuController.shared.order.menuItems.removeAll()
        }
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

    // 設定點餐項目的數量。
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuController.shared.order.menuItems.count  // (共享)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 刪除，從 MenuController 的共享實例中移除位於該 indexPath 的項目。
            MenuController.shared.order.menuItems.remove(at: indexPath.row)
        }
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.order, for: indexPath)
        
        configure(cell, forItemAt: indexPath)
        
        return cell
    }
    
    /// 配置cell顯示的內容，餐點名稱和價格。
    func configure(_ cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        // 嘗試將傳入的 UITableViewCell 轉換成 MenuItemCell
        guard let cell = cell as? MenuItemCell else { return }
        
        /// 獲取對應行數的餐點資訊。(共享)
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
        
        cell.itemName = menuItem.name
        cell.price = menuItem.price
        // 在圖片還未下載完成時，將單元格的圖片設為nil，這樣MenuItemCell會設定佔位圖片。
        cell.image = nil
        
        // 啟動異步任務下載圖片
        imageLoadTasks[indexPath] = Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                //  檢查 cell 位置是否有變，以確保圖片正確性
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexPath {
                    cell.image = image
                }
            }
            // 下載完成後移除任務記錄
            imageLoadTasks[indexPath] = nil
        }
    }

}
