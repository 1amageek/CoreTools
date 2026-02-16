import OpenFoundationModels

@Generable
public struct ContactDetail: Sendable {
    @Guide(description: "Unique identifier of the contact")
    public var identifier: String

    @Guide(description: "Given (first) name")
    public var givenName: String

    @Guide(description: "Family (last) name")
    public var familyName: String

    @Guide(description: "Phone numbers")
    public var phones: [LabeledValue]

    @Guide(description: "Email addresses")
    public var emails: [LabeledValue]

    @Guide(description: "Postal addresses")
    public var addresses: [PostalAddress]

    @Guide(description: "Organization name")
    public var organization: String?

    @Guide(description: "Job title")
    public var jobTitle: String?

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(identifier: String, givenName: String, familyName: String, phones: [LabeledValue], emails: [LabeledValue], addresses: [PostalAddress], organization: String?, jobTitle: String?, message: String) {
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.phones = phones
        self.emails = emails
        self.addresses = addresses
        self.organization = organization
        self.jobTitle = jobTitle
        self.message = message
    }
}
