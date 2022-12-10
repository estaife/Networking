//
//  URLRequestBuilder.swift
//  
//
//  Created by estaife on 09/12/22.
//

import Foundation

final class URLRequestBuilder: URLRequestBuilderProtocol {
    
    private let jsonSerializer: JSONSerialization.Type
    private let jsonEncoder: JSONEncoder

    init(jsonSerializer: JSONSerialization.Type = JSONSerialization.self, jsonEncoder: JSONEncoder = .init()) {
        self.jsonSerializer = jsonSerializer
        self.jsonEncoder = jsonEncoder
    }

    func build(with request: HTTPRequestProtocol) throws -> URLRequest {
        guard let url = URL(string: request.url) else {
            throw HTTPRequestError.urlError(URLError(URLError.Code.badURL))
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        request.headers?.forEach { dictionary in
            urlRequest.setValue(dictionary.value, forHTTPHeaderField: dictionary.key)
        }
        switch request.parameters {
        case let .queryItems(parameters):
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                urlComponents.queryItems = parameters.map { (key: String, value: String) -> URLQueryItem in
                    return URLQueryItem(name: key, value: value)
                }
                urlRequest.url = urlComponents.url
            }
        case let .json(model):
            do {
                let httpBody = try jsonEncoder.encode(model)
                urlRequest.httpBody = httpBody
            } catch {
                throw HTTPRequestError.requestSerialization(error)
            }
        case let .body(parameters):
            do {
                let httpBody = try jsonSerializer.data(withJSONObject: parameters, options: .fragmentsAllowed)
                urlRequest.httpBody = httpBody
            } catch {
                throw HTTPRequestError.requestSerialization(error)
            }
        default:
            break
        }

        return urlRequest
    }
}
