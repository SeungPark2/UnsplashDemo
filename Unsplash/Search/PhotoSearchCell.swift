//
//  PhotoSearchCell.swift
//  Unsplash
//
//  Created by 박승태 on 2022/02/27.
//

import UIKit

class PhotoSearchCell: UICollectionViewCell {
    
    // MARK: -- Public Properties
    
    static let identifier: String = "PhotoSearchCell"
    
    // MARK: -- Public Method
    
    func updateUI(with photo: Photo) {
        
        let height = (UIScreen.main.bounds.width / 2) *
                     (CGFloat(photo.height ?? 0) / CGFloat(photo.width ?? 1))
        
        self.photoImageView?.downloadedFrom(link: photo.urls.regular,
                                            size: CGSize(width: UIScreen.main.bounds.width / 2,
                                                         height: height))
        self.userNameLabel?.text = photo.user.name
    }
    
    // MARK: -- Private Method
    
    // MARK: -- Private Properties
    
    // MARK: -- IBOutlet
    
    @IBOutlet private weak var photoImageView: UIImageView?
    @IBOutlet private weak var userNameLabel: UILabel?
}
