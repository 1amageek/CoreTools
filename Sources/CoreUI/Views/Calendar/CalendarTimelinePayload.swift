import Foundation

public struct CalendarEventPayload: Codable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let startISO8601: String
    public let endISO8601: String
    public let location: String?
    public let travelMinutes: Int?
    public let isConflict: Bool

    public init(
        id: String,
        title: String,
        startISO8601: String,
        endISO8601: String,
        location: String? = nil,
        travelMinutes: Int? = nil,
        isConflict: Bool = false
    ) {
        self.id = id
        self.title = title
        self.startISO8601 = startISO8601
        self.endISO8601 = endISO8601
        self.location = location
        self.travelMinutes = travelMinutes
        self.isConflict = isConflict
    }
}

public struct CalendarTimelinePayload: EmbeddedPayload {
    public let timezoneIdentifier: String
    public let events: [CalendarEventPayload]

    public init(timezoneIdentifier: String, events: [CalendarEventPayload]) {
        self.timezoneIdentifier = timezoneIdentifier
        self.events = events
    }

    public var hasMap: Bool { false }
    public var listCount: Int { events.count }
    public var formFieldCount: Int { 0 }
}
