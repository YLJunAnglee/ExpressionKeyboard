//
//  LJEmoticonCell.swift
//  001-表情键盘
//
//  Created by 连俊杨 on 16/12/13.
//  Copyright © 2016年 yang_ljun. All rights reserved.
//

import UIKit

// 表情 cell 的协议方法
@objc protocol LJEmoticonCellDelegate: NSObjectProtocol {
    
    // 表情 cell 选中表情模型
    // - cell: 本身cell
    // - em  : 表情模型
    func emoticonCellDidSelectedEmoticon(cell: LJEmoticonCell, em: LJEmoticon?)
}

// 表情的页面cell
// - 每一个 cell 就是和 collectionView 一样大小
// - 每一个 cell 中用九宫格的算法，自行添加 20 个表情
// - 最后一个位置放置删除按钮
class LJEmoticonCell: UICollectionViewCell {
    
    // 定义代理
    weak var delegate: LJEmoticonCellDelegate?
    
    // 当前页面的表情模型数组，'最多' 20 个
    var emoticons: [LJEmoticon]? {
        didSet {
            
            // 1, 隐藏所有的按钮
            for v in contentView.subviews {
                v.isHidden = true
            }
            
            // 显示删除按钮
            contentView.subviews.last?.isHidden = false
            
            // 2, 遍历表情模型数组，设置按钮图像，显示
            for (i, em) in (emoticons ?? []).enumerated() {
                
                if let button = contentView.subviews[i] as? UIButton {
                    
                    // 设置图像
                    button.setImage(em.image, for: .normal)
                    
                    // 设置 emoji 的字符串
                    button.setTitle(em.emoji, for: .normal)
                    
                    button.isHidden = false
                }
            }
        }
    }
    
    // 表情选择提示视图
    private lazy var tipView = LJEmoticonTipView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 当视图从界面上删除，同样会调用此方法，newWindow == nil
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        guard let w = newWindow else {
            return
        }
        
        // 将提示视图添加到窗口上
        // 提示：在 iOS 6.0 之前，很多程序员都喜欢把控件往窗口上添加
        // 在现在开发，如果有地方，就不要用窗口
        
        w.addSubview(tipView)
        tipView.isHidden = true
    }
    
    // MARK: - 监听方法
    // 选中表情按钮
    @objc func selectedEmoticonButton(button: UIButton) {
       
        // 1, 取 tag 0 - 20， 当值为20时，对应的是删除按钮
        let tag = button.tag
        
        // 2, 根据tag判断是否是删除按钮，如果不是，取出对应的表情
        var em: LJEmoticon?
        if tag < (emoticons?.count ?? 0) {
            em = emoticons?[tag]
        }
        
        // 3, em 如果为nil，就是删除按钮
        delegate?.emoticonCellDidSelectedEmoticon(cell: self, em: em)
    }
    
    // 长按手势识别 - 是一个非常重要的手势
    // 可以保证一个对象监听两种点击手势，而且不需要考虑手势冲突
    @objc func longGesture(ges: UILongPressGestureRecognizer) {
      
        // 1. 获取触摸位置
        let location = ges.location(in: self)
        
        // 2. 获取触摸位置对应的按钮
        guard let button = buttonWithLocation(location: location) else {
            
            tipView.isHidden = true
            return
        }
        
        // 3. 处理手势状态
        switch ges.state {
        case .began, .changed:
            tipView.isHidden = false
            
            // 坐标系的转换 -> 将按钮参照 cell 的坐标系，转换到 window 的坐标位置
            let changeCenter = self.convert(button.center, to: window)
            
            // 设置提示视图的位置
            tipView.center = changeCenter
            
            // 设置提示视图的表情模型
            guard let count = emoticons?.count else {
                break
            }
            if button.tag < count {
                tipView.emoticon = emoticons?[button.tag]
            }
            
        case .ended:
            tipView.isHidden = true
            
            // 执行选中按钮的函数
            selectedEmoticonButton(button: button)
        
        case .cancelled, .failed:
            tipView.isHidden = true
            
        default:
            break
        }
    }
    
    private func buttonWithLocation(location: CGPoint) -> UIButton? {
        
        // 遍历 contentView 的所有的子视图，如果可见，同时在location范围内，确认是按钮
        for btn in contentView.subviews as! [UIButton] {
            
            if btn.frame.contains(location) && !btn.isHidden && btn != contentView.subviews.last{
                return btn
            }
        }
        return nil
    }
}

extension LJEmoticonCell {
    
    func setupUI() {
        
        let rowCount = 3
        let colCount = 7
        
        // 准备常数
        let leftMargin: CGFloat = 8     // 左右间距
        let bottomMargin: CGFloat = 16  // 底部间距，为分页控件预留空间
        
        let w = (bounds.width - 2 * leftMargin) / CGFloat(colCount)
        let h = (bounds.height - bottomMargin) / CGFloat(rowCount)
        
        // 连续创建21个按钮
        for i in 0..<21 {
            
            let row = i / colCount
            let col = i % colCount
            
            let button = UIButton()
            
            // 设置按钮的frame
            let x = leftMargin + CGFloat(col) * w
            let y = CGFloat(row) * h
            
            button.frame = CGRect(x: x, y: y, width: w, height: h)
            
            // 设置title的大小
            button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
            
            contentView.addSubview(button)
            
            // 添加tag值 和 监听方法
            button.tag = i
            
            button.addTarget(self, action: #selector(selectedEmoticonButton), for: .touchUpInside)
        }
        
        // 创建删除按钮
        let removeButton = contentView.subviews.last as! UIButton
        
        let image = UIImage(named: "compose_emotion_delete_highlighted", in: LJEmoticonManager.shared.bundle, compatibleWith: nil)
        removeButton.setImage(image, for: .normal)
        
        // 添加长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longGesture))
        longPress.minimumPressDuration = 0.2
        
        addGestureRecognizer(longPress)
    }
}




