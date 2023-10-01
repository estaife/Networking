//
//  HTTPRequestDispatcher.swift
//  
//
//  Created by estaife on 09/12/22.
//

import Foundation

public class HTTPRequestDispatcher {
    private let session: URLSessionProtocol
    private let builder: URLRequestBuilderProtocol
    
    public init(session: URLSessionProtocol, builder: URLRequestBuilderProtocol) {
        self.session = session
        self.builder = builder
    }
    
    public convenience init() {
        self.init(session: URLSession.shared, builder: URLRequestBuilder())
    }
    
    private func handle(error: Error) -> HTTPRequestError {
        if error._code == -1009 {
            return .networkUnavailable
        }
        return .request(error)
    }
    
    private func handle(response: URLResponse?, data: Data?) -> Result<Data, HTTPRequestError> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.invalidHTTPResponse)
        }
        
        guard let data, !data.isEmpty else {
            return .failure(.emptyData)
        }
        
        if 400...499 ~= httpResponse.statusCode {
            return .failure(.serializedError(data: data, statusCode: httpResponse.statusCode))
        }
        
        if 200...299 ~= httpResponse.statusCode {
            return .success(data)
        }
        
        return .failure(.unknown)
    }
}

extension HTTPRequestDispatcher: HTTPRequestDispatcherProtocol {
   
    public func perform(_ request: HTTPRequestProtocol, completion: @escaping (Result<Data, HTTPRequestError>) -> Void) {
        do {
            let urlRequest = try builder.build(with: request)
            session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
                if let self {
                    if let error {
                        completion(.failure(self.handle(error: error)))
                        return
                    }
                    completion(self.handle(response: response, data: data))
                    return
                }
            }
        } catch {
            completion(.failure(.request(error)))
            return
        }
    }
    
    public func perform(_ url: URL, completion: @escaping (Result<Data, HTTPRequestError>) -> Void) {
        session.dataTask(with: url) { data, _, error in
            if let error { completion(.failure(.request(error))) }
            if let data { completion(.success(data)) }
        }
    }
}
