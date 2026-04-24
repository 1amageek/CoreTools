import CoreLocation

public struct StopRegionMonitoringTool: Tool {
    public let name = "location_stop_region_monitoring"
    public let description = """
        Stop monitoring a geographic region by its identifier.

        Usage:
        - Provide the identifier used when the region was registered with location_start_region_monitoring
        - The consent parameter MUST be true
        - The call will FAIL if the identifier does not match any monitored region
        """

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Identifier of the region to stop monitoring")
        public var identifier: String

        @Guide(description: "User consent to stop region monitoring")
        public var consent: Bool
    }

    private let service: any LocationServiceProtocol

    public init(service: any LocationServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> RegionMonitoringResult {
        guard arguments.consent else {
            throw CoreToolsError.permissionDenied(framework: "CoreLocation", detail: "User consent is required to stop region monitoring")
        }
        try await service.stopRegionMonitoring(identifier: arguments.identifier)
        return RegionMonitoringResult(
            regionIdentifier: arguments.identifier,
            action: "stopped",
            message: "Region monitoring stopped for '\(arguments.identifier)'"
        )
    }
}

extension StopRegionMonitoringTool: ToolIconProviding {
    public var iconSystemName: String { "location.fill" }
}
