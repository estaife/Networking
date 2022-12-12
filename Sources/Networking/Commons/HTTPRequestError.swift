//
//  HTTPRequestError.swift
//
//
//  Created by estaife on 09/12/22.
//

import Foundation

public enum HTTPRequestError: Error {
    case unknown
    case networkUnavailable
    case invalidHTTPResponse
    case serializedError(data: Data, statusCode: Int)
    case request(Error)
    case parameterEncodingFailed(reason: ParameterEncodingFailure)
    case responseSerializationFailed(Error)
    
    public enum ParameterEncodingFailure: Error, Equatable {
        case missingURL
        case invalidJSONObject
        case jsonEncodingFailed(error: Error)
        case customEncodingFailed(error: Error)
        
        public static func == (lhs: HTTPRequestError.ParameterEncodingFailure, rhs: HTTPRequestError.ParameterEncodingFailure) -> Bool {
            switch (lhs, rhs) {
            case (.missingURL, .missingURL):
                return true
            case (.invalidJSONObject, .invalidJSONObject):
                return true
            case let (.jsonEncodingFailed(lhsError), .jsonEncodingFailed(rhsError)):
                return (lhsError as NSError) == (rhsError as NSError)
            case let (.customEncodingFailed(lhsError), .customEncodingFailed(rhsError)):
                return (lhsError as NSError) == (rhsError as NSError)
            default:
                return false
            }
        }
    }
}

extension HTTPRequestError: Equatable {
    public static func == (lhs: HTTPRequestError, rhs: HTTPRequestError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case (.networkUnavailable, .networkUnavailable):
            return true
        case (.invalidHTTPResponse, .invalidHTTPResponse):
            return true
        case let (.serializedError(lhsData, lhsCode), .serializedError(rhsData, rhsCode)):
            return lhsData == rhsData && lhsCode == rhsCode
        case let (.request(lhsError), .request(rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        case let (.parameterEncodingFailed(lhsReason), .parameterEncodingFailed(rhsReason)):
            return lhsReason == rhsReason
        case let (.responseSerializationFailed(lhsError), .responseSerializationFailed(rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        default:
            return false
        }
    }
}
