//
//  SceneDelegate.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/3.
//

import UIKit

// 主要的場景代理(SceneDelegate)類別，負責處理窗口場景的生命週期事件。
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    // orderTabBarItem 的參照，用於更新 badge。
    var orderTabBarItem: UITabBarItem!
    
    // 當場景與 App 連接時，這個方法會被呼叫。
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 確保場景是一個窗口場景。
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // 註冊觀察者，以便在訂單更新時收到通知。
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrderBadge), name: MenuController.orderUpdatedNotification, object: nil)
        
        // 初始化orderTabBarItem，指向 TabBarController 中的第二個視圖控制器的頁籤（也就是訂單）。
        orderTabBarItem = (window?.rootViewController as? UITabBarController)?.viewControllers?[1].tabBarItem
    }
    
    // 負責提供一個 NSUserActivity，當 App 的場景需要保存狀態時會用到。
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return MenuController.shared.userActivity
    }
    
    // 當 App 的場景從之前保存的狀態中恢復時，會呼叫這個方法。
    func scene(_ scene: UIScene, restoreInteractionStateWith stateRestorationActivity: NSUserActivity) {
        // 檢查從 NSUserActivity 中是否有保存的訂單，如果有的話，就設定給 MenuController 的 order 屬性。
        if let restoreOrder = stateRestorationActivity.order {
            MenuController.shared.order = restoreOrder
        }
        
        // 使用 guard 確認一系列條件，當所有條件都滿足時才繼續執行。
        guard
            let restorationController = StateRestorationController(userActivity: stateRestorationActivity),
            let tabBarController = window?.rootViewController as? UITabBarController,
            tabBarController.viewControllers?.count == 2,
            let categoryTableViewController = (tabBarController.viewControllers?[0] as? UINavigationController)?.topViewController as? CategoryTableViewController
        else {
            return
        }
        
        // 根據 UIStoryboard 取得對應的 ViewController，進行場景恢復的操作。
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch restorationController {
        case .categories:
            // 如果是 categories 狀態，目前不需進行任何操作。
            break
            
        case .menu(let category):
            // 如果是 menu 狀態，則找到對應的 MenuTableViewController 並推入導航堆疊（navigation stack）。
            let menuTableViewController = storyboard.instantiateViewController(identifier: restorationController.identifier.rawValue, creator: { (coder) in
                return MenuTableViewController(coder: coder, category: category)
            })
            categoryTableViewController.navigationController?.pushViewController(menuTableViewController, animated: true)
            
        case .menuItemDetail(let menuItem):
            // 如果是 menuItemDetail 狀態，則先找到 MenuTableViewController 再找到 MenuItemDetailViewController，並依序推入導航堆疊（navigation stack）。
            let menuTableViewController = storyboard.instantiateViewController(identifier: StateRestorationController.Identifier.menu.rawValue, creator: { (coder) in
                return MenuTableViewController(coder: coder, category: menuItem.category)
            })
            let menuItemDetailViewController = storyboard.instantiateViewController(identifier: restorationController.identifier.rawValue, creator: { (coder) in
                return MenuItemDetailViewController(coder: coder, menuItem: menuItem)
            })
            
            categoryTableViewController.navigationController?.pushViewController(menuTableViewController, animated: false)
            categoryTableViewController.navigationController?.pushViewController(menuItemDetailViewController, animated: false)
            
        case .order:
            // 如果是 order 狀態，則切換到訂單的 Tab。
            tabBarController.selectedIndex = 1
        }
        
    }
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // 更新訂單badge的方法
    @objc func updateOrderBadge() {
        // 設定 badgeValue 為訂單中項目的數量。當當計數為 0 時，將 badge 值設為nil）
        switch MenuController.shared.order.menuItems.count {
        case 0:
            orderTabBarItem.badgeValue = nil
        case let count:
            orderTabBarItem.badgeValue = String(count)
        }
    }

}

