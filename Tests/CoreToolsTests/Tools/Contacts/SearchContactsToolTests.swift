import Testing
import OpenFoundationModels
@testable import CoreTools

@Suite("SearchContactsTool Tests")
struct SearchContactsToolTests {

    @Test("Returns matching contacts")
    func searchContacts() async throws {
        let mock = MockContactsService()
        mock.searchResult = [
            ContactRecord(identifier: "1", givenName: "Taro", familyName: "Yamada"),
            ContactRecord(identifier: "2", givenName: "Hanako", familyName: "Yamada"),
        ]
        let tool = SearchContactsTool(service: mock)
        let args = try SearchContactsTool.Arguments(GeneratedContent(properties: [
            "query": "Yamada"
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.contacts.count == 2)
        #expect(result.contacts[0].givenName == "Taro")
        #expect(result.message.contains("2"))
    }

    @Test("Returns empty list when no matches")
    func noResults() async throws {
        let mock = MockContactsService()
        mock.searchResult = []
        let tool = SearchContactsTool(service: mock)
        let args = try SearchContactsTool.Arguments(GeneratedContent(properties: [
            "query": "Nobody"
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.contacts.isEmpty)
    }
}
