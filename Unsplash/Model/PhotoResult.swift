//
//  Photo.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/25.
//

import Foundation

struct PhotoResult: Codable {
    
    let total: Int?
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        
        case total, photos = "results"
    }
}

struct Photo: Codable {
    
    let id: String
    let width: Int?
    let height: Int?
    let urls: ImageURL
    let isLikedByUser: Bool
    let user: User
    
    enum CodingKeys: String, CodingKey {
        
        case id, width, height, user, urls
        case isLikedByUser = "liked_by_user"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.id = (try? container?.decode(String.self, forKey: .id)) ?? ""
        self.width = try? container?.decode(Int.self, forKey: .width)
        self.height = try? container?.decode(Int.self, forKey: .height)
        self.urls = try container!.decode(ImageURL.self, forKey: .urls)
        self.isLikedByUser = (try? container?.decode(Bool.self, forKey: .isLikedByUser)) ?? false
        self.user = try container!.decode(User.self, forKey: .user)
    }
}

struct User: Codable {
    
    let name: String
    
    enum CodingKeys: CodingKey {
        
        case name
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.name = (try? container?.decode(String.self, forKey: .name)) ?? ""
    }
}

struct ImageURL: Codable {
    
    let regular: String
    let thumb: String
    let small: String
    
    enum CodingKeys: CodingKey {
        
        case regular, thumb, small
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.regular = (try? container?.decode(String.self, forKey: .regular)) ?? ""
        self.thumb = (try? container?.decode(String.self, forKey: .thumb)) ?? ""
        self.small = (try? container?.decode(String.self, forKey: .small)) ?? ""
    }
}
