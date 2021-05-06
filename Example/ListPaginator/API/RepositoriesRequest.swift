import Foundation

/**
 Note that this request is strongly rate-limited. Requests made wll begin failing fairly quickly after multiple fetches.
 */
struct RepositoriesRequest: Request {
    typealias ResponseType = Repositories

    var url: URL { URL(string: "https://api.github.com/search/repositories?q=language:swift&per_page=30&page=\(page)")! }

    let page: Int
}

struct Repositories: Decodable {
    let totalCount: Int
    let repositories: [Repository]

    public enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case repositories = "items"
    }
}

struct Repository: Decodable, Identifiable {
    let id: Int
    let name: String
    let fullName: String
    let watchersCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case watchersCount = "watchers_count"
    }
}
