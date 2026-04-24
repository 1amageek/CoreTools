import Foundation

public struct ListPendingNotificationsTool: Tool {
    public let name = "notification_list_pending"
    public let description = """
        List all pending scheduled notifications.

        ALWAYS call this tool when the user asks about their reminders, scheduled notifications, or what's pending.

        Usage:
        - Returns all notifications that have been scheduled but not yet delivered
        - Each item includes identifier, title, body, and next trigger date in ISO 8601 format
        - ALWAYS use this tool before notification_cancel to obtain valid identifiers
        - Returns an empty list if no notifications are pending
        """

    @Generable
    public struct Arguments: Sendable {}

    private let service: any NotificationServiceProtocol

    public init(service: any NotificationServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> PendingNotificationList {
        let pending = try await service.listPending()
        let formatter = ISO8601DateFormatter()
        let items = pending.map { notification in
            PendingNotificationItem(
                identifier: notification.identifier,
                title: notification.title,
                body: notification.body,
                nextTriggerDate: notification.nextTriggerDate.map { formatter.string(from: $0) }
            )
        }
        return PendingNotificationList(
            items: items,
            message: "\(items.count) pending notification(s)"
        )
    }
}

extension ListPendingNotificationsTool: ToolIconProviding {
    public var iconSystemName: String { "bell.fill" }
}
