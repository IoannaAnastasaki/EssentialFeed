//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by ΙωάνναΑναστασάκη on 5/10/24.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCcheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)// let sut -> it is the system under test
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
