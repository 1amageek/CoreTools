import Foundation

public struct CalendarEventPayload: Codable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let start: String
    public let end: String
    public let location: String?
    public let travelMin: Int?
    public let conflict: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case start
        case end
        case location
        case travelMin
        case conflict
        case startISO8601
        case endISO8601
        case travelMinutes
        case isConflict
    }

    public init(
        id: String,
        title: String,
        start: String,
        end: String,
        location: String? = nil,
        travelMin: Int? = nil,
        conflict: Bool = false
    ) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.location = location
        self.travelMin = travelMin
        self.conflict = conflict
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.title = try container.decode(String.self, forKey: .title)

        if let value = try container.decodeIfPresent(String.self, forKey: .start) {
            self.start = value
        } else {
            self.start = try container.decode(String.self, forKey: .startISO8601)
        }

        if let value = try container.decodeIfPresent(String.self, forKey: .end) {
            self.end = value
        } else {
            self.end = try container.decode(String.self, forKey: .endISO8601)
        }

        self.location = try container.decodeIfPresent(String.self, forKey: .location)

        if let value = try container.decodeIfPresent(Int.self, forKey: .travelMin) {
            self.travelMin = value
        } else {
            self.travelMin = try container.decodeIfPresent(Int.self, forKey: .travelMinutes)
        }

        if let value = try container.decodeIfPresent(Bool.self, forKey: .conflict) {
            self.conflict = value
        } else if let value = try container.decodeIfPresent(Bool.self, forKey: .isConflict) {
            self.conflict = value
        } else {
            self.conflict = false
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(travelMin, forKey: .travelMin)
        try container.encode(conflict, forKey: .conflict)
    }
}

public struct CalendarTimelinePayload: EmbeddedPayload {
    public let timezone: String?
    public let events: [CalendarEventPayload]

    enum CodingKeys: String, CodingKey {
        case timezone
        case timezoneIdentifier
        case events
    }

    public init(timezone: String?, events: [CalendarEventPayload]) {
        self.timezone = timezone
        self.events = events
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(String.self, forKey: .timezone) {
            self.timezone = value
        } else {
            self.timezone = try container.decodeIfPresent(String.self, forKey: .timezoneIdentifier)
        }

        self.events = try container.decode([CalendarEventPayload].self, forKey: .events)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(timezone, forKey: .timezone)
        try container.encode(events, forKey: .events)
    }

    public var hasMap: Bool { false }
    public var listCount: Int { events.count }
    public var formFieldCount: Int { 0 }
}
