import Foundation

public struct PendingNotification: Sendable {
    public var identifier: String
    public var title: String
    public var body: String
    public var nextTriggerDate: Date?

    public init(identifier: String, title: String, body: String, nextTriggerDate: Date?) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.nextTriggerDate = nextTriggerDate
    }
}

public protocol NotificationServiceProtocol: Sendable {
    func scheduleTimeInterval(identifier: String, title: String, body: String, timeInterval: TimeInterval, repeats: Bool) async throws
    func scheduleCalendar(identifier: String, title: String, body: String, year: Int?, month: Int?, day: Int?, hour: Int?, minute: Int?) async throws
    func listPending() async throws -> [PendingNotification]
    func cancel(identifiers: [String]) async throws
}
