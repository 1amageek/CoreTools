
@Generable
public struct CancelNotificationResult: Sendable, PromptRepresentable {
    @Guide(description: "Identifiers of cancelled notifications")
    public var cancelledIdentifiers: [String]

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(cancelledIdentifiers: [String], message: String) {
        self.cancelledIdentifiers = cancelledIdentifiers
        self.message = message
    }
}
