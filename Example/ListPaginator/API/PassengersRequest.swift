import Foundation

public struct PassengersRequest: Request {
    typealias ResponseType = PassengersResponse

    var url: URL { URL(string: "https://api.instantwebtools.net/v1/passenger?page=\(page)&size=20")! }

    let page: Int
}

public struct PassengersResponse: Decodable {
    let passengers: [Passenger]

    public enum CodingKeys: String, CodingKey {
        case passengers = "data"
    }
}

public struct Passenger: Decodable, Identifiable {
    public let id: String
    let name: String

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}
