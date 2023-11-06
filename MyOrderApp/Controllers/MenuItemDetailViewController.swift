//
//  MenuItemDetailViewController.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/3.
//

import UIKit

@MainActor
class MenuItemDetailViewController: UIViewController {

    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDetailLabel: UILabel!
    @IBOutlet weak var addToOrderButton: UIButton!
    
    /// 儲存從  MenuTableViewController 傳來的菜單項目資料
    let menuItem: MenuItem
    
    init?(coder: NSCoder, menuItem: MenuItem) {
        self.menuItem = menuItem
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 更新顯示內容
        updateUI()
    }
    
    /// 當 MenuItemDetailViewController 出現在畫面上時，進行用戶活動更新。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 傳遞當前菜單項目到 MenuController 的共享實例，更新用戶活動。
        MenuController.shared.updateUserActivity(with: .menuItemDetail(menuItem))
    }
    
    /// 更新顯示內容
    func updateUI() {
        itemNameLabel.text = menuItem.name
        itemPriceLabel.text = menuItem.price.formatted(.currency(code: "usd"))
        itemDetailLabel.text = menuItem.detailText
        
        // 異步任務
        Task.init {
            // 嘗試異步獲取圖片，如果成功，則將該圖片設置到圖片視圖中
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                menuItemImageView.image = image
            }
        }
    }
    
    // 添加商品
    @IBAction func addToOrderButtonTapped(_ sender: UIButton) {
        // 使用 UIViewPropertyAnimator 創建動畫
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.6) {
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
        // 加入一個動畫區塊，執行放大後恢復原狀的動畫
        animator.addAnimations({
            self.addToOrderButton.transform = .identity
        }, delayFactor: 0)
        animator.startAnimation()           // 啟動動畫
        
        // 將目前頁面的菜單品項加入到共享的訂單中。確保用戶在 App 的不同部分中看到的訂單資訊是一致的，
        MenuController.shared.order.menuItems.append(menuItem)
    }
    
}
    


/*
 // UIView.animate
 @IBAction func addToOrderButtonTapped(_ sender: UIButton) {
     // 彈簧動畫
     UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: [], animations: {
         self.addToOrderButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
         self.addToOrderButton.transform = .identity
     }, completion: nil)
     
 }
 */
