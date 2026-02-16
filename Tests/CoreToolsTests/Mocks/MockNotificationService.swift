import Foundation
@testable import CoreTools

final class MockNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    var pendingResult: [PendingNotification] = []
    var scheduledIdentifiers: [String] = []
    var cancelledIdentifiers: [String] = []
    var shouldThrow: (any Error)?

    func scheduleTimeInterval(identifier: String, title: String, body: String, timeInterval: TimeInterval, repeats: Bool) async throws {
        if let error = shouldThrow { throw error }
        scheduledIdentifiers.append(identifier)
    }

    func scheduleCalendar(identifier: String, title: String, body: String, year: Int?, month: Int?, day: Int?, hour: Int?, minute: Int?) async throws {
        if let error = shouldThrow { throw error }
        scheduledIdentifiers.append(identifier)
    }

    func listPending() async throws -> [PendingNotification] {
        if let error = shouldThrow { throw error }
        return pendingResult
    }

    func cancel(identifiers: [String]) async throws {
        if let error = shouldThrow { throw error }
        cancelledIdentifiers.append(contentsOf: identifiers)
    }
}
