//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by ΙωάνναΑναστασάκη on 12/8/23.
//

import XCTest

class RemoteFeedLoader {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
     client.get(from: URL(string: "http://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    
    func get(from url: URL) {
        requestedURL = url
    }
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
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
 The goal is to refactor and get rid of the Singleton:
 How?
 1.make shared a var(it will be not singleton anymore).
 2.Move test logic from the RemoteFeedUrl to HttpClient(the false url line)
 3. Move the test logic ta a new subclass of the HttpClient(making shared property var
 instead of let, open the possibility to make subclass of HttpClient. We do not want the requestedUrl
 to HttpClient class as it exists only for testing purposes)
 4. Swap HttpClient shared instance with the spy subclass during tests
 5. Remove HttpClient private initializer(constructor) since its not a Singleton anymore
 //We do not have a Singleton anymore and the test logic is now in the test type - spy class
 
 10:22
 Not good approach to use share instance directly at
 HTTPClient.shared.get(from: URL(string: "http://a-url.com")!)
because we are mixing responsibilities - responsibility of invoking a method in an object
 and responsibility of locating this object. I f we inject our client we have more control in our code, we do not want to know ehich Http instance i am using.
 Using constructor dependency injection to RemoteFeedUrl, i did not need shaed instance and when i deleted
 sharedInstance from HttpClient class, it was looking like an abstract class, as it had only the get method that the spy class already ovverided. So we make HttpClient to protocol and the spy class just conforms to it.
 
 */

