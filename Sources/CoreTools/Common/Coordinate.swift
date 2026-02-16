import OpenFoundationModels

@Generable
public struct Coordinate: Sendable {
    @Guide(description: "Latitude in degrees", .range(-90...90))
    public var latitude: Double

    @Guide(description: "Longitude in degrees", .range(-180...180))
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
