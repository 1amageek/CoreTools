import OpenFoundationModels

@Generable
public struct LocationResult: Sendable {
    @Guide(description: "The coordinate of the current location")
    public var coordinate: Coordinate

    @Guide(description: "Altitude in meters")
    public var altitude: Double

    @Guide(description: "Horizontal accuracy in meters")
    public var accuracy: Double

    @Guide(description: "Reverse-geocoded address string, if available")
    public var address: String?

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(coordinate: Coordinate, altitude: Double, accuracy: Double, address: String?, message: String) {
        self.coordinate = coordinate
        self.altitude = altitude
        self.accuracy = accuracy
        self.address = address
        self.message = message
    }
}
