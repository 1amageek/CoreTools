import MapKit

public struct ResolvePlaceDetailsTool: Tool {
    public let name = "map_resolve_place_details"
    public let description = """
        Retrieve detailed information about a single place by name.

        ALWAYS call this tool when the user asks about a specific named place, landmark, or station.

        Usage:
        - Provide a specific place name or query (e.g., "Tokyo Skytree", "Shibuya Station")
        - Returns name, address, phone number, URL, category, and coordinates
        - The result coordinates are suitable for displaying as a pin map visualization
        - For searching multiple places by keyword or category, use map_search_places instead
        """

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Name or query of the place to look up")
        public var query: String
    }

    private let service: any MapServiceProtocol

    public init(service: any MapServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> PlaceDetail {
        let item = try await service.resolvePlaceDetails(query: arguments.query)
        let address = [item.placemark.thoroughfare, item.placemark.locality, item.placemark.administrativeArea, item.placemark.country]
            .compactMap { $0 }
            .joined(separator: ", ")
        return PlaceDetail(
            name: item.name ?? arguments.query,
            address: address,
            phone: item.phoneNumber,
            url: item.url?.absoluteString,
            category: item.pointOfInterestCategory?.rawValue,
            coordinate: Coordinate(
                latitude: item.placemark.coordinate.latitude,
                longitude: item.placemark.coordinate.longitude
            ),
            message: "Place details resolved for '\(arguments.query)'"
        )
    }
}

extension ResolvePlaceDetailsTool: ToolIconProviding {
    public var iconSystemName: String { "map.fill" }
}
