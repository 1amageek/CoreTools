
@Generable
public struct ContactMutationResult: Sendable {
    @Guide(description: "Identifier of the created or updated contact")
    public var identifier: String

    @Guide(description: "Action performed: created or updated", .anyOf(["created", "updated"]))
    public var action: String

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(identifier: String, action: String, message: String) {
        self.identifier = identifier
        self.action = action
        self.message = message
    }
}
