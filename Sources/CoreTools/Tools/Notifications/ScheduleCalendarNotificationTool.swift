import OpenFoundationModels

public struct ScheduleCalendarNotificationTool: Tool {
    public let name = "notification_schedule_calendar"
    public let description = "Schedule a notification at a specific calendar date and time"

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Unique identifier for the notification")
        public var identifier: String

        @Guide(description: "Title of the notification")
        public var title: String

        @Guide(description: "Body text of the notification")
        public var body: String

        @Guide(description: "Year component")
        public var year: Int?

        @Guide(description: "Month component (1-12)")
        public var month: Int?

        @Guide(description: "Day component (1-31)")
        public var day: Int?

        @Guide(description: "Hour component (0-23)")
        public var hour: Int?

        @Guide(description: "Minute component (0-59)")
        public var minute: Int?

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
        try await service.scheduleCalendar(
            identifier: arguments.identifier,
            title: arguments.title,
            body: arguments.body,
            year: arguments.year,
            month: arguments.month,
            day: arguments.day,
            hour: arguments.hour,
            minute: arguments.minute
        )
        var parts: [String] = []
        if let y = arguments.year { parts.append("\(y)") }
        if let m = arguments.month { parts.append("month=\(m)") }
        if let d = arguments.day { parts.append("day=\(d)") }
        if let h = arguments.hour { parts.append("\(h)h") }
        if let min = arguments.minute { parts.append("\(min)m") }
        let triggerDesc = parts.isEmpty ? "No specific time set" : parts.joined(separator: " ")
        return ScheduledNotificationResult(
            identifier: arguments.identifier,
            title: arguments.title,
            triggerDescription: triggerDesc,
            message: "Calendar notification '\(arguments.title)' scheduled"
        )
    }
}
