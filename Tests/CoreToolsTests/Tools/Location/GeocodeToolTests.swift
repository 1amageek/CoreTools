import Testing
import Foundation
import OpenFoundationModels
@testable import CoreTools

@Suite("GeocodeTool Tests")
struct GeocodeToolTests {

    @Test("Returns empty list when no placemarks found")
    func emptyResult() async throws {
        let mock = MockLocationService()
        mock.geocodeResult = []
        let tool = GeocodeTool(service: mock)
        let args = try GeocodeTool.Arguments(GeneratedContent(properties: [
            "address": "Nonexistent Place"
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.locations.isEmpty)
        #expect(result.message.contains("0"))
    }

    @Test("Propagates errors")
    func geocodeError() async throws {
        let mock = MockLocationService()
        mock.shouldThrow = CoreToolsError.operationFailed(operation: "geocode", underlyingError: NSError(domain: "test", code: 1))
        let tool = GeocodeTool(service: mock)
        let args = try GeocodeTool.Arguments(GeneratedContent(properties: [
            "address": "Test"
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
