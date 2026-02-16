
public struct CreateContactTool: Tool {
    public let name = "contacts_create"
    public let description = "Create a new contact"

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Given (first) name")
        public var givenName: String

        @Guide(description: "Family (last) name")
        public var familyName: String

        @Guide(description: "Phone numbers as comma-separated values")
        public var phoneNumbers: [String]

        @Guide(description: "Email addresses as comma-separated values")
        public var emailAddresses: [String]

        @Guide(description: "User consent to create a new contact")
        public var consent: Bool
    }

    private let service: any ContactsServiceProtocol

    public init(service: any ContactsServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> ContactMutationResult {
        guard arguments.consent else {
            throw CoreToolsError.permissionDenied(framework: "Contacts", detail: "User consent is required to create a contact")
        }
        let phones = arguments.phoneNumbers.map { (label: nil as String?, value: $0) }
        let emails = arguments.emailAddresses.map { (label: nil as String?, value: $0) }
        let identifier = try await service.createContact(
            givenName: arguments.givenName,
            familyName: arguments.familyName,
            phoneNumbers: phones,
            emailAddresses: emails
        )
        return ContactMutationResult(
            identifier: identifier,
            action: "created",
            message: "Contact '\(arguments.givenName) \(arguments.familyName)' created"
        )
    }
}
