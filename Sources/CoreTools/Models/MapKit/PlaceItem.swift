import OpenFoundationModels

@Generable
public struct PlaceItem: Sendable {
    @Guide(description: "Name of the place")
    public var name: String

    @Guide(description: "Coordinate of the place")
    public var coordinate: Coordinate

    @Guide(description: "Formatted address")
    public var address: String

    @Guide(description: "Phone number, if available")
    public var phone: String?

    @Guide(description: "Category or type of place")
    public var category: String?

    public init(name: String, coordinate: Coordinate, address: String, phone: String?, category: String?) {
        self.name = name
        self.coordinate = coordinate
        self.address = address
        self.phone = phone
        self.category = category
    }
}
