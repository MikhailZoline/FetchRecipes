//
//  NetworkingTests.swift
//
//
//  Created by Mikhail Zoline on 10/17/24.
//
import XCTest
import Combine
@testable import Networking

typealias ResponseType = Networking.ResponseType
typealias NetworkingError = Networking.NetworkingError

final class NetworkingTests: XCTestCase {
    static var recipeModelPublisher: CurrentValueSubject<Result<ResponseType, NetworkingError>, Never>?
    static var result: ResponseType?
    static var error: NetworkingError?
    static var resultExpectation = XCTestExpectation(description: "Success 3")
    static var emptyExpectation = XCTestExpectation(description: "Success 0")
    static var errorExpectation = XCTestExpectation(description: "Error")
    static let defaultURL: URL = .init(fileURLWithPath: "")
     
    override func setUp() async throws {
        XCTAssertNotNil(Networking.demoData)
        XCTAssertEqual(Networking.demoData?.count, 1)
        Networking.recipeModelPublisher.send(.success(Networking.demoData ?? []))
        NetworkingTests.recipeModelPublisher = Networking.recipeModelPublisher
        XCTAssertNotNil(Self.recipeModelPublisher)
        NetworkingTests.recipeModelPublisher?.sink { _ in }
            receiveValue: {
                switch $0 {
                case .success(let response):
                    NetworkingTests.result = response
                    if response.count == 3 {
                        NetworkingTests.resultExpectation.fulfill()
                    }
                    if response.count == 0 {
                        NetworkingTests.emptyExpectation.fulfill()
                    }
                case .failure(let error):
                    NetworkingTests.error = error
                    NetworkingTests.errorExpectation.fulfill()
                }
            }.store(in: &Networking.cancellables)
        XCTAssertEqual(NetworkingTests.result?.count, 1)
    }
    
    func testExample() async throws {
        //Test happy path
        var url: URL? = Bundle.module.url(forResource: Networking.RequestType.demoData.rawValue, withExtension: ".json")
        XCTAssertNotNil(url)
        XCTAssertEqual(NetworkingTests.result?.count, 1)
        Networking.loadRequest(with: url ?? NetworkingTests.defaultURL)
        wait(for: [NetworkingTests.resultExpectation], timeout: 0.1)
        XCTAssertEqual(NetworkingTests.result?.count, 3)
        
        //Test empty Data
        url = Bundle.module.url(forResource: Networking.RequestType.emptyData.rawValue, withExtension: ".json")
        XCTAssertNotNil(url)
        Networking.loadRequest(with: url ?? .init(fileURLWithPath: ""))
        wait(for: [NetworkingTests.emptyExpectation], timeout: 0.1)
        XCTAssertEqual(NetworkingTests.result?.count, 0)
        
        //Test malformed Data
        url = Bundle.module.url(forResource: Networking.RequestType.malformedData.rawValue, withExtension: ".json")
        XCTAssertNotNil(url)
        Networking.loadRequest(with: url ?? .init(fileURLWithPath: ""))
        wait(for: [NetworkingTests.errorExpectation], timeout: 0.1)
        XCTAssertNotEqual(NetworkingTests.error, nil)
        XCTAssertEqual(NetworkingTests.error?.kind.value, Networking.FailureReason.decodingFailed.value)
    }
}
