import Testing
import OpenFoundationModels
@testable import CoreTools

@Suite("CreateContactTool Tests")
struct CreateContactToolTests {

    @Test("Creates contact with consent")
    func createWithConsent() async throws {
        let mock = MockContactsService()
        mock.createResult = "new-id-123"
        let tool = CreateContactTool(service: mock)
        let args = try CreateContactTool.Arguments(GeneratedContent(properties: [
            "givenName": "Taro",
            "familyName": "Yamada",
            "phoneNumbers": GeneratedContent(elements: [GeneratedContent("090-1234-5678")]),
            "emailAddresses": GeneratedContent(elements: [GeneratedContent("taro@example.com")]),
            "consent": true
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.identifier == "new-id-123")
        #expect(result.action == "created")
    }

    @Test("Throws without consent")
    func noConsent() async throws {
        let mock = MockContactsService()
        let tool = CreateContactTool(service: mock)
        let args = try CreateContactTool.Arguments(GeneratedContent(properties: [
            "givenName": "Taro",
            "familyName": "Yamada",
            "phoneNumbers": GeneratedContent(elements: [GeneratedContent("090-1234-5678")]),
            "emailAddresses": GeneratedContent(elements: [GeneratedContent("taro@example.com")]),
            "consent": false
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
