import UserNotifications

public struct NotificationService: NotificationServiceProtocol {

    public init() {}

    public func scheduleTimeInterval(identifier: String, title: String, body: String, timeInterval: TimeInterval, repeats: Bool) async throws {
        try await requestAuthorization()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            throw CoreToolsError.operationFailed(operation: "scheduleTimeInterval", underlyingError: error)
        }
    }

    public func scheduleCalendar(identifier: String, title: String, body: String, year: Int?, month: Int?, day: Int?, hour: Int?, minute: Int?) async throws {
        try await requestAuthorization()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            throw CoreToolsError.operationFailed(operation: "scheduleCalendar", underlyingError: error)
        }
    }

    public func listPending() async throws -> [PendingNotification] {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.map { request in
            let nextDate: Date?
            if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger {
                nextDate = calendarTrigger.nextTriggerDate()
            } else if let intervalTrigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                nextDate = intervalTrigger.nextTriggerDate()
            } else {
                nextDate = nil
            }
            return PendingNotification(
                identifier: request.identifier,
                title: request.content.title,
                body: request.content.body,
                nextTriggerDate: nextDate
            )
        }
    }

    public func cancel(identifiers: [String]) async throws {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .denied:
            throw CoreToolsError.permissionDenied(framework: "UserNotifications", detail: "Notification permission is denied")
        case .notDetermined:
            let granted: Bool
            do {
                granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                throw CoreToolsError.operationFailed(operation: "requestAuthorization", underlyingError: error)
            }
            if !granted {
                throw CoreToolsError.permissionDenied(framework: "UserNotifications", detail: "Notification permission was not granted")
            }
        default:
            break
        }
    }
}
