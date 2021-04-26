import Foundation
import Combine

public final class ListPaginator<Response, Item>: ObservableObject {
    /// Defines how the paginator should generate page numbers for building network requests. This will be based on how the target API works with paging.
    public enum PagingStrategy {
        /// For APIs which use a page index-based system. Typically an incrementing integer is sent as part of the request parameters. The  `startingFrom` associated value should provide the initial page number. You should typically pass `0` or `1` to define whether your endpoint is 0 or 1-based.
        case pageIndex(startingFrom: Int)

        /// For APIs which use an offset-based system. Typically an offset based on the last fetched *item*'s index is passed to subsequent requests. For example, passing 0 for page one, receiving 20 results and then passing 20 for the next request and so on.
        case itemOffset

        fileprivate var initialPage: Int {
            switch self {
            case let .pageIndex(startingFrom):
                return startingFrom
            case .itemOffset:
                return 0
            }
        }
    }

    /// Allows the client to choose between using a Combine publisher or a simple closure for fetching new pages of data.
    public enum RequestProvider {
        /// A Combine publisher which will perform a network request with a given page.  The publisher is expected to:
        /// 1. Return a Swift `Result`. The data type is expected to match this class's generic `Response` type.
        /// 2. Never fail. This approach is considered so requests may be retried if they fail. A failable publisher has the downside of finishing on error and makes retrying slightly more complex.
        case publisher((Int) -> AnyPublisher<Result<Response, Error>, Never>)

        /// A simple closure which will perform a network request with a given page. This closure should perform its work and call back the provided completion block with the result of its network request.
        case closure((Int, @escaping (Result<Response, Error>) -> Void) -> Void)
    }

    /// Tracks the current pagination status. Is used internally for blocking duplicate requests but this may also be observed to display progress indicators and error messages within the client application.
    public enum Status {
        /// The paginator has been instantiated but no network requests have been performed yet.
        case initial

        /// The paginator is idle and not performing any requests. The `hasMore` associated value dictates whether there are more objects to be fetched or not.
        case idle(hasMore: Bool)

        /// The paginator is currently fetching new items. This status may be used to display loading indicators in the client application.
        case fetching

        /// An error occured during the last request. This status may be used to display an error message and retry control in the client application.
        case error(Error)

        fileprivate var mayFetchMore: Bool {
            switch self {
            case .initial:
                return true
            case let .idle(hasMore):
                return hasMore
            case .fetching:
                return false
            case .error:
                return true
            }
        }
    }

    /// An array of view-ready `Item`s. Observable.
    @Published public private(set) var results = [Item]()

    /// The current pagination status. Observable.
    @Published public private(set) var status: Status = .initial

    /// An optional closure called after each page's request is made. Non-Combine implementations which choose not to make use of the @Published attributes of `results` and `status` may prefer to use this system for updating the client's UI.
    public var completionHandler: ((Result<Response, Error>) -> Void)?

    /// A passthrough subject which should be triggered when new data is to be fetched. Typically you will call `fetchMoreIfNeeded.send()` when users scroll near the bottom of paginated content.
    public let fetchMoreIfNeeded = PassthroughSubject<Void, Never>()

    /// Defines how requests are constructed. See the `PagingStrategy` documentation for details.
    public var strategy: PagingStrategy = .pageIndex(startingFrom: 0) {
        didSet { reset() }
    }

    /// A property which defines how the client application will provide data for ListPaginator to consume. ListPaginator currently supports network requests via either a Combine publisher or a simple Swift closure. Both are expected to return a Swift `Result` with the success data type matching this class's generic `Response` type. See the `RequestProvider` documentation for more details.
    public var requestProvider: RequestProvider?

    /// The keypath which defines where in the response object the target item array can be found.
    public var responseItemsKeyPath: KeyPath<Response, [Item]>?

    private var nextPage: Int = 0
    private var fetchCancellable: AnyCancellable?

    public init() {
        fetchCancellable = fetchMoreIfNeeded
            .filter { self.status.mayFetchMore }
            .map { self.status = .fetching }
            .flatMap { self.requestPublisher }
            .sink(receiveValue: { result in
                guard let responseItemsKeyPath = self.responseItemsKeyPath else {
                    fatalError("Missing configuration for responseItemsKeyPath property. This is required to inform ListPaginator how to find individual items within a response.")
                }

                switch result {
                case let .success(response):
                    let items = response[keyPath: responseItemsKeyPath]
                    self.results.append(contentsOf: items)

                    self.status = .idle(hasMore: !items.isEmpty)
                    self.advancePage(response: response, itemsKeyPath: responseItemsKeyPath)
                    self.completionHandler?(result)
                case let .failure(error):
                    self.status = .error(error)
                }
            })
    }

    private func advancePage(response: Response, itemsKeyPath: KeyPath<Response, [Item]>) {
        switch strategy {
        case .pageIndex:
            nextPage += 1
        case .itemOffset:
            nextPage += response[keyPath: itemsKeyPath].count
        }
    }

    private var requestPublisher: AnyPublisher<Result<Response, Error>, Never> {
        guard let requestProvider = requestProvider else {
            fatalError("Please configure ListPaginator with a valid requestProvider. This is required to inform ListPaginator how to perform network requests for new pages of data.")
        }

        switch requestProvider {
        case let .publisher(publisher):
            return publisher(nextPage)
        case let .closure(closure):
            return Deferred {
                Future<Result<Response, Error>, Never> { promise in
                    closure(self.nextPage, { result in
                        promise(.success(result))
                    })
                }
            }
            .eraseToAnyPublisher()
        }
    }

    /// Removes all results and resets the status and pagination offsets.
    public func reset() {
        results.removeAll()
        status = .initial
        nextPage = strategy.initialPage
    }
}
