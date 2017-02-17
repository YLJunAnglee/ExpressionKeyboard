//
//  LJEmoticonTipView.swift
//  WeiBo
//
//  Created by 连俊杨 on 16/12/16.
//  Copyright © 2016年 yang_ljun. All rights reserved.
//

import UIKit
import pop

class LJEmoticonTipView: UIImageView {
    
    // 之前选择的表情
    private var preEmoticon: LJEmoticon?
    
    // 提示视图的表情模型
    var emoticon: LJEmoticon? {
        didSet {
            // 判断表情是否有变化
            if emoticon == preEmoticon {
                return
            }
            // 记录当前的表情
            preEmoticon = emoticon
            
            // 设置表情模型
            tipButton.setTitle(emoticon?.emoji, for: .normal)
            tipButton.setImage(emoticon?.image, for: .normal)
            
            // 表情的动画
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            
            anim.fromValue = 30
            anim.toValue = 8
            
            anim.springBounciness = 20
            anim.springSpeed = 20
            
            tipButton.layer.pop_add(anim, forKey: nil)
        }
    }

    // 提示按钮的内部视图
    private lazy var tipButton = UIButton()
    
    init() {
        
        let bundle = LJEmoticonManager.shared.bundle
        let image = UIImage(named: "emoticon_keyboard_magnifier", in: bundle, compatibleWith: nil)
        
        super.init(image: image)
        
        // 设置锚点
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.2)
   
        // 添加按钮
        tipButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        tipButton.frame = CGRect(x: 0, y: 8, width: 36, height: 36)
        tipButton.center.x = bounds.width * 0.5

        tipButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        addSubview(tipButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
