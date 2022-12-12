//
//  HTTPRequestDispatcherProtocol.swift
//
//
//  Created by estaife on 09/12/22.
//

import Foundation

public protocol HTTPRequestDispatcherProtocol: AnyObject {
    init(session: URLSessionProtocol, builder: URLRequestBuilderProtocol, decoder: JSONDecoder)
    
    func execute<ResponseType: Codable>(_ request: HTTPRequestProtocol, type: ResponseType.Type, completion: @escaping (Result<ResponseType, HTTPRequestError>) -> Void)
    func execute(_ url: URL, completion: @escaping (Result<Data, HTTPRequestError>) -> Void)
}
