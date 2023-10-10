//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by ΙωάνναΑναστασάκη on 12/8/23.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        // o client mporei na einai URLSession, Alamofire klp
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        //to prwto mas test gia na kanoume execute th load feeds command apo to api
        //sut.load()
        
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient()
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNil(client.requestedURL)
    }
    
}
