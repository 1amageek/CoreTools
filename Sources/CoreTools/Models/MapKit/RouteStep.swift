
@Generable
public struct RouteStep: Sendable {
    @Guide(description: "Human-readable instruction for this step")
    public var instructions: String

    @Guide(description: "Distance of this step in meters")
    public var distance: Double

    public init(instructions: String, distance: Double) {
        self.instructions = instructions
        self.distance = distance
    }
}
