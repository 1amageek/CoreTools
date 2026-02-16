import Testing
@testable import CoreTools

@Suite("CancelNotificationTool Tests")
struct CancelNotificationToolTests {

    @Test("Cancels notifications by identifiers")
    func cancelNotifications() async throws {
        let mock = MockNotificationService()
        let tool = CancelNotificationTool(service: mock)
        let args = try CancelNotificationTool.Arguments(GeneratedContent(properties: [
            "identifiers": GeneratedContent(elements: [GeneratedContent("n1"), GeneratedContent("n2")])
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.cancelledIdentifiers.count == 2)
        #expect(mock.cancelledIdentifiers == ["n1", "n2"])
    }
}
