//
//  JSONEncoderMock.swift
//  
//
//  Created by estaife on 10/12/22.
//

import Foundation

final class JSONEncoderMock: JSONEncoder {
    var errorStub: Error?
    
    override func encode<T>(_ value: T) throws -> Data where T : Encodable {
        if let errorStub {
            throw errorStub
        }
        
        return try super.encode(value)
    }
}
