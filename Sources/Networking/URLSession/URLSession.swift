//
//  URLSession.swift
//  
//
//  Created by estaife on 10/12/22.
//

import Foundation

extension URLSession: URLSessionProtocol {
    public func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    public func dataTask(with url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        dataTask(with: url, completionHandler: completionHandler).resume()
    }
}
