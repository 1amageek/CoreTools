import CoreLocation

public struct StartRegionMonitoringTool: Tool {
    public let name = "location_start_region_monitoring"
    public let description = "Start monitoring a geographic region for entry and exit events"

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Unique identifier for the region")
        public var identifier: String

        @Guide(description: "Center latitude of the region", .range(-90...90))
        public var latitude: Double

        @Guide(description: "Center longitude of the region", .range(-180...180))
        public var longitude: Double

        @Guide(description: "Radius of the region in meters", .range(1...100000))
        public var radius: Double

        @Guide(description: "User consent to start region monitoring")
        public var consent: Bool
    }

    private let service: any LocationServiceProtocol

    public init(service: any LocationServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> RegionMonitoringResult {
        guard arguments.consent else {
            throw CoreToolsError.permissionDenied(framework: "CoreLocation", detail: "User consent is required to start region monitoring")
        }
        let center = CLLocationCoordinate2D(latitude: arguments.latitude, longitude: arguments.longitude)
        try await service.startRegionMonitoring(identifier: arguments.identifier, center: center, radius: arguments.radius)
        return RegionMonitoringResult(
            regionIdentifier: arguments.identifier,
            action: "started",
            message: "Region monitoring started for '\(arguments.identifier)'"
        )
    }
}
