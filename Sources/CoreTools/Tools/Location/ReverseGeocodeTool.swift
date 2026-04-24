import CoreLocation

public struct ReverseGeocodeTool: Tool {
    public let name = "location_reverse_geocode"
    public let description = """
        Convert geographic coordinates to a human-readable address.

        ALWAYS call this tool when you have coordinates and need to find the corresponding address.

        Usage:
        - Provide latitude (-90 to 90) and longitude (-180 to 180) in degrees
        - Returns a formatted address with locality, administrative area, and country
        - For the reverse operation (address to coordinates), use location_geocode instead
        - The call will FAIL if the coordinates do not correspond to a known address
        """

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Latitude in degrees", .range(-90...90))
        public var latitude: Double

        @Guide(description: "Longitude in degrees", .range(-180...180))
        public var longitude: Double
    }

    private let service: any LocationServiceProtocol

    public init(service: any LocationServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> ReverseGeocodeResult {
        let placemark = try await service.reverseGeocode(latitude: arguments.latitude, longitude: arguments.longitude)
        let address = [placemark.name, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.country]
            .compactMap { $0 }
            .joined(separator: ", ")
        return ReverseGeocodeResult(
            address: address,
            locality: placemark.locality,
            administrativeArea: placemark.administrativeArea,
            country: placemark.country,
            message: "Reverse geocode completed successfully"
        )
    }
}

extension ReverseGeocodeTool: ToolIconProviding {
    public var iconSystemName: String { "location.fill" }
}
