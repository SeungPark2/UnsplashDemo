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
        
        let imageHeight: CGFloat = self.frame.width * (CGFloat(photo.height ?? 1) / CGFloat(photo.width ?? 1))
        
        self.photoImageViewTop?.constant = (self.frame.height - imageHeight) / 2
        
        self.photoImageViewHeight?.constant = imageHeight
    }
    
    // MARK: -- awakeFromNib
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.scrollView?.setZoomScale(0,
                                      animated: false)
    }
    
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
    
    @IBOutlet private weak var photoImageViewLeading: NSLayoutConstraint?
    @IBOutlet private weak var photoImageViewTrailing: NSLayoutConstraint?
    
    @IBOutlet private weak var photoImageViewTop: NSLayoutConstraint?
}

// MARK: -- UIScrollViewDelegate

extension PhotoDetailCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return self.photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        guard let imageView = self.photoImageView else { return }
        
        let xOffset = max(0, (self.bounds.size.height - imageView.frame.height) / 2)
        self.photoImageViewTop?.constant = xOffset
    }
}
