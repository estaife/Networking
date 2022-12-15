//
//  HTTPRequestDispatcherProtocol.swift
//
//
//  Created by estaife on 09/12/22.
//

import Foundation

public protocol HTTPRequestDispatcherProtocol: AnyObject {
    func perform(_ request: HTTPRequestProtocol, completion: @escaping (Result<Data, HTTPRequestError>) -> Void)
    func perform(_ url: URL, completion: @escaping (Result<Data, HTTPRequestError>) -> Void)
}
