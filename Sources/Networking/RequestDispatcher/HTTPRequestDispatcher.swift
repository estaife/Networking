//
//  HTTPRequestDispatcher.swift
//  
//
//  Created by estaife on 09/12/22.
//

import Foundation

public class HTTPRequestDispatcher: HTTPRequestDispatcherProtocol {
    public let session: URLSessionProtocol
    public let builder: URLRequestBuilderProtocol
    
    public required init(session: URLSessionProtocol, builder: URLRequestBuilderProtocol) {
        self.session = session
        self.builder = builder
    }
    
    public convenience init() {
        self.init(session: URLSession.shared, builder: URLRequestBuilder())
    }
   
    public func execute<ResponseType: Codable>(_ request: HTTPRequestProtocol, type: ResponseType.Type, completion: @escaping (Result<ResponseType, HTTPRequestError>) -> Void) {
        
        do {
            let urlRequest = try builder.build(with: request)
            session.dataTask(with: urlRequest) { (data, response, error) in
                if let error {
                    switch error {
                    case let urlError as URLError:
                        if urlError.networkUnavailableReason != nil {
                            completion(.failure(.networkUnavailable))
                        }
                        completion(.failure(.urlError(urlError)))
                        
                    case let requestError as HTTPRequestError:
                        completion(.failure(requestError))
                        
                    default:
                        completion(.failure(.request(error)))
                    }
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidHTTPResponse))
                    return
                }
                
                guard let data else {
                    completion(.failure(.unknown))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    completion(.failure(.serializedError(data: data, statusCode: httpResponse.statusCode)))
                    return
                }
        
                do {
                    let decoder = JSONDecoder()
                    let responseType = try decoder.decode(type.self, from: data)
                    completion(.success(responseType))
                    return
                } catch let error as DecodingError {
                    completion(.failure(.jsonParse(error)))
                    return
                } catch {
                    completion(.failure(.unknown))
                    return
                }
            }
        } catch {
            completion(.failure(.request(error)))
        }
    }
    
    public func execute(_ url: URL, completion: @escaping (Result<Data, HTTPRequestError>) -> Void) {
        session.dataTask(with: url) { data, _, error in
            if let error { completion(.failure(.request(error))) }
            if let data { completion(.success(data)) }
        }
    }
}
