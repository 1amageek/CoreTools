import EventKit

public struct CalendarService: CalendarServiceProtocol {
    public init() {}

    public func listEvents(startDate: Date, endDate: Date) async throws -> [CalendarEventRecord] {
        try await ensureAuthorized()
        let store = EKEventStore()
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = store.events(matching: predicate)
        return events.map { toRecord($0) }
    }

    private func toRecord(_ event: EKEvent) -> CalendarEventRecord {
        CalendarEventRecord(
            eventIdentifier: event.eventIdentifier,
            title: event.title ?? "",
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            location: event.location ?? "",
            calendar: event.calendar?.title ?? ""
        )
    }

    private func ensureAuthorized() async throws {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .denied, .restricted:
            throw CoreToolsError.permissionDenied(
                framework: "EventKit",
                detail: "Calendar access is \(status == .denied ? "denied" : "restricted")"
            )
        case .notDetermined:
            let store = EKEventStore()
            let granted: Bool
            do {
                granted = try await store.requestFullAccessToEvents()
            } catch {
                throw CoreToolsError.operationFailed(
                    operation: "requestCalendarAccess", underlyingError: error
                )
            }
            if !granted {
                throw CoreToolsError.permissionDenied(
                    framework: "EventKit",
                    detail: "Calendar access was not granted"
                )
            }
        default:
            break
        }
    }
}
