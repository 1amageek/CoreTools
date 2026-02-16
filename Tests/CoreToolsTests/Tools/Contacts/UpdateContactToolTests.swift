import Testing
import OpenFoundationModels
@testable import CoreTools

@Suite("UpdateContactTool Tests")
struct UpdateContactToolTests {

    @Test("Updates contact with consent")
    func updateWithConsent() async throws {
        let mock = MockContactsService()
        let tool = UpdateContactTool(service: mock)
        let args = try UpdateContactTool.Arguments(GeneratedContent(properties: [
            "identifier": "1",
            "givenName": "Jiro",
            "consent": true
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.identifier == "1")
        #expect(result.action == "updated")
    }

    @Test("Throws without consent")
    func noConsent() async throws {
        let mock = MockContactsService()
        let tool = UpdateContactTool(service: mock)
        let args = try UpdateContactTool.Arguments(GeneratedContent(properties: [
            "identifier": "1",
            "consent": false
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
