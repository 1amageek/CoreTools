
@Generable
public struct ContactSearchResult: Sendable {
    @Guide(description: "List of matching contacts")
    public var contacts: [ContactSummary]

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(contacts: [ContactSummary], message: String) {
        self.contacts = contacts
        self.message = message
    }
}
