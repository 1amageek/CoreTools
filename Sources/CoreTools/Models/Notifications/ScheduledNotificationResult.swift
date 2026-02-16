
@Generable
public struct ScheduledNotificationResult: Sendable {
    @Guide(description: "Identifier of the scheduled notification")
    public var identifier: String

    @Guide(description: "Title of the notification")
    public var title: String

    @Guide(description: "Trigger description")
    public var triggerDescription: String

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(identifier: String, title: String, triggerDescription: String, message: String) {
        self.identifier = identifier
        self.title = title
        self.triggerDescription = triggerDescription
        self.message = message
    }
}
