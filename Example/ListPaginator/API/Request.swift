import Foundation
import Combine

protocol Request {
    associatedtype ResponseType: Decodable
    typealias Result = Swift.Result<ResponseType, Error>
    var url: URL { get }
}

var simulateAPIError = false

enum MockError: Error {
    case error
}

extension Request {
    var request: AnyPublisher<Result, Never> {
        Just(()).flatMap {
            URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: ResponseType.self, decoder: JSONDecoder())
                .map {
                    if simulateAPIError {
                        simulateAPIError = false
                        return .failure(MockError.error)
                    } else {
                        return .success($0)
                    }
                }
                .catch { error in
                    Just(.failure(error))
                }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func performRequest(completion: @escaping (Result) -> Void) {
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            DispatchQueue.main.async {
                if simulateAPIError {
                    completion(.failure(MockError.error))
                    simulateAPIError = false
                } else {
                    let obj = try! JSONDecoder().decode(ResponseType.self, from: data!)
                    completion(.success(obj))
                }
            }
        }.resume()
    }
}
