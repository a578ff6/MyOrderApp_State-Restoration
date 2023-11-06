//
//  MenuItemCell.swift
//  MyOrderApp
//
//  Created by 曹家瑋 on 2023/11/5.
//

import UIKit

class MenuItemCell: UITableViewCell {
    // 當「項目名稱」更新時，檢查舊值是否與新值不同，若不同則更新配置
    var itemName: String? = nil {
        didSet {
            if oldValue != itemName {
                setNeedsUpdateConfiguration()
            }
        }
    }
    // 當「價格」更新時，檢查舊值是否與新值不同，若不同則更新配置
    var price: Double? = nil {
        didSet {
            if oldValue != price {
                setNeedsUpdateConfiguration()
            }
        }
    }
    // 當「圖片」更新時，檢查舊值是否與新值不同，若不同則更新配置
    var image: UIImage? = nil {
        didSet {
            if oldValue != image {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    // 更新 cell 配置
    override func updateConfiguration(using state: UICellConfigurationState) {
        // 使用預設的內容配置並根據目前狀態更新它
        var content = defaultContentConfiguration().updated(for: state)
        content.text = itemName
        content.secondaryText = price?.formatted(.currency(code: "usd"))
        content.prefersSideBySideTextAndSecondaryText = true

        // 設定圖片並調整大小
        var imageProperties = content.imageProperties
        imageProperties.maximumSize = CGSize(width: 40, height: 40) // 設定圖片的最大尺寸
        imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40) // 為圖片保留布局空間
        content.imageProperties = imageProperties

        if let image = image {
            content.image = image
        } else {
            content.image = UIImage(systemName: "photo.fill.on.rectangle.fill")
        }

        self.contentConfiguration = content
    }
    
}


// MARK: - 官方提供的部分
/*
 // 更新 cell 配置
 override func updateConfiguration(using state: UICellConfigurationState) {
     // 使用預設的內容配置並根據目前狀態更新它
     var content = defaultContentConfiguration().updated(for: state)
     content.text = itemName
     content.secondaryText = price?.formatted(.currency(code: "usd"))
     content.prefersSideBySideTextAndSecondaryText = true
     
     if let image = image {
         content.image = image
     } else {
         content.image = UIImage(systemName: "photo.fill.on.rectangle.fill")
     }
     self.contentConfiguration = content
 }
 */
