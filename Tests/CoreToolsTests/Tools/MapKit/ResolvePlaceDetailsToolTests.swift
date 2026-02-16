import Testing
import OpenFoundationModels
@testable import CoreTools

@Suite("ResolvePlaceDetailsTool Tests")
struct ResolvePlaceDetailsToolTests {

    @Test("Throws when no place found")
    func noPlace() async throws {
        let mock = MockMapService()
        mock.placeDetailResult = nil
        let tool = ResolvePlaceDetailsTool(service: mock)
        let args = try ResolvePlaceDetailsTool.Arguments(GeneratedContent(properties: [
            "query": "Unknown Place"
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
