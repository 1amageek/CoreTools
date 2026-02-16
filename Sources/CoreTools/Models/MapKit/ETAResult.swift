
@Generable
public struct ETAResult: Sendable {
    @Guide(description: "Estimated travel time in seconds")
    public var travelTime: Double

    @Guide(description: "Distance in meters")
    public var distance: Double

    @Guide(description: "Expected arrival time as ISO 8601 string")
    public var arrivalTime: String

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(travelTime: Double, distance: Double, arrivalTime: String, message: String) {
        self.travelTime = travelTime
        self.distance = distance
        self.arrivalTime = arrivalTime
        self.message = message
    }
}
