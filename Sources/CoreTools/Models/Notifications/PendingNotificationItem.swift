
@Generable
public struct PendingNotificationItem: Sendable {
    @Guide(description: "Notification identifier")
    public var identifier: String

    @Guide(description: "Notification title")
    public var title: String

    @Guide(description: "Notification body")
    public var body: String

    @Guide(description: "Next trigger date as ISO 8601 string")
    public var nextTriggerDate: String?

    public init(identifier: String, title: String, body: String, nextTriggerDate: String?) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.nextTriggerDate = nextTriggerDate
    }
}
