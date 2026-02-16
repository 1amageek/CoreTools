import OpenFoundationModels

public struct ScheduleTimeNotificationTool: Tool {
    public let name = "notification_schedule_time"
    public let description = "Schedule a notification to fire after a time interval"

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Unique identifier for the notification")
        public var identifier: String

        @Guide(description: "Title of the notification")
        public var title: String

        @Guide(description: "Body text of the notification")
        public var body: String

        @Guide(description: "Time interval in seconds until the notification fires", .range(1...86400))
        public var timeInterval: Double

        @Guide(description: "Whether the notification should repeat")
        public var repeats: Bool

        @Guide(description: "User consent to schedule the notification")
        public var consent: Bool
    }

    private let service: any NotificationServiceProtocol

    public init(service: any NotificationServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> ScheduledNotificationResult {
        guard arguments.consent else {
            throw CoreToolsError.permissionDenied(framework: "UserNotifications", detail: "User consent is required to schedule a notification")
        }
        try await service.scheduleTimeInterval(
            identifier: arguments.identifier,
            title: arguments.title,
            body: arguments.body,
            timeInterval: arguments.timeInterval,
            repeats: arguments.repeats
        )
        return ScheduledNotificationResult(
            identifier: arguments.identifier,
            title: arguments.title,
            triggerDescription: "After \(Int(arguments.timeInterval)) seconds\(arguments.repeats ? " (repeating)" : "")",
            message: "Notification '\(arguments.title)' scheduled"
        )
    }
}
