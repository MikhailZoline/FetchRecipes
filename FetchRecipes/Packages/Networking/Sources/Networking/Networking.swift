// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Combine
import Models

public enum Networking {
    
    public enum FailureReason: Error {
        case invalidURL(error: URLError)
        case sessionFailed(error: URLError)
        case decodingFailed
        case emptyData(error: URLError)
        case other(Error)
    }
    
    public struct NetworkingError: Error, LocalizedError, Equatable {
        var kind: FailureReason
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.toString == rhs.toString
        }
        
        public var errorDescription: String? {
            return self.toString
        }
        
        public var toString: String {
            switch kind {
            case .invalidURL(let error):
                return "Invalid URL \(error)"
            case .sessionFailed(let error):
                return "SessionFailed \(error)"
            case .decodingFailed:
                return "Malformed Data"
            case .emptyData(let error):
                return "Empty Data \(error)"
            case .other(let error):
                return "Other \(error)"
            }
        }
    }
    
    public enum RequestType: String {
        case allRecipes = "AllRecipes"
        case malformedData = "MalformedRecipes"
        case emptyData = "EmptyRecipes"
        case demoData = "DemoRecipes"
    }
    
    public static func url(for requestType: RequestType) -> URL? {
        return Bundle.main.url(forResource: requestType.rawValue, withExtension: "json")
    }
    
    public static var cancellables = Set<AnyCancellable>()
    
    public typealias ResponseType = [Models.Recipe.ViewModel]
    
    public static let recipeModelPublisher = CurrentValueSubject<Result<ResponseType, NetworkingError>, Never>(.success(ResponseType()))
    
 /*
    public typealias ExpectedResponse = Decodable
    
    public static func request<ExpectedResponse: Decodable>(url: URL, expectedResponseType: ExpectedResponse.Type) -> AnyPublisher<Result<ExpectedResponse, NetworkingError>, Never> {
        
        URLSession.shared.dataTaskPublisher(for: url)
            .mapError { return NetworkingError(kind: .sessionFailed(error: $0)) }
            .tryMap() {
                guard $0.data.count > 0 else {
                    throw NetworkingError(kind: .emptyData(error: URLError(.zeroByteResource)))
                }
                return $0.data
            }
            .decode(type: ExpectedResponse.self, decoder: JSONDecoder())
            .map { Result<ExpectedResponse, NetworkingError>.success($0)}
            .mapError { _ in NetworkingError(kind: .decodingFailed) }
            .catch { Just<Result<ExpectedResponse, NetworkingError>>(.failure($0)) }
            .eraseToAnyPublisher()
        
    }
 */
    
    public static func loadRequest(with url: URL) {
        
        URLSession.shared.dataTaskPublisher(for: url)
            .mapError { return NetworkingError(kind: .sessionFailed(error: $0)) }
            .tryMap() {
                guard $0.data.count > 0 else {
                    throw NetworkingError(kind: .emptyData(error: URLError(.zeroByteResource)))
                }
                return $0.data
            }
            .mapError { _ in NetworkingError(kind: .emptyData(error: URLError(.zeroByteResource))) }
            .decode(type: [String: [Models.RecipeShape]].self, decoder: JSONDecoder())
            .map { .success($0) }
            .mapError { _ in NetworkingError(kind: .decodingFailed) }
            .catch { Just<Result< _, NetworkingError>>(.failure($0)) }
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in }
                receiveValue: {
                    switch $0 {
                    case .success(let response):
                        print("Recived response")
                        recipeModelPublisher.send(
                            .success(
                                response.first?.value.map(\.toViewModel).sorted {
                                    return $0.cuisine < $1.cuisine
                                } ?? []
                            )
                        )
                    case .failure(let error):
                        recipeModelPublisher.send(.failure(error))
                        print("\(error.toString)")
                    }
             }.store(in: &cancellables)
        }
    
}

public extension Networking.NetworkingError {
    init(_ kind: Networking.FailureReason) {
        self.init(kind: kind)
    }
}
