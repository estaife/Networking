//
//  URLProtocolMock.swift
//  
//
//  Created by estaife on 10/12/22.
//

import Foundation

final class URLProtocolMock: URLProtocol {
    static var emit: ((URLRequest) -> Void)?
    static var data: Data?
    static var response: HTTPURLResponse?
    static var error: Error?
    
    static func applySimulateWith(data: Data?, response: HTTPURLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }
     
    static func observerRequest(completion: @escaping (URLRequest) -> Void) {
        URLProtocolMock.emit = completion
    }
    
    // MARK: - URLProtocol
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        URLProtocolMock.emit?(request)
        handleResponse()
    }
    
    override func stopLoading() { }
    
    // MARK: - Handle Response
    private func handleResponse() {
        if let error = URLProtocolMock.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        if let response = URLProtocolMock.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = URLProtocolMock.data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
}
