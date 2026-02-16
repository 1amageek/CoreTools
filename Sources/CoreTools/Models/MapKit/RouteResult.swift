
@Generable
public struct RouteResult: Sendable {
    @Guide(description: "Turn-by-turn route steps")
    public var steps: [RouteStep]

    @Guide(description: "Total distance in meters")
    public var distance: Double

    @Guide(description: "Estimated travel time in seconds")
    public var travelTime: Double

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(steps: [RouteStep], distance: Double, travelTime: Double, message: String) {
        self.steps = steps
        self.distance = distance
        self.travelTime = travelTime
        self.message = message
    }
}
