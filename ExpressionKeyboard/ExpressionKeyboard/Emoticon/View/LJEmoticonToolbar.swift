//
//  LJEmoticonToolbar.swift
//  001-表情键盘
//
//  Created by 连俊杨 on 16/12/13.
//  Copyright © 2016年 yang_ljun. All rights reserved.
//

import UIKit

@objc protocol LJEmoticonToolbarDelegate: NSObjectProtocol {
    
    // 表情工具栏选中分组项索引
    // toolBar: 工具栏
    // index  : 索引
    func emoticonToolbarDidSelectedButtonIndex(toolBar: LJEmoticonToolbar, index: Int)
}

class LJEmoticonToolbar: UIView {
    
    // 选中分组索引
    var selectedIndex: Int = 0 {
        didSet {
            // 1. 取消所有按钮的选中状态
            for btn in subviews as! [UIButton] {
                btn.isSelected = false
            }
            // 2. 设置 index 对应的选中状态
            (subviews[selectedIndex] as! UIButton).isSelected = true
        }
    }
    
    // 代理
    weak var delegate: LJEmoticonToolbarDelegate?
    
    override func awakeFromNib() {
        
        setupUI()
    }
    
    
    // 设置按钮的位置
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let count = subviews.count
        let w = bounds.width / CGFloat(count)
        
        let rect = CGRect(x: 0, y: 0, width: w, height: bounds.height)
        
        for (i, button) in subviews.enumerated() {
            
            button.frame = rect.offsetBy(dx: CGFloat(i) * w, dy: 0)
        }
    }
    
    // MARK - 监听方法
    // 点击分组项按钮
    @objc func clickItem(button: UIButton) {
        
        // 通知代理执行协议方法
        delegate?.emoticonToolbarDidSelectedButtonIndex(toolBar: self, index: button.tag)
    }
    
}

extension LJEmoticonToolbar {
    
    func setupUI() {
        
        // 0, 获取表情管理系统单例
        let manager = LJEmoticonManager.shared
        
        // 1, 从表情包的分组名称 -> 设置按钮
        for (i, p) in manager.packages.enumerated() {
            
            // 1> 实例化按钮
            let button = UIButton()
            
            // 2> 设置按钮状态
            button.setTitle(p.groupName, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor.darkGray, for: .highlighted)
            button.setTitleColor(UIColor.darkGray, for: .selected)
            
            button.sizeToFit()
            
            // 3> 设置按钮的背景图片
            let imageName = "compose_emotion_table_\(p.bgImageName ?? "")_normal"
            let imageNameHL = "compose_emotion_table_\(p.bgImageName ?? "")_selected"
            
            var image = UIImage(named: imageName, in: manager.bundle, compatibleWith: nil)
            var imageHL = UIImage(named: imageNameHL, in: manager.bundle, compatibleWith: nil)
            
            // 拉伸图片
            let size = image?.size ?? CGSize()
            let inset = UIEdgeInsets(top: size.height * 0.5,
                                     left: size.width * 0.5,
                                     bottom: size.height * 0.5,
                                     right: size.width * 0.5)
            
            image = image?.resizableImage(withCapInsets: inset)
            imageHL = imageHL?.resizableImage(withCapInsets: inset)
            
            
            button.setBackgroundImage(image, for: .normal)
            button.setBackgroundImage(imageHL, for: .highlighted)
            button.setBackgroundImage(imageHL, for: .selected)
            
            
            // 3> 添加按钮
            addSubview(button)
            
            // 4> 添加tag
            button.tag = i
            
            // 5> 添加单击事件
            button.addTarget(self, action: #selector(clickItem), for: .touchUpInside)
        }
        
        // 默认选中第0组
        (subviews[0] as! UIButton).isSelected = true
    }
}


