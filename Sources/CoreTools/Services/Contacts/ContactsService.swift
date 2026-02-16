import Contacts

public struct ContactsService: ContactsServiceProtocol {

    public init() {}

    public func searchContacts(query: String) async throws -> [ContactRecord] {
        try await ensureAuthorized()
        let store = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
        let predicate = CNContact.predicateForContacts(matchingName: query)
        let contacts: [CNContact]
        do {
            contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        } catch {
            throw CoreToolsError.operationFailed(operation: "searchContacts", underlyingError: error)
        }
        return contacts.map { toRecord($0) }
    }

    public func getContactDetail(identifier: String) async throws -> ContactRecord {
        try await ensureAuthorized()
        let store = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactJobTitleKey as CNKeyDescriptor,
            CNContactRelationsKey as CNKeyDescriptor,
        ]
        let contact: CNContact
        do {
            contact = try store.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
        } catch {
            throw CoreToolsError.notFound(resource: "contact: \(identifier)")
        }
        return toDetailRecord(contact)
    }

    public func createContact(givenName: String, familyName: String, phoneNumbers: [(label: String?, value: String)], emailAddresses: [(label: String?, value: String)]) async throws -> String {
        try await ensureAuthorized()
        let store = CNContactStore()
        let contact = CNMutableContact()
        contact.givenName = givenName
        contact.familyName = familyName
        contact.phoneNumbers = phoneNumbers.map { entry in
            CNLabeledValue(label: entry.label, value: CNPhoneNumber(stringValue: entry.value))
        }
        contact.emailAddresses = emailAddresses.map { entry in
            CNLabeledValue(label: entry.label, value: entry.value as NSString)
        }
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        do {
            try store.execute(saveRequest)
        } catch {
            throw CoreToolsError.operationFailed(operation: "createContact", underlyingError: error)
        }
        return contact.identifier
    }

    public func updateContact(identifier: String, givenName: String?, familyName: String?, phoneNumbers: [(label: String?, value: String)]?, emailAddresses: [(label: String?, value: String)]?) async throws {
        try await ensureAuthorized()
        let store = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
        let contact: CNMutableContact
        do {
            let fetched = try store.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
            guard let mutable = fetched.mutableCopy() as? CNMutableContact else {
                throw CoreToolsError.operationFailed(operation: "updateContact", underlyingError: NSError(domain: "CoreTools", code: -1))
            }
            contact = mutable
        } catch let error as CoreToolsError {
            throw error
        } catch {
            throw CoreToolsError.notFound(resource: "contact: \(identifier)")
        }
        if let givenName { contact.givenName = givenName }
        if let familyName { contact.familyName = familyName }
        if let phoneNumbers {
            contact.phoneNumbers = phoneNumbers.map { entry in
                CNLabeledValue(label: entry.label, value: CNPhoneNumber(stringValue: entry.value))
            }
        }
        if let emailAddresses {
            contact.emailAddresses = emailAddresses.map { entry in
                CNLabeledValue(label: entry.label, value: entry.value as NSString)
            }
        }
        let saveRequest = CNSaveRequest()
        saveRequest.update(contact)
        do {
            try store.execute(saveRequest)
        } catch {
            throw CoreToolsError.operationFailed(operation: "updateContact", underlyingError: error)
        }
    }

    public func resolveRelationship(name: String) async throws -> [ContactRecord] {
        try await ensureAuthorized()
        let store = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactRelationsKey as CNKeyDescriptor,
        ]
        let predicate = CNContact.predicateForContacts(matchingName: name)
        let contacts: [CNContact]
        do {
            contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        } catch {
            throw CoreToolsError.operationFailed(operation: "resolveRelationship", underlyingError: error)
        }
        return contacts.map { contact in
            var record = toRecord(contact)
            record.relationships = contact.contactRelations.map { labeled in
                let label = CNLabeledValue<CNContactRelation>.localizedString(forLabel: labeled.label ?? "")
                return (label: label, name: labeled.value.name)
            }
            return record
        }
    }

    private func toRecord(_ contact: CNContact) -> ContactRecord {
        ContactRecord(
            identifier: contact.identifier,
            givenName: contact.givenName,
            familyName: contact.familyName,
            phoneNumbers: contact.phoneNumbers.map { labeled in
                (label: CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: labeled.label ?? ""), value: labeled.value.stringValue)
            },
            emailAddresses: contact.emailAddresses.map { labeled in
                (label: CNLabeledValue<NSString>.localizedString(forLabel: labeled.label ?? ""), value: labeled.value as String)
            }
        )
    }

    private func toDetailRecord(_ contact: CNContact) -> ContactRecord {
        ContactRecord(
            identifier: contact.identifier,
            givenName: contact.givenName,
            familyName: contact.familyName,
            phoneNumbers: contact.phoneNumbers.map { labeled in
                (label: CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: labeled.label ?? ""), value: labeled.value.stringValue)
            },
            emailAddresses: contact.emailAddresses.map { labeled in
                (label: CNLabeledValue<NSString>.localizedString(forLabel: labeled.label ?? ""), value: labeled.value as String)
            },
            postalAddresses: contact.postalAddresses.map { labeled in
                let addr = labeled.value
                return PostalAddress(street: addr.street, city: addr.city, state: addr.state, postalCode: addr.postalCode, country: addr.country)
            },
            organizationName: contact.organizationName,
            jobTitle: contact.jobTitle,
            relationships: contact.contactRelations.map { labeled in
                let label = CNLabeledValue<CNContactRelation>.localizedString(forLabel: labeled.label ?? "")
                return (label: label, name: labeled.value.name)
            }
        )
    }

    private func ensureAuthorized() async throws {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .denied, .restricted:
            throw CoreToolsError.permissionDenied(
                framework: "Contacts",
                detail: "Contact access is \(status == .denied ? "denied" : "restricted")"
            )
        case .notDetermined:
            let store = CNContactStore()
            let granted: Bool
            do {
                granted = try await store.requestAccess(for: .contacts)
            } catch {
                throw CoreToolsError.operationFailed(operation: "requestContactsAccess", underlyingError: error)
            }
            if !granted {
                throw CoreToolsError.permissionDenied(
                    framework: "Contacts",
                    detail: "Contact access was not granted"
                )
            }
        default:
            break
        }
    }
}
