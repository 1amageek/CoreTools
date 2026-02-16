import OpenFoundationModels

public struct GetContactDetailTool: Tool {
    public let name = "contacts_get_detail"
    public let description = "Get detailed information about a specific contact"

    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "Unique identifier of the contact")
        public var identifier: String
    }

    private let service: any ContactsServiceProtocol

    public init(service: any ContactsServiceProtocol) {
        self.service = service
    }

    public func call(arguments: Arguments) async throws -> ContactDetail {
        let record = try await service.getContactDetail(identifier: arguments.identifier)
        let phones = record.phoneNumbers.map { LabeledValue(label: $0.label, value: $0.value) }
        let emails = record.emailAddresses.map { LabeledValue(label: $0.label, value: $0.value) }
        return ContactDetail(
            identifier: record.identifier,
            givenName: record.givenName,
            familyName: record.familyName,
            phones: phones,
            emails: emails,
            addresses: record.postalAddresses,
            organization: record.organizationName.isEmpty ? nil : record.organizationName,
            jobTitle: record.jobTitle.isEmpty ? nil : record.jobTitle,
            message: "Contact detail retrieved for \(record.givenName) \(record.familyName)"
        )
    }
}
