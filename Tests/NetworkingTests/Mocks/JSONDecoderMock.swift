//
//  JSONDecoderMock.swift
//  
//
//  Created by estaife on 11/12/22.
//

import Foundation

final class JSONDecoderMock: JSONDecoder {
    var errorStub: Error?
    
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        if let errorStub {
            throw errorStub
        }
        return try super.decode(type, from: data)
    }
}
