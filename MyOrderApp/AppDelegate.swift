//
//  AppDelegate.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/3.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // 當 App 啟動完成後會被呼叫
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 取得系統的臨時目錄路徑
        let temporaryDirectory = NSTemporaryDirectory()
        // 建立一個新的 URLCache ，設定記憶體容量為25MB，硬碟容量為50MB，並指定緩存路徑為臨時目錄
        let urlCache = URLCache(memoryCapacity: 25_000_000, diskCapacity: 50_000_000, diskPath: temporaryDirectory)
        // 設定剛剛建立的urlCache為共享緩存
        URLCache.shared = urlCache
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

