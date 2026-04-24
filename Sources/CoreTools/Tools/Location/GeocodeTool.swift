import CoreLocation

public struct GeocodeTool: Tool {
    public let name = "location_geocode"
    public let description = """
        Convert an address string to geographic coordinates.

        ALWAYS call this tool when you need to convert an address or place name into latitude/longitude coordinates.

        Usage:
        - Provide a human-readable address (e.g., street address, city name, landmark)
        - May return multiple matching locations for ambiguous addresses
        - The result coordinates are suitable for displaying map visualization
        - For the reverse operation (coordinates to address), use location_reverse_geocode instead
        - The call will FAIL if the address cannot be resolved to any location
        """

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "The address string to geocode")
        public var address: String
    }

    private let service: any LocationServiceProtocol

    public init(service: any LocationServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> GeocodeResult {
        let placemarks = try await service.geocode(address: arguments.address)
        let locations = placemarks.compactMap { placemark -> GeocodeLocation? in
            guard let location = placemark.location else { return nil }
            let displayName = [placemark.name, placemark.locality, placemark.country]
                .compactMap { $0 }
                .joined(separator: ", ")
            return GeocodeLocation(
                coordinate: Coordinate(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                ),
                displayName: displayName
            )
        }
        return GeocodeResult(
            locations: locations,
            message: "Found \(locations.count) location(s) for '\(arguments.address)'"
        )
    }
}

extension GeocodeTool: ToolIconProviding {
    public var iconSystemName: String { "location.fill" }
}
