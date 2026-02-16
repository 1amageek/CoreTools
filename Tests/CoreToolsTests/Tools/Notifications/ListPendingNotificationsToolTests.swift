import Testing
import Foundation
import OpenFoundationModels
@testable import CoreTools

@Suite("ListPendingNotificationsTool Tests")
struct ListPendingNotificationsToolTests {

    @Test("Lists pending notifications")
    func listPending() async throws {
        let mock = MockNotificationService()
        mock.pendingResult = [
            PendingNotification(identifier: "n1", title: "Reminder 1", body: "Body 1", nextTriggerDate: Date()),
            PendingNotification(identifier: "n2", title: "Reminder 2", body: "Body 2", nextTriggerDate: nil),
        ]
        let tool = ListPendingNotificationsTool(service: mock)
        let args = try ListPendingNotificationsTool.Arguments(GeneratedContent(properties: [:]))
        let result = try await tool.call(arguments: args)
        #expect(result.items.count == 2)
        #expect(result.items[0].identifier == "n1")
        #expect(result.items[1].nextTriggerDate == nil)
    }

    @Test("Returns empty list when no pending")
    func noPending() async throws {
        let mock = MockNotificationService()
        mock.pendingResult = []
        let tool = ListPendingNotificationsTool(service: mock)
        let args = try ListPendingNotificationsTool.Arguments(GeneratedContent(properties: [:]))
        let result = try await tool.call(arguments: args)
        #expect(result.items.isEmpty)
        #expect(result.message.contains("0"))
    }
}
