//
//  HTTPRequestDispatcherTests.swift
//  
//
//  Created by estaife on 10/12/22.
//

import XCTest
@testable import Networking

final class HTTPRequestDispatcherTests: XCTestCase {
    func testConvenienceInit() {
        let sut = HTTPRequestDispatcher()
        
        XCTAssertNotNil(sut)
    }
    
    func testDownloadData() throws {
        let sut = createSUT()
        let dataExpected = Seeds.dataValid

        let expectation = expectation(description: #function)
        
        sut.execute(Seeds.url) { result in
            switch result {
            case .success(let dataReceived):
                XCTAssertEqual(dataReceived, dataExpected)
            default:
                XCTFail()
            }
            expectation.fulfill()
        }
        
        URLProtocolMock.applySimulateWith(
            data: dataExpected,
            response: Seeds.createResponseWith(statusCode: 204),
            error: nil
        )
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testDownloadDataCompleteRequestError() throws {
        let sut = createSUT()
        let errorExpected = HTTPRequestError.request(Seeds.error)

        let expectation = expectation(description: #function)
        
        sut.execute(Seeds.url) { result in
            switch result {
            case .failure(let errorReceived):
                XCTAssertEqual((errorReceived as NSError).code, (errorExpected as NSError).code)
                XCTAssertEqual((errorReceived as NSError).domain, (errorExpected as NSError).domain)
            default:
                XCTFail()
            }
            expectation.fulfill()
        }
        
        URLProtocolMock.applySimulateWith(
            data: nil,
            response: Seeds.createResponseWith(statusCode: 204),
            error: errorExpected
        )
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testGETMakeRequestWithURLAndMethodCorect() {
        let request = HTTPRequestSpy(url: Seeds.urlString)
        
        expectRequestWith(request: request) { requestExpected in
            XCTAssertEqual(Seeds.url, requestExpected.url)
            XCTAssertEqual("GET", requestExpected.httpMethod)
        }
    }
    
    func testGETMakeRequestWithHeadersCorect() {
        let request = HTTPRequestSpy(url: Seeds.urlString, headers: ["Request-Header": "mock-value"])
        
        expectRequestWith(request: request) { requestExpected in
            XCTAssertEqual(requestExpected.allHTTPHeaderFields, request.headers)
        }
    }
    
    func testPOSTMakeRequestWithURLAndMethodCorect() {
        let request = HTTPRequestSpy(url: Seeds.urlString, method: .post, parameters: .json(model: Seeds.testModel))
        
        expectRequestWith(request: request) { requestExpected in
            XCTAssertEqual(Seeds.url, requestExpected.url)
            XCTAssertEqual("POST", requestExpected.httpMethod)
            XCTAssertNotNil(requestExpected.httpBodyStream)
        }
    }
    
    func testPOSTMakeRequestRequestWhenDataHasBeenNil() throws {
        let request = HTTPRequestSpy(url: Seeds.urlString, method: .post)
        
        expectRequestWith(request: request) { requestExpected in
            XCTAssertNil(requestExpected.httpBody)
        }
    }
    
    func testPOSTMakeRequestToCompleteWithNetworkUnavailableError() throws {
        expectResultWith(
            type: TestModel.self,
            resultExpected: .failure(.networkUnavailable),
            andWith: (
                data: nil,
                response: nil,
                error: NSError(domain: "error_any", code: -1009)
            )
        )
    }
    
    func testPOSTMakeRequestToCompleteWithRequestError() throws {
        expectResultWith(
            type: TestModel.self,
            resultExpected: .failure(.request(Seeds.error)),
            andWith: (
                data: nil,
                response: nil,
                error: HTTPRequestError.request(Seeds.error)
            )
        )
    }
    
    func testPOSTMakeRequestToCompleteWithDataAndResponse200() {
        expectResultWith(
            type: TestModel.self,
            resultExpected: .success(try! Seeds.testModel.convertToData()),
            andWith: (
                data: try! Seeds.testModel.convertToData(),
                response: Seeds.createResponseWith(statusCode: 200),
                error: nil
            )
        )
    }
    
    func testPOSTMakeRequestToCompleteWithDataOptionalAndResponse204() throws {
        expectResultWith(
            type: TestModel.self,
            resultExpected: .success(try! Seeds.testModel.convertToData()),
            andWith: (
                data: try! Seeds.testModel.convertToData(),
                response: Seeds.createResponseWith(statusCode: 204),
                error: nil
            )
        )
        
        expectResultWith(
            type: [TestModel].self,
            resultExpected: .failure(HTTPRequestError.responseSerializationFailed(NSError(domain: "NSCocoaErrorDomain", code: 3840))),
            andWith: (
                data: Seeds.dataValid,
                response: Seeds.createResponseWith(statusCode: 204),
                error: nil
            )
        )
    }
    
    func testPOSTMakeRequestToCompleteWithInvalidHTTPResponseError() throws {
        expectResultWith(
            type: TestModel.self,
            resultExpected: .failure(.invalidHTTPResponse),
            andWith: (
                data: nil,
                response: nil,
                error: nil
            )
        )
    }
    
    func testPOSTMakeRequestToCompleteWithUnknownError() throws {
        expectResultWith(
            type: TestModel.self,
            resultExpected: .failure(.unknown),
            andWith: (
                data: Seeds.dataEmpty,
                response: Seeds.createResponseWith(statusCode: 1),
                error: nil
            )
        )
    }
    
    func testPOSTMakeRequestToCompleteWithSerializedError() throws {
        expectResultWith(
            type: TestModel.self,
            resultExpected: .failure(.serializedError(data: Seeds.dataValid, statusCode: 404)),
            andWith: (
                data: Seeds.dataValid,
                response: Seeds.createResponseWith(statusCode: 404),
                error: nil
            )
        )
    }
    
    func testPOSTMakeRequestToCompleteWithUnknownErrorAtDecode() throws {
        let request = HTTPRequestSpy(url: Seeds.urlString, method: .post)
        let decoderMock = JSONDecoderMock()
        decoderMock.errorStub = Seeds.error
        
        let sut = createSUT(decoder: decoderMock)

        let expectation = expectation(description: #function)
        
        sut.execute(request, type: TestModel.self) { resultReceived in
            switch resultReceived {
            case .failure(let errorReceived):
                XCTAssertEqual(errorReceived as HTTPRequestError, .unknown)
            default:
                XCTFail()
            }
            expectation.fulfill()
        }
        
        URLProtocolMock.applySimulateWith(
            data: Seeds.dataValid,
            response: Seeds.createResponseWith(statusCode: 204),
            error: nil
        )
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testPOSTMakeRequestToCompleteWithErrorIntoBuildParameters() throws {
        let request = HTTPRequestSpy(url: Seeds.urlString, method: .post)
        let requestBuilderSpy = URLRequestBuilderSpy()
        requestBuilderSpy.errorStub = Seeds.error
        
        let sut = createSUT(builder: requestBuilderSpy)

        let expectation = expectation(description: #function)
        
        sut.execute(request, type: TestModel.self) { resultReceived in
            switch resultReceived {
            case .failure(let errorReceived):
                XCTAssertEqual(errorReceived as HTTPRequestError, .request(Seeds.error))
            default:
                XCTFail()
            }
            expectation.fulfill()
        }
        
        URLProtocolMock.applySimulateWith(
            data: Seeds.dataValid,
            response: Seeds.createResponseWith(statusCode: 204),
            error: nil
        )
        
        wait(for: [expectation], timeout: 1)
    }
}

extension HTTPRequestDispatcherTests {
    func createSUT(builder: URLRequestBuilderProtocol = URLRequestBuilder(), decoder: JSONDecoder = .init()) -> HTTPRequestDispatcher {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        
        let sessionMock = URLSession(configuration: configuration)
        let sut = HTTPRequestDispatcher(session: sessionMock, builder: builder, decoder: decoder)
        
        memoryLeakCheckWith(instance: sut)
        
        return sut
    }
}

extension HTTPRequestDispatcherTests {
    func expectRequestWith(request: HTTPRequestSpy, completion: @escaping (URLRequest) -> Void) {
        let sut = createSUT()
        
        let expectation = expectation(description: #function)
        sut.execute(request, type: TestModel.self) { _ in expectation.fulfill() }
        var request: URLRequest!
        URLProtocolMock.observerRequest { request = $0 }
        wait(for: [expectation], timeout: 1)
        completion(request)
    }
}

extension HTTPRequestDispatcherTests {
    func expectResultWith<ResponseType: Codable>(
        request: HTTPRequestProtocol = HTTPRequestSpy(url: Seeds.urlString, method: .post),
        type: ResponseType.Type,
        resultExpected: (Result<Data?, HTTPRequestError>),
        andWith stub: (data: Data?, response: HTTPURLResponse?, error: Error?),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = createSUT()
        
        let expectation = expectation(description: #function)
        sut.execute(request, type: type) { resultReceived in
            switch (resultExpected, resultReceived) {
            case (.success(let dataExpected), .success(let dataReceived)):
                XCTAssertEqual(dataExpected, try! dataReceived.convertToData(), file: file, line: line)
            case (.failure(let errorExpected), .failure(let errorReceived)):
                XCTAssertEqual((errorExpected as NSError).code, (errorReceived as NSError).code, file: file, line: line)
                XCTAssertEqual((errorExpected as NSError).domain, (errorReceived as NSError).domain, file: file, line: line)
            default:
                XCTFail("Received \(resultReceived) this \(resultExpected) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        URLProtocolMock.applySimulateWith(data: stub.data, response: stub.response, error: stub.error)
        wait(for: [expectation], timeout: 1)
    }
}
