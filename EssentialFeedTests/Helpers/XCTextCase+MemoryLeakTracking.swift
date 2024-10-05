//
//  XCTextCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by ΙωάνναΑναστασάκη on 11/3/24.
//

import XCTest

extension XCTestCase {
     func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated. Potential memory leak.",  file: file, line: line)
        }
    }
}
