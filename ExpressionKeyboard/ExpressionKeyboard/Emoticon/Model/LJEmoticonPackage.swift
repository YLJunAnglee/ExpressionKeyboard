//
//  LJEmoticonPackage.swift
//  003-表情包管理
//
//  Created by 连俊杨 on 16/12/1.
//  Copyright © 2016年 yang_ljun. All rights reserved.
//

import UIKit
import YYModel

// 表情包模型
class LJEmoticonPackage: NSObject {
    
    // 表情包的分组名
    var groupName: String?
    
    // 背景图片位置
    var bgImageName: String?
    
    // 表情包目录，从目录下的info.plist中可以创建表情模型数组
    var directory: String? {
        didSet {
            // 当每次给表情包目录设置值时，我们可以用didSet方法，从目录下加载info.plist文件，字典转模型给‘懒加载的表情空数组’赋值
            guard let directory = directory,
                  let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
                  let bundle = Bundle(path: path),
                  let plistPath = bundle.path(forResource: "info.plist", ofType: nil, inDirectory: directory),
                  let packages = NSArray(contentsOfFile: plistPath) as? [[String: String]],
                  let models = NSArray.yy_modelArray(with: LJEmoticon.self, json: packages) as? [LJEmoticon] else {
                
                return
            }
            // 给每个表情模型赋值
            for m in models {
                
                m.directory = directory
            }
            
            // 设置表情模型数组
            emoticons += models
    
        }
    }
    
    // 懒加载的表情模型的空数组
    // 使用懒加载可以避免后续的解包
    lazy var emoticons = [LJEmoticon]()
    
    // 表情页面数量
    var numberOfPages: Int {
        
        return (emoticons.count - 1) / 20 + 1
    }
    
    // 从懒加载的表情包中，按照 page 截取最多 20 个表情模型的数组
    // 例如有 26 个表情
    // page == 0, 返回 0-19 个模型
    // page == 1, 返回 20-25 个模型
    func emoticon(page: Int) -> [LJEmoticon] {
        
        // 每页的数量
        let count = 20
        let location = page * count
        var length = count
        
        // 判断数组是否越界
        if location + length > emoticons.count {
            length = emoticons.count - location
        }
        
        let range = NSRange(location: location, length: length)
        
        // 截取数组的子数组
        let subArray = (emoticons as NSArray).subarray(with: range)
        
        return subArray as! [LJEmoticon]
    }
    
    
    override var description: String {
        
        return yy_modelDescription()
    }
}
