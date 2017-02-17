//
//  LJEmoticonInputView.swift
//  001-表情键盘
//
//  Created by 连俊杨 on 16/12/13.
//  Copyright © 2016年 yang_ljun. All rights reserved.
//

import UIKit

// 可重用的标识符
private let cellID = "cellID"

// 表情输入视图
class LJEmoticonInputView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 底部工具栏
    @IBOutlet weak var toolbar: LJEmoticonToolbar!
    
    // 分页控件
    @IBOutlet weak var pageControl: UIPageControl!
    

    // 选中表情回调闭包 属性
    var selectedEmoticonCallBack: ((_ emoticon: LJEmoticon?)->())?
    
    // 加载并且返回视图
    class func inputView(selectedEmoticon: @escaping (_ emoticon: LJEmoticon?)->()) -> LJEmoticonInputView {
        
        let nib = UINib(nibName: "LJEmoticonInputView", bundle: nil)
        
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! LJEmoticonInputView
        
        // 记录闭包
        view.selectedEmoticonCallBack = selectedEmoticon
        
        return view
    }
    
    override func awakeFromNib() {
        
        collectionView.backgroundColor = UIColor.white
        
        // 注册纯代码的cell
        collectionView.register(LJEmoticonCell.self, forCellWithReuseIdentifier: cellID)
        
        // 设置代理
        toolbar.delegate = self
        
        // 设置pageControl的显示图像
        let bundle = LJEmoticonManager.shared.bundle
        guard let normalImage = UIImage(named: "compose_keyboard_dot_normal", in: bundle, compatibleWith: nil),
              let selectedImage = UIImage(named: "compose_keyboard_dot_selected", in: bundle, compatibleWith: nil) else {
               
                return
        }
/************************这种平铺的方法，使得图片比例不协调，不可用**********************
         
         // 使用填充颜色的方法
         pageControl.pageIndicatorTintColor = UIColor(patternImage: normalImage)
         pageControl.currentPageIndicatorTintColor = UIColor(patternImage: selectedImage)
         
****************************************************************************************/
       
        // 采用 KVC 方法，给pageControl的隐藏属性赋值
        pageControl.setValue(normalImage, forKey: "_pageImage")
        pageControl.setValue(selectedImage, forKey: "_currentPageImage")
    }
}

extension LJEmoticonInputView: LJEmoticonToolbarDelegate {
    
    func emoticonToolbarDidSelectedButtonIndex(toolBar: LJEmoticonToolbar, index: Int) {
        
        // 让 collectionView 发生滚动 -> 滚动到每一个分组的第0页
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        // 设置 toolbar 上按钮的选择状态
        toolBar.selectedIndex = index
    }
}

// CollectionViewDataSource 数据源代理方法
extension LJEmoticonInputView: UICollectionViewDataSource {
    
    // 分组数量 - 返回表情包的数量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return LJEmoticonManager.shared.packages.count
    }
    
    // 每组中item的数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return LJEmoticonManager.shared.packages[section].numberOfPages
    }
    
    // 返回每个item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 1, 取cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! LJEmoticonCell
        
        // 2, 设置cell
        cell.emoticons = LJEmoticonManager.shared.packages[indexPath.section].emoticon(page: indexPath.row)
        
        // 3, 设置代理
        cell.delegate = self
        
        // 4, 返回cell
        return cell
    }
}

// MARK - UICollectionViewDelegate
extension LJEmoticonInputView: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 1.获取中心点
        var center = scrollView.center
        center.x += scrollView.contentOffset.x
        
        // 2.获取当前显示的 cell 的indexPath
        let paths = collectionView.indexPathsForVisibleItems
        
        // 3.判断中心点在哪一个 indexpath 上，也就是在哪一个页面上
        var targetIndexPath: IndexPath?
        for indexPath in paths {
            
            // 4. 根据 indexPath 获得cell
            let cell = collectionView.cellForItem(at: indexPath)
            
            // 5. 判断中心点位置
            if cell?.frame.contains(center) == true {
                
                targetIndexPath = indexPath
                break
            }
        }
        
        // 6. 这里处理逻辑
        // 记录下来的indexPath.section 就是分组
        guard let target = targetIndexPath else {
            return
        }
        toolbar.selectedIndex = target.section
        
        // 7. 设置分页控件
        // a> 总页数，不同的分组，页数不一样
        pageControl.numberOfPages = collectionView.numberOfItems(inSection: target.section)
        pageControl.currentPage = target.item
    }
}

extension LJEmoticonInputView: LJEmoticonCellDelegate {
    
    // 选中的表情回调
    // cell：分页 cell
    // em: 选中的表情，删除键为nil
    func emoticonCellDidSelectedEmoticon(cell: LJEmoticonCell, em: LJEmoticon?) {
        
        // 闭包回调
        selectedEmoticonCallBack?(em)
        
        
        let indexPath = collectionView.indexPathsForVisibleItems[0]
        if indexPath.section == 0 {
            
            return  // 第0组不参与刷新
        }
        
        // 添加最近使用的表情
        guard let em = em else {
            return
        }
        LJEmoticonManager.shared.recentEmoticon(em: em) 
        
        // 刷新数据 - 第 0 组
        var indexSet = IndexSet()
        indexSet.insert(0)
        
        collectionView.reloadSections(indexSet)
    }
}


