//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by ΙωάνναΑναστασάκη on 12/8/23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "http://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    private init() {}
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
}



/***
 Some theory for this lecture
 
 sut: system under test-small piece of code to test
 The tests in this file are specifically for RemoteFeedLoader, so the sut is RemoteFeedLoader
 
 Collaborator: Like Alamofire, URLSession, HttpClient
 
 XCTAssert: asserts that an expression is true
 
 test_init_doesNotRequestDataFromURL():
 first test - We did not make url request since that should only happen when .load() is invoked
 
 test_load_requestDataFromURL():
 second test -  in this test is expected to call load() from RemoteFeedLoader and get the data from the internet.
 We can pass client to RemoteFeedLoader fwith dependency injection(
    Constructor Dependency ijection:   let sut = RemoteFeedLoader(client: client)
    Property dependency injection: sut.client = client
    method dependency injection: sut.load(client: client)
    )
 
But instructors suggest not dependency injection but a more concrete way to communicate RemoteFeedLoader and HttpClient, Singleton Impementation.
 
 The test are passed, but why to have Singleton HttpClient and not have as many HttpClients as i want?
 
 
 */

