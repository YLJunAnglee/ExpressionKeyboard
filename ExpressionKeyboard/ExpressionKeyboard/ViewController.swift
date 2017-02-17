//
//  ViewController.swift
//  ExpressionKeyboard
//
//  Created by 连俊杨 on 17/2/17.
//  Copyright © 2017年 yang_ljun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    lazy var emoticonView: LJEmoticonInputView = LJEmoticonInputView.inputView { [weak self] (em) in
        
        self?.insetEmoticon(em: em)
        
    }
    
    func insetEmoticon(em: LJEmoticon?) {
        
        // 1.删除按钮
        guard let em = em else {
            
            // 删除文本
            textView.deleteBackward()
            return
        }
        
        // 2.emoji字符串
        if let emoji = em.emoji, let textRange = textView.selectedTextRange {
            
            textView.replace(textRange, withText: emoji)
            return
        }
        
        // 3.图片文本
        let imageText = em.imageAttributeText(textFont: textView.font!)
        
        let attrStrM = NSMutableAttributedString(attributedString: textView.attributedText)
        
        
        attrStrM.replaceCharacters(in: textView.selectedRange, with: imageText)
        print("+++++\(attrStrM)")
        
        // 重新设置属性文本
        let range = textView.selectedRange
        
        textView.attributedText = attrStrM
        
        textView.selectedRange = NSRange(location: range.location + 1, length: 0)
    }
    
    var emoticonText: String {
        
        guard let attrStr = textView.attributedText else {
            
            return ""
        }
        
        var result = String()
        
        attrStr.enumerateAttributes(in: NSRange(location: 0, length: attrStr.length), options: [], using: { (dict, range, _) in
            
            if let attachment = dict["NSAttachment"] as? LJEmoticonAttachment {
                
                result += attachment.chs ?? ""
                
            }else {
                
                let subStr = (attrStr.string as NSString).substring(with: range)
                result += subStr
            }
        })
        
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.inputView = emoticonView
        
        textView.reloadInputViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
    
}

