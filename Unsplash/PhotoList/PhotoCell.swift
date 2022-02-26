//
//  PhotoCell.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/25.
//

import UIKit

class PhotoCell: UITableViewCell {
    
    static let identifier: String = "PhotoCell"
    
    func updateUI(with photo: Photo) {
        
        let height = UIScreen.main.bounds.width * (CGFloat(photo.height ?? 0) / CGFloat(photo.width ?? 1))
        
        self.photoImageView?.downloadedFrom(link: photo.urls.regular,
                                            size: CGSize(width: UIScreen.main.bounds.width,
                                                         height: height))
        self.userNameLabel?.text = photo.user.name
    }
    
    @IBOutlet private weak var photoImageView: UIImageView?
    @IBOutlet private weak var userNameLabel: UILabel?
}
