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
            throw HTTPRequestError.parameterEncodingFailed(reason: .missingURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        request.headers.forEach { dictionary in
            urlRequest.setValue(dictionary.value, forHTTPHeaderField: dictionary.key)
        }
        
        switch request.parameters {
        case let .queryItems(parameters):
            buildQueryItems(url: url, parameters: parameters, urlRequest: &urlRequest)
        case let .json(model):
            try buildJSON(url: url, model: model, headers: request.headers, urlRequest: &urlRequest)
        case let .body(parameters):
            try buildBody(url: url, parameters: parameters, headers: request.headers, urlRequest: &urlRequest)
        default:
            break
        }

        return urlRequest
    }
    
    private func buildQueryItems(url: URL, parameters: [String : String], urlRequest: inout URLRequest) {
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            urlComponents.queryItems = parameters.map { (key: String, value: String) -> URLQueryItem in
                return URLQueryItem(name: key, value: value)
            }
            urlRequest.url = urlComponents.url
        }
    }
    
    private func buildBody(url: URL, parameters: [String : Any], headers: [String : String], urlRequest: inout URLRequest) throws {
        buildContentTypeIfNeeded(headers: headers, urlRequest: &urlRequest)
        
        guard jsonSerializer.isValidJSONObject(parameters) else {
            throw HTTPRequestError.parameterEncodingFailed(reason: .invalidJSONObject)
        }

        do {            
            let httpBody = try jsonSerializer.data(withJSONObject: parameters, options: .fragmentsAllowed)
            urlRequest.httpBody = httpBody
            
        } catch {
            throw HTTPRequestError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
    }
    
    private func buildJSON(url: URL, model: Encodable, headers: [String : String], urlRequest: inout URLRequest) throws {
        buildContentTypeIfNeeded(headers: headers, urlRequest: &urlRequest)
        
        do {
            let httpBody = try jsonEncoder.encode(model)
            urlRequest.httpBody = httpBody
        } catch {
            throw HTTPRequestError.parameterEncodingFailed(reason: .customEncodingFailed(error: error))
        }
    }
    
    private func buildContentTypeIfNeeded(headers: [String : String], urlRequest: inout URLRequest) {
        if headers["Content-Type"] == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
