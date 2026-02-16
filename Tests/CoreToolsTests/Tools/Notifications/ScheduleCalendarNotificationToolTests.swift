import Testing
@testable import CoreTools

@Suite("ScheduleCalendarNotificationTool Tests")
struct ScheduleCalendarNotificationToolTests {

    @Test("Schedules calendar notification with consent")
    func scheduleWithConsent() async throws {
        let mock = MockNotificationService()
        let tool = ScheduleCalendarNotificationTool(service: mock)
        let args = try ScheduleCalendarNotificationTool.Arguments(GeneratedContent(properties: [
            "identifier": "meeting-1",
            "title": "Meeting",
            "body": "Stand-up meeting",
            "hour": 9,
            "minute": 0,
            "consent": true
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.identifier == "meeting-1")
        #expect(mock.scheduledIdentifiers.contains("meeting-1"))
    }

    @Test("Throws without consent")
    func noConsent() async throws {
        let mock = MockNotificationService()
        let tool = ScheduleCalendarNotificationTool(service: mock)
        let args = try ScheduleCalendarNotificationTool.Arguments(GeneratedContent(properties: [
            "identifier": "meeting-1",
            "title": "Meeting",
            "body": "Stand-up meeting",
            "consent": false
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
