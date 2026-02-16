public struct ContactRecord: Sendable {
    public var identifier: String
    public var givenName: String
    public var familyName: String
    public var phoneNumbers: [(label: String, value: String)]
    public var emailAddresses: [(label: String, value: String)]
    public var postalAddresses: [PostalAddress]
    public var organizationName: String
    public var jobTitle: String
    public var relationships: [(label: String, name: String)]

    public init(identifier: String, givenName: String, familyName: String, phoneNumbers: [(label: String, value: String)] = [], emailAddresses: [(label: String, value: String)] = [], postalAddresses: [PostalAddress] = [], organizationName: String = "", jobTitle: String = "", relationships: [(label: String, name: String)] = []) {
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.phoneNumbers = phoneNumbers
        self.emailAddresses = emailAddresses
        self.postalAddresses = postalAddresses
        self.organizationName = organizationName
        self.jobTitle = jobTitle
        self.relationships = relationships
    }
}

public protocol ContactsServiceProtocol: Sendable {
    func searchContacts(query: String) async throws -> [ContactRecord]
    func getContactDetail(identifier: String) async throws -> ContactRecord
    func createContact(givenName: String, familyName: String, phoneNumbers: [(label: String?, value: String)], emailAddresses: [(label: String?, value: String)]) async throws -> String
    func updateContact(identifier: String, givenName: String?, familyName: String?, phoneNumbers: [(label: String?, value: String)]?, emailAddresses: [(label: String?, value: String)]?) async throws
    func resolveRelationship(name: String) async throws -> [ContactRecord]
}
