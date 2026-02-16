import OpenFoundationModels

public struct SearchContactsTool: Tool {
    public let name = "contacts_search"
    public let description = "Search contacts by name"

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Name to search for")
        public var query: String
    }

    private let service: any ContactsServiceProtocol

    public init(service: any ContactsServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> ContactSearchResult {
        let records = try await service.searchContacts(query: arguments.query)
        let summaries = records.map { record in
            ContactSummary(
                identifier: record.identifier,
                givenName: record.givenName,
                familyName: record.familyName
            )
        }
        return ContactSearchResult(
            contacts: summaries,
            message: "Found \(summaries.count) contact(s) matching '\(arguments.query)'"
        )
    }
}
