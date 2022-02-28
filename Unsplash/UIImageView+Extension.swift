//
//  UIImageView+Extension.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/25.
//

import UIKit

class Cache {
    
    static let imageCache = NSCache<NSString, UIImage>()
}

public extension UIImageView {
    
    func downloadedFrom(link: String,
                        contentMode mode: UIView.ContentMode = .scaleToFill,
                        size: CGSize? = nil) {
        
        guard let url = URL(string: link) else { return }
        
        self.contentMode = mode
        
        if let cacheImage = Cache.imageCache.object(forKey: url.absoluteString as NSString) {
        
            DispatchQueue.main.async() {

                UIView.transition(with: self,
                                  duration: 0.14,
                                  options: .transitionCrossDissolve,
                                  animations: {

                    self.image = cacheImage

                }, completion: nil)
            }
            
            return
        }
                
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                
                print("Download image fail : \(url)")
                return
            }
            
            print("Download image success \(url)")
            
            guard let size = size,
                  let resizeImage = image.resize(size: size)
            else {
                
                Cache.imageCache.setObject(image,
                                           forKey: url.absoluteString as NSString)
                
                DispatchQueue.main.async() {
                    
                    UIView.transition(with: self ?? UIImageView(),
                                      duration: 0.15,
                                      options: .transitionCrossDissolve) {
                        
                        self?.image = image
                        self?.accessibilityIdentifier = self?.image?.accessibilityIdentifier
                        
                    }
                }
                return
            }
                                                 
            Cache.imageCache.setObject(resizeImage,
                                       forKey: url.absoluteString as NSString)
            
            DispatchQueue.main.async() {
                
                UIView.transition(with: self ?? UIImageView(),
                                  duration: 0.15,
                                  options: .transitionCrossDissolve) {
                    
                    self?.image = resizeImage
                    self?.accessibilityIdentifier = self?.image?.accessibilityIdentifier
                    
                }
            }
            
        }.resume()
    }
}
