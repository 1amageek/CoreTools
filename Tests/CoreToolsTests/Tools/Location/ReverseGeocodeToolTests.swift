import Testing
@testable import CoreTools

@Suite("ReverseGeocodeTool Tests")
struct ReverseGeocodeToolTests {

    @Test("Throws when no placemark found")
    func notFound() async throws {
        let mock = MockLocationService()
        mock.reverseGeocodeResult = nil
        let tool = ReverseGeocodeTool(service: mock)
        let args = try ReverseGeocodeTool.Arguments(GeneratedContent(properties: [
            "latitude": 0.0,
            "longitude": 0.0
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
