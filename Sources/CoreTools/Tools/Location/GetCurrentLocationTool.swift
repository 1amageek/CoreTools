import OpenFoundationModels
import CoreLocation

public struct GetCurrentLocationTool: Tool {
    public let name = "location_get_current"
    public let description = "Get the current device location including coordinates, altitude, and address"

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
