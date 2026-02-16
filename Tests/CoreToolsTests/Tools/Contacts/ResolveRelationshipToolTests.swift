import Testing
@testable import CoreTools

@Suite("ResolveRelationshipTool Tests")
struct ResolveRelationshipToolTests {

    @Test("Returns relationship matches")
    func resolveRelationships() async throws {
        let mock = MockContactsService()
        mock.resolveResult = [
            ContactRecord(
                identifier: "1",
                givenName: "Taro",
                familyName: "Yamada",
                relationships: [("brother", "Jiro")]
            ),
        ]
        let tool = ResolveRelationshipTool(service: mock)
        let args = try ResolveRelationshipTool.Arguments(GeneratedContent(properties: [
            "name": "Yamada"
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.matches.count == 1)
        #expect(result.matches[0].fullName == "Taro Yamada")
        #expect(result.matches[0].relationships.count == 1)
    }

    @Test("Returns empty when no matches")
    func noMatches() async throws {
        let mock = MockContactsService()
        mock.resolveResult = []
        let tool = ResolveRelationshipTool(service: mock)
        let args = try ResolveRelationshipTool.Arguments(GeneratedContent(properties: [
            "name": "Nobody"
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.matches.isEmpty)
    }
}
