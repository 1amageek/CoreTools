
@Generable
public struct CalendarEventList: Sendable, PromptRepresentable {
    @Guide(description: "List of calendar events")
    public var events: [CalendarEventItem]

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(events: [CalendarEventItem], message: String) {
        self.events = events
        self.message = message
    }
}
