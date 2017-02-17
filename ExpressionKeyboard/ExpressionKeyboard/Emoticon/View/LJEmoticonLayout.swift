//
//  LJEmoticonLayout.swift
//  001-表情键盘
//
//  Created by 连俊杨 on 16/12/13.
//  Copyright © 2016年 yang_ljun. All rights reserved.
//

import UIKit

// 表情集合视图的布局
class LJEmoticonLayout: UICollectionViewFlowLayout {
    
    // prepare 就是 OC 中的 prepareLayout
    override func prepare() {
        super.prepare()
        
        // 在此方法中，collectionView的大小已经确定
        guard let collectionView = collectionView else {
            
            return
        }
        itemSize = collectionView.bounds.size
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
        // 设定滚动方向
        // 水平方向滚动，cell 垂直方向布局
        // 垂直方向滚动，cell 水平方向布局
        scrollDirection = .horizontal
    }
}
