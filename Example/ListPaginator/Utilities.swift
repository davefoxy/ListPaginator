import Foundation
import ListPaginator

extension ListPaginator.Status {
    var description: String {
        switch self {
        case .initial:
            return "Initial"
        case let .idle(hasMore):
            return "Idle (Has More: \(hasMore))"
        case .fetching:
            return "Fetching"
        case .error:
            return "Error"
        }
    }
}

protocol ExampleViewController {
    func clearAll()
}
