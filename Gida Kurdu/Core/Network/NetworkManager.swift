import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

protocol NetworkManagerProtocol {
    func fetch<T: Decodable>(from endpoint: String) -> AnyPublisher<T, NetworkError>
    func fetchWithURLRequest<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, NetworkError>
}

final class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    func fetch<T: Decodable>(from endpoint: String) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return fetchWithURLRequest(URLRequest(url: url))
    }
    
    func fetchWithURLRequest<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, NetworkError> {
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.serverError("Invalid response")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return NetworkError.decodingError
            }
            .eraseToAnyPublisher()
    }
} 