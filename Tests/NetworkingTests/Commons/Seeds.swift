//
//  Seeds.swift
//  
//
//  Created by estaife on 10/12/22.
//

import Foundation

struct Seeds {
    static var dataInvalid: Data { .init("Data Invaid".utf8) }

    static var dataValid: Data {
        .init(#"{ "test" : "mock" }"#.utf8)
    }

    static var dataEmpty: Data { .init() }

    static var url: URL { URL(string: "http://url-mock.com")! }
    
    static var urlString: String { "http://url-mock.com" }
    
    static var invalidURLString: String { "" } 

    static var error: Error {  NSError(domain: "Networking.HTTPRequestError", code: 2) }

    static func createResponseWith(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    static var testModel: TestModel {
        .init(test: "TestModel")
    }
    
    static var dictionaryBody: [String : Any] {
        ["fieldOne": "valueOne", "fieldTwo" : ["subFieldTwo" : "subFieldTwo"]] as [String : Any]
    }
}
