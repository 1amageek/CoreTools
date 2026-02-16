
public struct ResolveRelationshipTool: Tool {
    public let name = "contacts_resolve_relationship"
    public let description = "Find contacts and their relationship labels by name"

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
