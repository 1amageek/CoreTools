import MapKit

public protocol MapServiceProtocol: Sendable {
    func searchPlaces(query: String, region: MKCoordinateRegion?) async throws -> [MKMapItem]
    func calculateRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, transportType: MKDirectionsTransportType) async throws -> MKRoute
    func estimateETA(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, transportType: MKDirectionsTransportType) async throws -> MKDirections.ETAResponse
    func resolvePlaceDetails(query: String) async throws -> MKMapItem
}
