import OpenFoundationModels
import MapKit

public struct CalculateRouteTool: Tool {
    public let name = "map_calculate_route"
    public let description = "Calculate a route between two locations with turn-by-turn directions"

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Origin latitude", .range(-90...90))
        public var fromLatitude: Double

        @Guide(description: "Origin longitude", .range(-180...180))
        public var fromLongitude: Double

        @Guide(description: "Destination latitude", .range(-90...90))
        public var toLatitude: Double

        @Guide(description: "Destination longitude", .range(-180...180))
        public var toLongitude: Double

        @Guide(description: "Transport type", .anyOf(["automobile", "walking", "transit"]))
        public var transportType: String
    }

    private let service: any MapServiceProtocol

    public init(service: any MapServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> RouteResult {
        let from = CLLocationCoordinate2D(latitude: arguments.fromLatitude, longitude: arguments.fromLongitude)
        let to = CLLocationCoordinate2D(latitude: arguments.toLatitude, longitude: arguments.toLongitude)
        let type = parseTransportType(arguments.transportType)
        let route = try await service.calculateRoute(from: from, to: to, transportType: type)
        let steps = route.steps.filter { !$0.instructions.isEmpty }.map { step in
            RouteStep(instructions: step.instructions, distance: step.distance)
        }
        return RouteResult(
            steps: steps,
            distance: route.distance,
            travelTime: route.expectedTravelTime,
            message: "Route calculated: \(formatDistance(route.distance)), \(formatTime(route.expectedTravelTime))"
        )
    }

    private func parseTransportType(_ value: String) -> MKDirectionsTransportType {
        switch value {
        case "walking": return .walking
        case "transit": return .transit
        default: return .automobile
        }
    }

    private func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        }
        return String(format: "%.0f m", meters)
    }

    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds / 60)
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)min"
        }
        return "\(minutes) min"
    }
}
