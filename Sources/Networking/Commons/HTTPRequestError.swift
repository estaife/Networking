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
    case requestSerialization(Error)
    case serializedError(data: Data, statusCode: Int)
    case request(Error)
    case jsonParse(Error)
    case urlError(URLError)
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
        case let (.requestSerialization(lhsError), .requestSerialization(rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        case let (.serializedError(lhsData, lhsCode), .serializedError(rhsData, rhsCode)):
            return lhsData == rhsData && lhsCode == rhsCode
        case let (.request(lhsError), .request(rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        case let (.jsonParse(lhsError), .jsonParse(rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        case let (.urlError(e1), .urlError(e2)):
            return e1 == e2
        default:
            return false
        }
    }
}
