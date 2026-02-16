import Testing
@testable import CoreTools

@Suite("CalculateRouteTool Tests")
struct CalculateRouteToolTests {

    @Test("Throws when no route found")
    func noRoute() async throws {
        let mock = MockMapService()
        mock.routeResult = nil
        let tool = CalculateRouteTool(service: mock)
        let args = try CalculateRouteTool.Arguments(GeneratedContent(properties: [
            "fromLatitude": 35.6812,
            "fromLongitude": 139.7671,
            "toLatitude": 34.6937,
            "toLongitude": 135.5023,
            "transportType": "automobile"
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
