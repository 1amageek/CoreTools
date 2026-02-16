import Testing
@testable import CoreTools

@Suite("ScheduleTimeNotificationTool Tests")
struct ScheduleTimeNotificationToolTests {

    @Test("Schedules notification with consent")
    func scheduleWithConsent() async throws {
        let mock = MockNotificationService()
        let tool = ScheduleTimeNotificationTool(service: mock)
        let args = try ScheduleTimeNotificationTool.Arguments(GeneratedContent(properties: [
            "identifier": "reminder-1",
            "title": "Reminder",
            "body": "Time to go",
            "timeInterval": 300.0,
            "repeats": false,
            "consent": true
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.identifier == "reminder-1")
        #expect(result.title == "Reminder")
        #expect(mock.scheduledIdentifiers.contains("reminder-1"))
    }

    @Test("Throws without consent")
    func noConsent() async throws {
        let mock = MockNotificationService()
        let tool = ScheduleTimeNotificationTool(service: mock)
        let args = try ScheduleTimeNotificationTool.Arguments(GeneratedContent(properties: [
            "identifier": "reminder-1",
            "title": "Reminder",
            "body": "Time to go",
            "timeInterval": 300.0,
            "repeats": false,
            "consent": false
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
