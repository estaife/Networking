//
//  XCTestCase.swift
//  
//
//  Created by estaife on 10/12/22.
//

import XCTest

extension XCTestCase {
    func memoryLeakCheckWith(instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}
