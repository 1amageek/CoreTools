import Testing
@testable import CoreTools

@Suite("GetContactDetailTool Tests")
struct GetContactDetailToolTests {

    @Test("Returns contact detail")
    func getDetail() async throws {
        let mock = MockContactsService()
        mock.detailResult = ContactRecord(
            identifier: "1",
            givenName: "Taro",
            familyName: "Yamada",
            phoneNumbers: [("mobile", "090-1234-5678")],
            emailAddresses: [("home", "taro@example.com")],
            postalAddresses: [PostalAddress(street: "1-1", city: "Shibuya", state: "Tokyo", postalCode: "150-0001", country: "Japan")],
            organizationName: "ACME",
            jobTitle: "Engineer"
        )
        let tool = GetContactDetailTool(service: mock)
        let args = try GetContactDetailTool.Arguments(GeneratedContent(properties: [
            "identifier": "1"
        ]))
        let result = try await tool.call(arguments: args)
        #expect(result.givenName == "Taro")
        #expect(result.phones.count == 1)
        #expect(result.emails.count == 1)
        #expect(result.addresses.count == 1)
        #expect(result.organization == "ACME")
    }

    @Test("Throws when contact not found")
    func notFound() async throws {
        let mock = MockContactsService()
        mock.detailResult = nil
        let tool = GetContactDetailTool(service: mock)
        let args = try GetContactDetailTool.Arguments(GeneratedContent(properties: [
            "identifier": "nonexistent"
        ]))
        await #expect(throws: CoreToolsError.self) {
            try await tool.call(arguments: args)
        }
    }
}
