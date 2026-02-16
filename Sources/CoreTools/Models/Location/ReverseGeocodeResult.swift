import OpenFoundationModels

@Generable
public struct ReverseGeocodeResult: Sendable {
    @Guide(description: "Full formatted address")
    public var address: String

    @Guide(description: "City or locality name")
    public var locality: String?

    @Guide(description: "State or administrative area")
    public var administrativeArea: String?

    @Guide(description: "Country name")
    public var country: String?

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(address: String, locality: String?, administrativeArea: String?, country: String?, message: String) {
        self.address = address
        self.locality = locality
        self.administrativeArea = administrativeArea
        self.country = country
        self.message = message
    }
}
