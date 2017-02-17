//
//  LJEmoticonManager.swift
//  003-表情包管理
//
//  Created by 连俊杨 on 16/12/1.
//  Copyright © 2016年 yang_ljun. All rights reserved.
//

import UIKit

// 表情管理器
class LJEmoticonManager {
    // 为了便于表情的复用，需要建立单例
    // 表情管理器的单例
    static let shared = LJEmoticonManager()
    
    // 表情包的懒加载数组 - 第一个数组是最近表情，加载之后，表情数组为空
    lazy var packages = [LJEmoticonPackage]()
    
    // 表情素材的 bundle
    lazy var bundle: Bundle = {
        
        let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil)
        // 创建bundle的路径
        return Bundle(path: path!)!
    }()
    
    // 锁住单例, 把构造函数锁住
    private init() {
        
        loadPackages()
    }
    
    // 增加最近使用的表情
    // em: 选中的表情
    func recentEmoticon(em: LJEmoticon) {
        
        // 1. 增加表情的使用次数
        em.times += 1
        
        // 2. 判断是否已经记录了该表情，如果没有记录，就添加记录
        if !packages[0].emoticons.contains(em) {
            
            packages[0].emoticons.append(em)
        }
        
        // 3. 根据使用次数排序，使用次数越高的排序靠前
        // 对当前数组排序
/**********************************下面闭包的简写***************************************
         
         packages[0].emoticons.sort { $0.times > $1.times}
***************************************************************************************/
        packages[0].emoticons.sort { (em1, em2) -> Bool in
            
            return em1.times > em2.times    // 降序排
        }
        
        // 4. 判断表情数组是否超出 20，如果超出，删除末尾的表情
        if packages[0].emoticons.count > 20 {
            packages[0].emoticons.removeSubrange(20..<packages[0].emoticons.count)
        }
    }
    
}

// MARK: - 表情包数据处理
extension LJEmoticonManager {
    
    func loadPackages() {
        
        // 读取 emoticons.plist
        // 只有按照 Bundle 默认的目录结构设定，就可以直接读取 Resources 目录下的文件
        guard let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
            // 创建bundle的路径
              let bundle = Bundle(path: path),
            // 加载bundle下文件的路径
              let plistPath = bundle.path(forResource: "emoticons.plist", ofType: nil),
            // 根据路径下的文件，加载文件数组
              let array = NSArray(contentsOfFile: plistPath) as? [[String: String]],
            // 用YYModel给文件数组转换成模型数组
              let models = NSArray.yy_modelArray(with: LJEmoticonPackage.self, json: array) as? [LJEmoticonPackage] else {
            
            return
        }
        // 给单例类的表情包数组添加内容
        // 使用 += 不需要再次给 packages 分配空间，直接追加数据
        packages += models

    }
}

// 表情符号处理
extension LJEmoticonManager {
    // 根据 string '[爱你]'，在所有的表情符号中查找对应的表情符号对象
    // 如果找到，返回表情符号对象；如果没有，返回nil
    func findEmoticon(chsStr: String) -> LJEmoticon? {
        
        // 遍历表情包数组
        // OC 中过滤数组使用 [谓词]
        // Swift 中 也是如此，但是更简单
        for p in packages {
            
            // 在表情数组中过滤字符串
            let result = p.emoticons.filter({ (em) -> Bool in
                
                return em.chs == chsStr
            })
            
            // 判断结果数组的个数
            if result.count == 1 {
                
                return result[0]
            }
        }
        
        return nil
    }
    
    // 将给定的字符串转换成属性文本
    // 关键点：按照匹配结果倒序替换
    
    // string: 要转换的完整的字符串
    // return: 转换后的属性文本
    func emoticonString(string: String, textFont: UIFont) -> NSAttributedString {
        
        // NSAttributedString 是不可变的，替换需要可变的
        let attrString = NSMutableAttributedString(string: string)
        // 1,建立正则表达式，过滤所有的表情文字
        // [] () 都是正则表达式的关键字，结果要参与匹配，需要转义
        let pattern = "\\[.*?\\]"
        
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else {
            
            return attrString
        }
        
        // 2,匹配所有项
        let matches = regx.matches(in: string, options: [], range: NSRange(location: 0, length: attrString.length))
        
        // 3,遍历所有的匹配结果
        for matche in matches.reversed() {
            
            let range = matche.rangeAt(0)
            let subStr = (attrString.string as NSString).substring(with: range)
            
            print(subStr)
            // 4,用对应的图片文本 替换掉 当前的字体文本
            // 关键点：需要倒序遍历
            // 如果是正序遍历，替换掉之后，会影响后面的查找；但是倒序替换之后，不会影响前面的
            
            // a> 使用subStr查找对应的属性模型
            if let em = LJEmoticonManager.shared.findEmoticon(chsStr: subStr) {
                
                // b> 替换
                attrString.replaceCharacters(in: range, with: em.imageAttributeText(textFont: textFont))
            }
            
        }
        
        // 统一设置一遍字符串的属性
        attrString.addAttributes([NSFontAttributeName: textFont,
                                  NSForegroundColorAttributeName: UIColor.darkGray],
                                 range: NSRange(location: 0, length: attrString.length))
        return attrString
    }
    
}

