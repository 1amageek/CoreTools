import OpenFoundationModels

@Generable
public struct RelationshipMatch: Sendable {
    @Guide(description: "Contact identifier")
    public var identifier: String

    @Guide(description: "Full name of the contact")
    public var fullName: String

    @Guide(description: "Relationship labels found")
    public var relationships: [String]

    public init(identifier: String, fullName: String, relationships: [String]) {
        self.identifier = identifier
        self.fullName = fullName
        self.relationships = relationships
    }
}

@Generable
public struct RelationshipResult: Sendable {
    @Guide(description: "Matching contacts with relationship info")
    public var matches: [RelationshipMatch]

    @Guide(description: "Human-readable status message")
    public var message: String

    public init(matches: [RelationshipMatch], message: String) {
        self.matches = matches
        self.message = message
    }
}
