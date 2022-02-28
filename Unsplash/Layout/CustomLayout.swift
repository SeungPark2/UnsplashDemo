//
//  CustomLayoutDelegate.swift
//  Unsplash
//
//  Created by 박승태 on 2022/02/28.
//

import UIKit

protocol CustomLayoutDelegate: AnyObject {
    
    func collectionView(collectionVIew: UICollectionView,
                        heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
}

class CustomLayout: UICollectionViewLayout {
    
    weak var delegate: CustomLayoutDelegate?
    var numberOfColums: Int = 1
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var width: CGFloat {
        
        get { return collectionView?.bounds.width ?? 0 }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: contentHeight)
    }
    
    override func prepare() {
        
        guard collectionView != nil else { return }
                    
        let columWidth = width / CGFloat(numberOfColums)
        
        var xOffsets = [CGFloat]()
        
        for colum in 0..<numberOfColums {
            
            xOffsets.append(CGFloat(colum) * columWidth)
        }
        
        var yOffset = [CGFloat](repeating: 0, count: numberOfColums)
        
        var column = 0
        
        for item in 0..<collectionView!.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            if cache.contains(where: { $0 == attributes }) { continue }
            
            let height = delegate?.collectionView(
                            collectionVIew: collectionView!,
                            heightForItemAtIndexPath: indexPath
                         ) ?? 0
            let frame = CGRect(x: xOffsets[column],
                               y: yOffset[column],
                               width: columWidth,
                               height: height)
            
            attributes.frame = frame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            column = column >= (numberOfColums - 1) ? 0 : column + 1
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attribute in cache {
            
            if attribute.frame.intersects(rect) {
                
                layoutAttributes.append(attribute)
            }
        }
        
        return layoutAttributes
    }
}
