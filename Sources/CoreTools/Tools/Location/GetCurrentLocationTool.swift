import CoreLocation

public struct GetCurrentLocationTool: Tool {
    public let name = "location_get_current"
    public let description = """
        Get the current device location including coordinates, altitude, and address.

        ALWAYS call this tool when the user asks where they are, their current location, or anything about nearby surroundings.

        Usage:
        - Returns latitude, longitude, altitude, horizontal accuracy, and a reverse-geocoded address
        - The result coordinates are suitable for displaying map visualization
        - Accuracy depends on device hardware and environment; check the accuracy field
        - Use location_geocode or location_reverse_geocode for address-to-coordinate conversions instead
        """

    @Generable
    public struct Arguments: Sendable {}

    private let service: any LocationServiceProtocol

    public init(service: any LocationServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> LocationResult {
        let location = try await service.requestCurrentLocation()
        var address: String?
        if let placemark = try? await service.reverseGeocode(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ) {
            address = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.country]
                .compactMap { $0 }
                .joined(separator: ", ")
        }
        return LocationResult(
            coordinate: Coordinate(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            ),
            altitude: location.altitude,
            accuracy: location.horizontalAccuracy,
            address: address,
            message: "Current location retrieved successfully"
        )
    }
}

extension GetCurrentLocationTool: ToolIconProviding {
    public var iconSystemName: String { "location.fill" }
}
