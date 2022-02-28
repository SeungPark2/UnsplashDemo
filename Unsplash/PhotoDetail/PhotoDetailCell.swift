//
//  PhotoDetailCell.swift
//  Unsplash
//
//  Created by 박승태 on 2022/02/27.
//

import UIKit

class PhotoDetailCell: UICollectionViewCell {
    
    // MARK: -- Public Properties
    
    static let identifier: String = "PhotoDetailCell"
    
    // MARK: -- Public Method
    
    func updateUI(with photo: Photo) {
        
        self.photoImageView?.downloadedFrom(link: photo.urls.regular)
        
        self.photoImageViewHeight?.constant = self.frame.width *
                                              (CGFloat(photo.height!) / CGFloat(photo.width!))
    }
    
    // MARK: -- awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollView?.minimumZoomScale = 1
        self.scrollView?.maximumZoomScale = 4
    }
    
    // MARK: -- Private Method
    
    // MARK: -- Private Properties
    
    // MARK: -- IBOutlet
    
    @IBOutlet private weak var scrollView: UIScrollView?
    @IBOutlet private weak var photoImageView: UIImageView?
    
    @IBOutlet private weak var photoImageViewHeight: NSLayoutConstraint?
    @IBOutlet private weak var photoImageViewCenterY: NSLayoutConstraint?
}

// MARK: -- UIScrollViewDelegate

extension PhotoDetailCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return self.photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {

        scrollView.isScrollEnabled = scrollView.zoomScale == 1
        
        self.photoImageViewCenterY?.constant = -(5 * scrollView.zoomScale)
    }
}
