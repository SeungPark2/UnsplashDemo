//
//  UIImage+Extension.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/26.
//

import UIKit

extension UIImage {

    func resize(size: CGSize) -> UIImage? {
        
        let customSize = CGSize(width: floor(size.width * UIScreen.main.scale),
                                height: floor(size.height * UIScreen.main.scale))
        
        UIGraphicsBeginImageContext(customSize)
        draw(in: CGRect(x: 0,
                        y: 0,
                        width: customSize.width,
                        height: customSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

}
