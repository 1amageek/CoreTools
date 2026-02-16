import Testing
@testable import CoreTools

@Suite("StopRegionMonitoringTool Tests")
struct StopRegionMonitoringToolTests {

    @Test("Stops monitoring with consent")
    func stopWithConsent() async throws {
        let mock = MockLocationService()
        let tool = StopRegionMonitoringTool(service: mock)
        let args = try StopRegionMonitoringTool.Arguments(GeneratedContent(properties: [
            "identifier": "home",
            "consent": true
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.regionIdentifier == "home")
        #expect(result.action == "stopped")
    }

    @Test("Throws without consent")
    func noConsent() async throws {
        let mock = MockLocationService()
        let tool = StopRegionMonitoringTool(service: mock)
        let args = try StopRegionMonitoringTool.Arguments(GeneratedContent(properties: [
            "identifier": "home",
            "consent": false
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
