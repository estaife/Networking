//
//  RequestBuilderProtocol.swift
//  
//
//  Created by estaife on 09/12/22.
//

import Foundation

public protocol URLRequestBuilderProtocol {
    func builder(with request: HTTPRequestProtocol) throws -> URLRequest
}
