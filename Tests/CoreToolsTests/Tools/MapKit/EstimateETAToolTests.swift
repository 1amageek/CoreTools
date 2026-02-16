import Testing
import OpenFoundationModels
@testable import CoreTools

@Suite("EstimateETATool Tests")
struct EstimateETAToolTests {

    @Test("Throws when no ETA available")
    func noETA() async throws {
        let mock = MockMapService()
        mock.etaResult = nil
        let tool = EstimateETATool(service: mock)
        let args = try EstimateETATool.Arguments(GeneratedContent(properties: [
            "fromLatitude": 35.6812,
            "fromLongitude": 139.7671,
            "toLatitude": 34.6937,
            "toLongitude": 135.5023,
            "transportType": "walking"
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
