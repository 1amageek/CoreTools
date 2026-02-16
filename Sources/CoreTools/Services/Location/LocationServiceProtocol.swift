import CoreLocation

public protocol LocationServiceProtocol: Sendable {
    func requestCurrentLocation() async throws -> CLLocation
    func geocode(address: String) async throws -> [CLPlacemark]
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> CLPlacemark
    func startRegionMonitoring(identifier: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) async throws
    func stopRegionMonitoring(identifier: String) async throws
}
