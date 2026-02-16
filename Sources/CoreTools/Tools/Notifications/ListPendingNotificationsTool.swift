import OpenFoundationModels
import Foundation

public struct ListPendingNotificationsTool: Tool {
    public let name = "notification_list_pending"
    public let description = "List all pending scheduled notifications"

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
