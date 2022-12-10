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

    func testBuilderWithURLInvalid() throws {
        let requestSpy = HTTPRequestSpy(url: invalidURLString)
        
        XCTAssertThrowsError(try sut.build(with: requestSpy)) { error in
            XCTAssertEqual(error as! HTTPRequestError, HTTPRequestError.urlError(URLError(URLError.Code.badURL)))
        }
    }

    func testBuilderWithURLValid() throws {
        let requestSpy = HTTPRequestSpy(url: validURLString)
    
        let urlRequest = try sut.build(with: requestSpy)
        
        XCTAssertEqual(urlRequest.url?.absoluteString, requestSpy.url)
        XCTAssertEqual(urlRequest.httpMethod, requestSpy.method.rawValue)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, [:])
        XCTAssertNil(urlRequest.httpBody)
    }
    
    func testBuilderWithHeaders() throws {
        let headers: [String : String] = ["keyOne": "valueOne", "keyTwo": "valueTwo"]
        let requestSpy = HTTPRequestSpy(url: validURLString, headers: headers)
        
        let urlRequest = try sut.build(with: requestSpy)
        
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, requestSpy.headers)
    }
    
    func testBuilderWithQueryItemsParameters() throws {
        let expectedQuery = "keyOne=valueOne"
        let items: [String : String] = ["keyOne": "valueOne"]
        let requestSpy = HTTPRequestSpy(url: validURLString, method: .post, headers: nil, parameters: .queryItems(items))
    
        let urlRequest = try sut.build(with: requestSpy)
        
        XCTAssertEqual(urlRequest.url?.query, expectedQuery)
    }
    
    func testBuilderWithJSONParameters() throws {
        let testModel = TestModel(test: "test")
        let requestSpy = HTTPRequestSpy(url: validURLString, method: .post, parameters: .json(model: testModel))
        
        let urlRequest = try sut.build(with: requestSpy)
        
        XCTAssertEqual(urlRequest.httpBody, try testModel.convertToData())
    }
    
    func testBuilderWithJSONParametersParseError() throws {
        let testModel = TestModel(test: "test")
        let requestSpy = HTTPRequestSpy(url: validURLString, method: .post, parameters: .json(model: testModel))
        let errorExpected = NSError(domain: "Json Serializer Error", code: -1)
        encoderMock.errorStub = errorExpected
        
        let sut = URLRequestBuilder(jsonEncoder: encoderMock)
        
        XCTAssertThrowsError(try sut.build(with: requestSpy)) { error in
            XCTAssertEqual(error as! HTTPRequestError, HTTPRequestError.requestSerialization(errorExpected))
        }
    }
    
    func testBuilderWithBodyParameters() throws {
        let url = "http://example.com"
        let dictionaryBody = ["fieldOne": "valueOne", "fieldTwo" : ["subFieldTwo" : "subFieldTwo"]] as [String : Any]
        let requestSpy = HTTPRequestSpy(url: url, method: .post, parameters: .body(dictionaryBody))

        let urlRequest = try sut.build(with: requestSpy)
        
        XCTAssertNotNil(urlRequest.httpBody)
    }
    
    func testBuilderWithBodyParametersParseError() throws {
        let dictionaryBody = ["fieldOne": "valueOne", "fieldTwo" : ["subFieldTwo" : "subFieldTwo"]] as [String : Any]
        let requestSpy = HTTPRequestSpy(url: validURLString, method: .post, parameters: .body(dictionaryBody))
        let expectedError = NSError(domain: "Json Serializer Error", code: -1)
        
        JSONSerializationMock.errorStub = expectedError
        let sut = URLRequestBuilder(jsonSerializer: JSONSerializationMock.self)
        
        XCTAssertThrowsError(try sut.build(with: requestSpy)) { error in
            XCTAssertEqual(error as! HTTPRequestError, HTTPRequestError.requestSerialization(expectedError))
        }
    }
}
