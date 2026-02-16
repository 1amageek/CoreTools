
@Generable
public struct PlaceDetail: Sendable {
    @Guide(description: "Name of the place")
    public var name: String

    @Guide(description: "Formatted address")
    public var address: String

    @Guide(description: "Phone number")
    public var phone: String?

    @Guide(description: "Website URL")
    public var url: String?

    @Guide(description: "Category or type of place")
    public var category: String?

    @Guide(description: "Coordinate of the place")
    public var coordinate: Coordinate

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(name: String, address: String, phone: String?, url: String?, category: String?, coordinate: Coordinate, message: String) {
        self.name = name
        self.address = address
        self.phone = phone
        self.url = url
        self.category = category
        self.coordinate = coordinate
        self.message = message
    }
}
