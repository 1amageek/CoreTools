import OpenFoundationModels

@Generable
public struct ContactSummary: Sendable {
    @Guide(description: "Unique identifier of the contact")
    public var identifier: String

    @Guide(description: "Given (first) name")
    public var givenName: String

    @Guide(description: "Family (last) name")
    public var familyName: String

    public init(identifier: String, givenName: String, familyName: String) {
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
    }
}
