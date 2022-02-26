//
//  Array+Extension.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/25.
//

import Foundation

extension Array {
    
    subscript (safe index: Int) -> Element? {

        return indices ~= index ? self[index] : nil
    }
}
