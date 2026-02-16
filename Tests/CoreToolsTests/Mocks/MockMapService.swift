import MapKit
@testable import CoreTools

final class MockMapService: MapServiceProtocol, @unchecked Sendable {
    var searchResult: [MKMapItem] = []
    var routeResult: MKRoute?
    var etaResult: MKDirections.ETAResponse?
    var placeDetailResult: MKMapItem?
    var shouldThrow: (any Error)?

    func searchPlaces(query: String, region: MKCoordinateRegion?) async throws -> [MKMapItem] {
        if let error = shouldThrow { throw error }
        return searchResult
    }

    func calculateRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, transportType: MKDirectionsTransportType) async throws -> MKRoute {
        if let error = shouldThrow { throw error }
        guard let route = routeResult else {
            throw CoreToolsError.notFound(resource: "route")
        }
        return route
    }

    func estimateETA(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, transportType: MKDirectionsTransportType) async throws -> MKDirections.ETAResponse {
        if let error = shouldThrow { throw error }
        guard let eta = etaResult else {
            throw CoreToolsError.notFound(resource: "eta")
        }
        return eta
    }

    func resolvePlaceDetails(query: String) async throws -> MKMapItem {
        if let error = shouldThrow { throw error }
        guard let item = placeDetailResult else {
            throw CoreToolsError.notFound(resource: "place")
        }
        return item
    }
}
