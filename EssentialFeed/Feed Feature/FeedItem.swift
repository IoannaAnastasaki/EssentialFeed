//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by ΙωάνναΑναστασάκη on 12/8/23.
//

import Foundation

public struct FeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, loacation: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = loacation
        self.imageURL = imageURL
    }
    
}

extension FeedItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
