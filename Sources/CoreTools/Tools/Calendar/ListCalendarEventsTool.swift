import Foundation

public struct ListCalendarEventsTool: Tool {
    public let name = "calendar_list_events"
    public let description = """
        List calendar events within a date range.

        ALWAYS call this tool when the user asks about their schedule, calendar, \
        appointments, or upcoming events. \
        ALWAYS render the result as a CoreUI calendar artifact so the user sees a visual calendar view.

        Usage:
        - Provide start and end dates as ISO 8601 strings to define the search range
        - Returns events from all calendars within the specified range
        - Each event includes identifier, title, start/end dates, location, and calendar name
        """

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Start date as ISO 8601 string")
        public var startDate: String

        @Guide(description: "End date as ISO 8601 string")
        public var endDate: String
    }

    private let service: any CalendarServiceProtocol

    public init(service: any CalendarServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> CalendarEventList {
        guard let start = Self.parseISO8601(arguments.startDate) else {
            throw CoreToolsError.invalidInput(
                parameter: "startDate", reason: "Invalid ISO 8601 format"
            )
        }
        guard let end = Self.parseISO8601(arguments.endDate) else {
            throw CoreToolsError.invalidInput(
                parameter: "endDate", reason: "Invalid ISO 8601 format"
            )
        }
        let records = try await service.listEvents(startDate: start, endDate: end)
        let formatter = ISO8601DateFormatter()
        let items = records.map { record in
            CalendarEventItem(
                identifier: record.eventIdentifier,
                title: record.title,
                startDate: formatter.string(from: record.startDate),
                endDate: formatter.string(from: record.endDate),
                isAllDay: record.isAllDay,
                location: record.location.isEmpty ? nil : record.location,
                calendar: record.calendar
            )
        }
        return CalendarEventList(
            events: items,
            message: "\(items.count) event(s) found"
        )
    }

    private static func parseISO8601(_ string: String) -> Date? {
        let full = ISO8601DateFormatter()
        if let date = full.date(from: string) { return date }

        let withTimezone = ISO8601DateFormatter()
        withTimezone.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withTimezone.date(from: string) { return date }

        let dateOnly = ISO8601DateFormatter()
        dateOnly.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        if let date = dateOnly.date(from: string) { return date }

        return nil
    }
}

extension ListCalendarEventsTool: ToolIconProviding {
    public var iconSystemName: String { "calendar" }
}
