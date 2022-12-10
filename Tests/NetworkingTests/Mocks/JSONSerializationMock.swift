//
//  JSONSerializationMock.swift
//  
//
//  Created by estaife on 10/12/22.
//

import Foundation

final class JSONSerializationMock: JSONSerialization {
    static var errorStub: Error?
    
    override class func data(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions = []) throws -> Data {
        if let errorStub {
            throw errorStub
        }
        return try super.data(withJSONObject: obj, options: opt)
    }
}
