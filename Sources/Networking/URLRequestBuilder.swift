//
//  URLRequestBuilder.swift
//  
//
//  Created by estaife on 09/12/22.
//

import Foundation

final class URLRequestBuilder: URLRequestBuilderProtocol {
    
    private let jsonSerializer: JSONSerialization.Type

    init(jsonSerializer: JSONSerialization.Type = JSONSerialization.self) {
        self.jsonSerializer = jsonSerializer
    }

    func builder(with request: HTTPRequestProtocol) throws -> URLRequest {
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
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return urlRequest
            }
            urlComponents.queryItems = parameters.map { (key: String, value: String) -> URLQueryItem in
                return URLQueryItem(name: key, value: value)
            }
            urlRequest.url = urlComponents.url
        case let .json(model):
            do {
                let httpBody = try model.convertToData()
                urlRequest.httpBody = httpBody
            } catch let error as EncodingError {
                throw HTTPRequestError.jsonParse(error)
            }
        case let .body(parameters):
            guard let parameters else {
                throw HTTPRequestError.request(NSError(domain: "URLRequestBuilder", code: -1))
            }
            urlRequest.httpBody = try jsonSerializer.data(withJSONObject: parameters, options: .fragmentsAllowed)

        default:
            break
        }

        return urlRequest
    }
}
