import OpenFoundationModels

@Generable
public struct PendingNotificationList: Sendable {
    @Guide(description: "List of pending notifications")
    public var items: [PendingNotificationItem]

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(items: [PendingNotificationItem], message: String) {
        self.items = items
        self.message = message
    }
}
