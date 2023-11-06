//
//  OrderConfirmationViewController.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/5.
//

import UIKit

/// 訂單確認視圖
class OrderConfirmationViewController: UIViewController {

    @IBOutlet weak var confirmationLabel: UILabel!
    
    /// 餐點所需的準備時間。
    let minutesToPrepare: Int
    // 自定義初始化器，接收準備時間。
    init?(coder: NSCoder,minutesToPrepare: Int) {
        self.minutesToPrepare = minutesToPrepare
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 顯示訂單時間資訊
        confirmationLabel.text = "感謝您的訂購！您的等待時間大約是 \(minutesToPrepare) 分鐘。"
    }
    
}
