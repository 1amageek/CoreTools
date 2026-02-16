import OpenFoundationModels

@Generable
public struct PostalAddress: Sendable {
    @Guide(description: "Street address")
    public var street: String

    @Guide(description: "City")
    public var city: String

    @Guide(description: "State or province")
    public var state: String

    @Guide(description: "Postal code")
    public var postalCode: String

    @Guide(description: "Country")
    public var country: String

    public init(street: String, city: String, state: String, postalCode: String, country: String) {
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }
}
