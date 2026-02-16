
public struct ToolRegistry: Sendable {
    public static func phase1Tools(
        locationService: any LocationServiceProtocol = LocationService(),
        mapService: any MapServiceProtocol = MapService(),
        contactsService: any ContactsServiceProtocol = ContactsService(),
        notificationService: any NotificationServiceProtocol = NotificationService()
    ) -> [any Tool] {
        [
            // Location (5)
            GetCurrentLocationTool(service: locationService),
            GeocodeTool(service: locationService),
            ReverseGeocodeTool(service: locationService),
            StartRegionMonitoringTool(service: locationService),
            StopRegionMonitoringTool(service: locationService),
            // MapKit (4)
            SearchPlacesTool(service: mapService),
            CalculateRouteTool(service: mapService),
            EstimateETATool(service: mapService),
            ResolvePlaceDetailsTool(service: mapService),
            // Contacts (5)
            SearchContactsTool(service: contactsService),
            GetContactDetailTool(service: contactsService),
            CreateContactTool(service: contactsService),
            UpdateContactTool(service: contactsService),
            ResolveRelationshipTool(service: contactsService),
            // Notifications (4)
            ScheduleTimeNotificationTool(service: notificationService),
            ScheduleCalendarNotificationTool(service: notificationService),
            ListPendingNotificationsTool(service: notificationService),
            CancelNotificationTool(service: notificationService),
        ]
    }
}
