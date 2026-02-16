import Testing
@testable import CoreTools

@Suite("StartRegionMonitoringTool Tests")
struct StartRegionMonitoringToolTests {

    @Test("Starts monitoring with consent")
    func startWithConsent() async throws {
        let mock = MockLocationService()
        let tool = StartRegionMonitoringTool(service: mock)
        let args = try StartRegionMonitoringTool.Arguments(GeneratedContent(properties: [
            "identifier": "home",
            "latitude": 35.6812,
            "longitude": 139.7671,
            "radius": 100.0,
            "consent": true
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.regionIdentifier == "home")
        #expect(result.action == "started")
    }

    @Test("Throws without consent")
    func noConsent() async throws {
        let mock = MockLocationService()
        let tool = StartRegionMonitoringTool(service: mock)
        let args = try StartRegionMonitoringTool.Arguments(GeneratedContent(properties: [
            "identifier": "home",
            "latitude": 35.6812,
            "longitude": 139.7671,
            "radius": 100.0,
            "consent": false
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
