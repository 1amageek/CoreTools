import MapKit
import Foundation

public struct EstimateETATool: Tool {
    public let name = "map_estimate_eta"
    public let description = "Estimate the travel time and arrival time between two locations"

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

    public func call(arguments: Arguments) async throws -> ETAResult {
        let from = CLLocationCoordinate2D(latitude: arguments.fromLatitude, longitude: arguments.fromLongitude)
        let to = CLLocationCoordinate2D(latitude: arguments.toLatitude, longitude: arguments.toLongitude)
        let type = parseTransportType(arguments.transportType)
        let eta = try await service.estimateETA(from: from, to: to, transportType: type)
        let arrivalDate = Date().addingTimeInterval(eta.expectedTravelTime)
        let formatter = ISO8601DateFormatter()
        return ETAResult(
            travelTime: eta.expectedTravelTime,
            distance: eta.distance,
            arrivalTime: formatter.string(from: arrivalDate),
            message: "ETA: \(formatTime(eta.expectedTravelTime))"
        )
    }

    private func parseTransportType(_ value: String) -> MKDirectionsTransportType {
        switch value {
        case "walking": return .walking
        case "transit": return .transit
        default: return .automobile
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds / 60)
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)min"
        }
        return "\(minutes) min"
    }
}
