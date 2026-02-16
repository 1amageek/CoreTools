import OpenFoundationModels

@Generable
public struct RegionMonitoringResult: Sendable {
    @Guide(description: "Identifier of the monitored region")
    public var regionIdentifier: String

    @Guide(description: "Action performed: started or stopped", .anyOf(["started", "stopped"]))
    public var action: String

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(regionIdentifier: String, action: String, message: String) {
        self.regionIdentifier = regionIdentifier
        self.action = action
        self.message = message
    }
}
