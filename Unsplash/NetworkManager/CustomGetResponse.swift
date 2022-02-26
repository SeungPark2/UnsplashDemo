//
//  CustomGetReponse.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/25.
//

import Foundation

extension Network {
    
    struct CustomGetResponse {
        
        var isHadNextPage: Bool
        var data: Data
    }
}
