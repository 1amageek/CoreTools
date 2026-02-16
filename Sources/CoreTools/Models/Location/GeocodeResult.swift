
@Generable
public struct GeocodeLocation: Sendable {
    @Guide(description: "Coordinate of the geocoded location")
    public var coordinate: Coordinate

    @Guide(description: "Display name or formatted address")
    public var displayName: String

    public init(coordinate: Coordinate, displayName: String) {
        self.coordinate = coordinate
        self.displayName = displayName
    }
}

@Generable
public struct GeocodeResult: Sendable {
    @Guide(description: "List of geocoded locations")
    public var locations: [GeocodeLocation]

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(locations: [GeocodeLocation], message: String) {
        self.locations = locations
        self.message = message
    }
}
