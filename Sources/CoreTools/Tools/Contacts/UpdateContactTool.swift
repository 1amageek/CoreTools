import OpenFoundationModels

public struct UpdateContactTool: Tool {
    public let name = "contacts_update"
    public let description = "Update an existing contact"

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Unique identifier of the contact to update")
        public var identifier: String

        @Guide(description: "New given (first) name")
        public var givenName: String?

        @Guide(description: "New family (last) name")
        public var familyName: String?

        @Guide(description: "User consent to update the contact")
        public var consent: Bool
    }

    private let service: any ContactsServiceProtocol

    public init(service: any ContactsServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> ContactMutationResult {
        guard arguments.consent else {
            throw CoreToolsError.permissionDenied(framework: "Contacts", detail: "User consent is required to update a contact")
        }
        try await service.updateContact(
            identifier: arguments.identifier,
            givenName: arguments.givenName,
            familyName: arguments.familyName,
            phoneNumbers: nil,
            emailAddresses: nil
        )
        return ContactMutationResult(
            identifier: arguments.identifier,
            action: "updated",
            message: "Contact '\(arguments.identifier)' updated"
        )
    }
}
