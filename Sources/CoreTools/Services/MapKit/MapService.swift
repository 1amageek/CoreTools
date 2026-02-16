import MapKit

public struct MapService: MapServiceProtocol {

    public init() {}

    public func searchPlaces(query: String, region: MKCoordinateRegion?) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        if let region {
            request.region = region
        }
        let search = MKLocalSearch(request: request)
        let response: MKLocalSearch.Response
        do {
            response = try await search.start()
        } catch {
            throw CoreToolsError.operationFailed(operation: "searchPlaces", underlyingError: error)
        }
        return response.mapItems
    }

    public func calculateRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, transportType: MKDirectionsTransportType) async throws -> MKRoute {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = transportType
        let directions = MKDirections(request: request)
        let response: MKDirections.Response
        do {
            response = try await directions.calculate()
        } catch {
            throw CoreToolsError.operationFailed(operation: "calculateRoute", underlyingError: error)
        }
        guard let route = response.routes.first else {
            throw CoreToolsError.notFound(resource: "route")
        }
        return route
    }

    public func estimateETA(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, transportType: MKDirectionsTransportType) async throws -> MKDirections.ETAResponse {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = transportType
        let directions = MKDirections(request: request)
        do {
            return try await directions.calculateETA()
        } catch {
            throw CoreToolsError.operationFailed(operation: "estimateETA", underlyingError: error)
        }
    }

    public func resolvePlaceDetails(query: String) async throws -> MKMapItem {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        let response: MKLocalSearch.Response
        do {
            response = try await search.start()
        } catch {
            throw CoreToolsError.operationFailed(operation: "resolvePlaceDetails", underlyingError: error)
        }
        guard let item = response.mapItems.first else {
            throw CoreToolsError.notFound(resource: "place: \(query)")
        }
        return item
    }
}
