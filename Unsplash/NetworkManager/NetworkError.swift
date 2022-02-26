//
//  NetworkError.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/25.
//

import Foundation

enum NetworkError: Error {
    
    case invalidToken
    case accessDenied
    case failed(errCode: Int, message: String)
    case serverNotConnected
}

extension NetworkError {
    
    var description: String {
        
        switch self {
            
        case .invalidToken: return ""
        case .accessDenied: return ""
        case .failed(_, _): return ""
        case .serverNotConnected: return ""
        }
    }
}
