//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by ΙωάνναΑναστασάκη on 12/8/23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
