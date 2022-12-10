//
//  XCTestCase.swift
//  
//
//  Created by estaife on 10/12/22.
//

import XCTest

extension XCTestCase {
    var validURLString: String { "http://example.com" }
    var invalidURLString: String { #"http://example.com/file\/.html"# }
}
