import Foundation

public struct PlaceListItem: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let address: String
    public let category: String?
    public let phone: String?
    public let coordinate: CoordinatePayload?

    public init(
        id: String,
        name: String,
        address: String,
        category: String? = nil,
        phone: String? = nil,
        coordinate: CoordinatePayload? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.category = category
        self.phone = phone
        self.coordinate = coordinate
    }
}

public struct PlaceListPayload: EmbeddedPayload {
    public let places: [PlaceListItem]

    public init(places: [PlaceListItem]) {
        self.places = places
    }

    public var hasMap: Bool { false }
    public var listCount: Int { places.count }
    public var formFieldCount: Int { 0 }
}
