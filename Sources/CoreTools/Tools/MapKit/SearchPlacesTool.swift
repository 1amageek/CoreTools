import MapKit

public struct SearchPlacesTool: Tool {
    public let name = "map_search_places"
    public let description = "Search for places of interest by keyword or category"

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Search query for places")
        public var query: String

        @Guide(description: "Center latitude to bias search results", .range(-90...90))
        public var centerLatitude: Double?

        @Guide(description: "Center longitude to bias search results", .range(-180...180))
        public var centerLongitude: Double?
    }

    private let service: any MapServiceProtocol

    public init(service: any MapServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> PlaceSearchResult {
        var region: MKCoordinateRegion?
        if let lat = arguments.centerLatitude, let lon = arguments.centerLongitude {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                latitudinalMeters: 10000,
                longitudinalMeters: 10000
            )
        }
        let items = try await service.searchPlaces(query: arguments.query, region: region)
        let places = items.map { item -> PlaceItem in
            let address = [item.placemark.thoroughfare, item.placemark.locality, item.placemark.administrativeArea, item.placemark.country]
                .compactMap { $0 }
                .joined(separator: ", ")
            return PlaceItem(
                name: item.name ?? "Unknown",
                coordinate: Coordinate(
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                ),
                address: address,
                phone: item.phoneNumber,
                category: item.pointOfInterestCategory?.rawValue
            )
        }
        return PlaceSearchResult(
            places: places,
            message: "Found \(places.count) place(s) for '\(arguments.query)'"
        )
    }
}
