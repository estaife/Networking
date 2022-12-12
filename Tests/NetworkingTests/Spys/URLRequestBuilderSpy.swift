//
//  URLRequestBuilderSpy.swift
//  
//
//  Created by estaife on 11/12/22.
//

@testable import Networking
import Foundation

final class URLRequestBuilderSpy: URLRequestBuilderProtocol {
    var errorStub: Error?
    
    func build(with request: HTTPRequestProtocol) throws -> URLRequest {
        if let errorStub {
            throw errorStub
        }
        return URLRequest(url: Seeds.url)
    }
}
