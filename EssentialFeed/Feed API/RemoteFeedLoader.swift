//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by ΙωάνναΑναστασάκη on 13/10/23.
//

import Foundation


public protocol HTTPClient {
    func get(from url: URL, completion: @escaping(Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping(Error) -> Void) {
        client.get(from: url) { error, response in
            if response != nil {
                completion(.invalidData)
            }
            else {
                completion(.connectivity)
            }
        }
    }
}
