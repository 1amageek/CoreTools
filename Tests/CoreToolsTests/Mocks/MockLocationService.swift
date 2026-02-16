import CoreLocation
@testable import CoreTools

final class MockLocationService: LocationServiceProtocol, @unchecked Sendable {
    var currentLocation = CLLocation(latitude: 35.6812, longitude: 139.7671)
    var geocodeResult: [CLPlacemark] = []
    var reverseGeocodeResult: CLPlacemark?
    var shouldThrow: (any Error)?

    func requestCurrentLocation() async throws -> CLLocation {
        if let error = shouldThrow { throw error }
        return currentLocation
    }

    func geocode(address: String) async throws -> [CLPlacemark] {
        if let error = shouldThrow { throw error }
        return geocodeResult
    }

    func reverseGeocode(latitude: Double, longitude: Double) async throws -> CLPlacemark {
        if let error = shouldThrow { throw error }
        guard let placemark = reverseGeocodeResult else {
            throw CoreToolsError.notFound(resource: "location")
        }
        return placemark
    }

    func startRegionMonitoring(identifier: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) async throws {
        if let error = shouldThrow { throw error }
    }

    func stopRegionMonitoring(identifier: String) async throws {
        if let error = shouldThrow { throw error }
    }
}
