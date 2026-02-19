
@Generable
public struct CalendarEventItem: Sendable {
    @Guide(description: "Event identifier")
    public var identifier: String

    @Guide(description: "Event title")
    public var title: String

    @Guide(description: "Start date as ISO 8601 string")
    public var startDate: String

    @Guide(description: "End date as ISO 8601 string")
    public var endDate: String

    @Guide(description: "Whether the event is all-day")
    public var isAllDay: Bool

    @Guide(description: "Event location")
    public var location: String?

    @Guide(description: "Calendar name")
    public var calendar: String

    public init(identifier: String, title: String, startDate: String, endDate: String,
                isAllDay: Bool, location: String?, calendar: String) {
        self.identifier = identifier
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.location = location
        self.calendar = calendar
    }
}
