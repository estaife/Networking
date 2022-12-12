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
    private let decoder: JSONDecoder
    
    public init(session: URLSessionProtocol, builder: URLRequestBuilderProtocol, decoder: JSONDecoder) {
        self.session = session
        self.builder = builder
        self.decoder = decoder
    }
    
    public convenience init() {
        self.init(session: URLSession.shared, builder: URLRequestBuilder(), decoder: JSONDecoder())
    }
    
    private func handle(error: Error) -> HTTPRequestError {
        if error._code == -1009 {
            return .networkUnavailable
        }
        return .request(error)
    }
    
    private func handle<ResponseType: Codable>(type: ResponseType.Type, response: URLResponse?, data: Data?) -> Result<ResponseType, HTTPRequestError> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.invalidHTTPResponse)
        }
        
        guard let data, !data.isEmpty else {
            return .failure(.unknown)
        }
        
        if 400...499 ~= httpResponse.statusCode {
            return .failure(.serializedError(data: data, statusCode: httpResponse.statusCode))
        }
        
        if 200...299 ~= httpResponse.statusCode {
            do {
                let responseType = try decoder.decode(type.self, from: data)
                return .success(responseType)
            } catch let error as DecodingError {
                return .failure(.responseSerializationFailed(error))
            } catch {
                return .failure(.unknown)
            }
        }
        
        return .failure(.unknown)
    }
}

extension HTTPRequestDispatcher: HTTPRequestDispatcherProtocol {
   
    public func execute<ResponseType: Codable>(_ request: HTTPRequestProtocol, type: ResponseType.Type, completion: @escaping (Result<ResponseType, HTTPRequestError>) -> Void) {
        do {
            let urlRequest = try builder.build(with: request)
            session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
                if let self {
                    if let error {
                        completion(.failure(self.handle(error: error)))
                        return
                    }
                    completion(self.handle(type: type, response: response, data: data))
                    return
                }
            }
        } catch {
            completion(.failure(.request(error)))
            return
        }
    }
    
    public func execute(_ url: URL, completion: @escaping (Result<Data, HTTPRequestError>) -> Void) {
        session.dataTask(with: url) { data, _, error in
            if let error { completion(.failure(.request(error))) }
            if let data { completion(.success(data)) }
        }
    }
}
