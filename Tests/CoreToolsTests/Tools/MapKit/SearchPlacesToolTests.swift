import Testing
import Foundation
import OpenFoundationModels
@testable import CoreTools

@Suite("SearchPlacesTool Tests")
struct SearchPlacesToolTests {

    @Test("Returns empty list when no places found")
    func emptyResult() async throws {
        let mock = MockMapService()
        mock.searchResult = []
        let tool = SearchPlacesTool(service: mock)
        let args = try SearchPlacesTool.Arguments(GeneratedContent(properties: [
            "query": "Coffee"
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.places.isEmpty)
        #expect(result.message.contains("0"))
    }

    @Test("Propagates service errors")
    func serviceError() async throws {
        let mock = MockMapService()
        mock.shouldThrow = CoreToolsError.operationFailed(operation: "search", underlyingError: NSError(domain: "test", code: 1))
        let tool = SearchPlacesTool(service: mock)
        let args = try SearchPlacesTool.Arguments(GeneratedContent(properties: [
            "query": "Coffee"
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
