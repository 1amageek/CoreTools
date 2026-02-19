import Foundation

public struct CalendarEventRecord: Sendable {
    public var eventIdentifier: String
    public var title: String
    public var startDate: Date
    public var endDate: Date
    public var isAllDay: Bool
    public var location: String
    public var calendar: String

    public init(eventIdentifier: String, title: String, startDate: Date, endDate: Date,
                isAllDay: Bool, location: String = "", calendar: String = "") {
        self.eventIdentifier = eventIdentifier
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.location = location
        self.calendar = calendar
    }
}

public protocol CalendarServiceProtocol: Sendable {
    func listEvents(startDate: Date, endDate: Date) async throws -> [CalendarEventRecord]
}
