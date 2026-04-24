
public struct ResolveRelationshipTool: Tool {
    public let name = "contacts_resolve_relationship"
    public let description = """
        Find contacts and their relationship labels by name.

        ALWAYS call this tool when the user asks about family members, relationships, or who someone is related to.

        Usage:
        - Search by name to find contacts that have relationship metadata (e.g., "mother", "spouse", "friend")
        - Returns each matching contact with their full name, identifier, and list of labeled relationships
        - Use this instead of contacts_search when the user asks about family members or relationships
        - Returns an empty list if no contacts match or no relationships are defined
        """

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Name to search for relationships")
        public var name: String
    }

    private let service: any ContactsServiceProtocol

    public init(service: any ContactsServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> RelationshipResult {
        let records = try await service.resolveRelationship(name: arguments.name)
        let matches = records.map { record in
            let relationships = record.relationships.map { "\($0.label): \($0.name)" }
            return RelationshipMatch(
                identifier: record.identifier,
                fullName: "\(record.givenName) \(record.familyName)",
                relationships: relationships
            )
        }
        return RelationshipResult(
            matches: matches,
            message: "Found \(matches.count) contact(s) with relationship info for '\(arguments.name)'"
        )
    }
}

extension ResolveRelationshipTool: ToolIconProviding {
    public var iconSystemName: String { "person.crop.circle.fill" }
}
