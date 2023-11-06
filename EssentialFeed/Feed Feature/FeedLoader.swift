//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by ΙωάνναΑναστασάκη on 12/8/23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
