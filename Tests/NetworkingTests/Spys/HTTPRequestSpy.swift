//
//  HTTPRequestSpy.swift
//  
//
//  Created by estaife on 10/12/22.
//

import Networking

struct HTTPRequestSpy: HTTPRequestProtocol {
    var url: String
    var method: HTTPMethod
    var headers: [String : String]?
    var parameters: HTTPRequestParameters
    
    init(url: String, method: HTTPMethod = .get, headers: [String : String]? = nil, parameters: HTTPRequestParameters = .plain) {
        self.url = url
        self.method = method
        self.headers = headers
        self.parameters = parameters
    }
}
