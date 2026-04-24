
public struct SearchContactsTool: Tool {
    public let name = "contacts_search"
    public let description = """
        Search the user's contacts by name and return matching results.

        ALWAYS call this tool when the user asks to find a contact or look up someone by name.

        Usage:
        - Provide a name query to search across given names and family names
        - Returns a list of matching contacts with identifiers, given names, and family names
        - Returns an empty list if no contacts match the query
        - ALWAYS use this tool before contacts_get_detail to obtain a valid contact identifier
        - For relationship information (e.g., "mother", "spouse"), use contacts_resolve_relationship instead
        """

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

extension SearchContactsTool: ToolIconProviding {
    public var iconSystemName: String { "person.crop.circle.fill" }
}
