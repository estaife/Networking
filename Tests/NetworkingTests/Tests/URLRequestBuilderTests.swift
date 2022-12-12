//
//  URLRequestBuilderTests.swift
//  
//
//  Created by estaife on 10/12/22.
//

@testable import Networking
import XCTest

final class URLRequestBuilderTests: XCTestCase {

    private var sut: URLRequestBuilder!
    private var encoderMock: JSONEncoderMock!

    override func setUp() {
        super.setUp()
        sut = URLRequestBuilder()
        encoderMock = JSONEncoderMock()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        encoderMock = nil
    }

    func testBuildWithURLInvalid() throws {
        let requestSpy = HTTPRequestSpy(url: Seeds.invalidURLString)
        
        XCTAssertThrowsError(try sut.build(with: requestSpy)) { error in
            XCTAssertEqual(error as! HTTPRequestError, HTTPRequestError.parameterEncodingFailed(reason: .missingURL))
        }
    }

    func testBuildWithURLValid() throws {
        let requestSpy = HTTPRequestSpy(url: Seeds.urlString)
    
        let urlRequest = try sut.build(with: requestSpy)
        
        XCTAssertEqual(urlRequest.url?.absoluteString, requestSpy.url)
        XCTAssertEqual(urlRequest.httpMethod, requestSpy.method.rawValue)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, [:])
        XCTAssertNil(urlRequest.httpBody)
    }
    
    func testBuildWithHeaders() throws {
        let headers: [String : String] = ["keyOne": "valueOne", "keyTwo": "valueTwo"]
        let requestSpy = HTTPRequestSpy(url: Seeds.urlString, headers: headers)
        
        let urlRequest = try sut.build(with: requestSpy)
        
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, requestSpy.headers)
    }
    
    func testBuildWithQueryItemsParameters() throws {
        let expectedQuery = "keyOne=valueOne"
        let items: [String : String] = ["keyOne": "valueOne"]
        let requestSpy = HTTPRequestSpy(url: Seeds.urlString, parameters: .queryItems(items))
    
        let urlRequest = try sut.build(with: requestSpy)
        
        XCTAssertEqual(urlRequest.url?.query, expectedQuery)
    }
    
    func testBuildWithJSONParameters() throws {
        let requestSpy = HTTPRequestSpy(url: Seeds.urlString, method: .post, parameters: .json(model: Seeds.testModel))
        
        let urlRequest = try sut.build(with: requestSpy)
        
        XCTAssertEqual(urlRequest.httpBody, try Seeds.testModel.convertToData())
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/json")
    }
    
    func testBuildWithJSONParametersEncodingFailed() throws {
        let testModel = TestModel(test: "test")
        let requestSpy = HTTPRequestSpy(url: Seeds.urlString, method: .post, parameters: .json(model: testModel))
        encoderMock.errorStub = Seeds.error
        
        let sut = URLRequestBuilder(jsonEncoder: encoderMock)
        
        XCTAssertThrowsError(try sut.build(with: requestSpy)) { error in
            XCTAssertEqual(error as! HTTPRequestError, HTTPRequestError.parameterEncodingFailed(reason: .customEncodingFailed(error: Seeds.error)))
        }
    }
    
    func testBuildWithBodyParameters() throws {
        let requestSpy = HTTPRequestSpy(url: Seeds.urlString, method: .post, parameters: .body(Seeds.dictionaryBody))

        let urlRequest = try sut.build(with: requestSpy)
        
        XCTAssertNotNil(urlRequest.httpBody)
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/json")
    }
    
    func testBuildWithBodyInvalidJSON() throws {
        let requestSpy = HTTPRequestSpy(url: Seeds.urlString, method: .post, parameters: .body(Seeds.dictionaryBody))
        let sut = URLRequestBuilder(jsonSerializer: JSONSerializationMock.self)
        
        JSONSerializationMock.isValidJSONObjectStub = false
        
        XCTAssertThrowsError(try sut.build(with: requestSpy)) { error in
            XCTAssertEqual(error as! HTTPRequestError, HTTPRequestError.parameterEncodingFailed(reason: .invalidJSONObject))
        }
    }
    
    func testBuilderWithBodyParametersEncodingFailed() throws {
        let requestSpy = HTTPRequestSpy(url: Seeds.urlString, method: .post, parameters: .body(Seeds.dictionaryBody))
        
        JSONSerializationMock.errorStub = Seeds.error
        let sut = URLRequestBuilder(jsonSerializer: JSONSerializationMock.self)
        
        XCTAssertThrowsError(try sut.build(with: requestSpy)) { error in
            XCTAssertEqual(error as! HTTPRequestError, HTTPRequestError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: Seeds.error)))
        }
    }
}
