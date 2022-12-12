//
//  HTTPRequestProtocol.swift
//  
//
//  Created by estaife on 09/12/22.
//

import Foundation

public protocol HTTPRequestProtocol {
    var url: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var parameters: HTTPRequestParameters { get }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public enum HTTPRequestParameters {
    case queryItems([String: String])
    case json(model: Encodable)
    case body([String: Any])
    case plain
}

public extension Encodable {
    func convertToData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
