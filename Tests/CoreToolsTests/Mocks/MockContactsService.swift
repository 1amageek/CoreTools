@testable import CoreTools

final class MockContactsService: ContactsServiceProtocol, @unchecked Sendable {
    var searchResult: [ContactRecord] = []
    var detailResult: ContactRecord?
    var createResult: String = "mock-id"
    var resolveResult: [ContactRecord] = []
    var shouldThrow: (any Error)?

    func searchContacts(query: String) async throws -> [ContactRecord] {
        if let error = shouldThrow { throw error }
        return searchResult
    }

    func getContactDetail(identifier: String) async throws -> ContactRecord {
        if let error = shouldThrow { throw error }
        guard let record = detailResult else {
            throw CoreToolsError.notFound(resource: "contact")
        }
        return record
    }

    func createContact(givenName: String, familyName: String, phoneNumbers: [(label: String?, value: String)], emailAddresses: [(label: String?, value: String)]) async throws -> String {
        if let error = shouldThrow { throw error }
        return createResult
    }

    func updateContact(identifier: String, givenName: String?, familyName: String?, phoneNumbers: [(label: String?, value: String)]?, emailAddresses: [(label: String?, value: String)]?) async throws {
        if let error = shouldThrow { throw error }
    }

    func resolveRelationship(name: String) async throws -> [ContactRecord] {
        if let error = shouldThrow { throw error }
        return resolveResult
    }
}
