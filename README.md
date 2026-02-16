# CoreTools

Apple framework tools for [OpenFoundationModels](https://github.com/1amageek/OpenFoundationModels). Each tool conforms to the `Tool` protocol, enabling on-device language models to interact with iOS/macOS system capabilities.

## Requirements

- Swift 6.2+
- iOS 18+ / macOS 15+

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/1amageek/CoreTools.git", from: "0.1.0")
]
```

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "CoreTools", package: "CoreTools"),
    ]
)
```

## Tools

### CoreLocation

| Tool | Name | Description |
|------|------|-------------|
| `GetCurrentLocationTool` | `location_get_current` | Get current device location |
| `GeocodeTool` | `location_geocode` | Convert address to coordinates |
| `ReverseGeocodeTool` | `location_reverse_geocode` | Convert coordinates to address |
| `StartRegionMonitoringTool` | `location_start_region_monitoring` | Monitor a geographic region |
| `StopRegionMonitoringTool` | `location_stop_region_monitoring` | Stop monitoring a region |

### MapKit

| Tool | Name | Description |
|------|------|-------------|
| `SearchPlacesTool` | `map_search_places` | Search for places by keyword |
| `CalculateRouteTool` | `map_calculate_route` | Calculate route with directions |
| `EstimateETATool` | `map_estimate_eta` | Estimate travel time |
| `ResolvePlaceDetailsTool` | `map_resolve_place_details` | Get detailed place information |

### Contacts

| Tool | Name | Description |
|------|------|-------------|
| `SearchContactsTool` | `contacts_search` | Search contacts by name |
| `GetContactDetailTool` | `contacts_get_detail` | Get contact details |
| `CreateContactTool` | `contacts_create` | Create a new contact |
| `UpdateContactTool` | `contacts_update` | Update an existing contact |
| `ResolveRelationshipTool` | `contacts_resolve_relationship` | Find contacts by relationship |

### UserNotifications

| Tool | Name | Description |
|------|------|-------------|
| `ScheduleTimeNotificationTool` | `notification_schedule_time` | Schedule after time interval |
| `ScheduleCalendarNotificationTool` | `notification_schedule_calendar` | Schedule at calendar date |
| `ListPendingNotificationsTool` | `notification_list_pending` | List pending notifications |
| `CancelNotificationTool` | `notification_cancel` | Cancel notifications |

## Usage

### With LanguageModelSession

```swift
import OpenFoundationModels
import CoreTools

let tools = ToolRegistry.phase1Tools()
let session = LanguageModelSession(tools: tools)
let response = try await session.respond(to: "What's near Tokyo Station?")
```

### Individual Tool

```swift
let tool = SearchPlacesTool(service: MapService())
let result = try await tool.call(arguments: .init(
    GeneratedContent(properties: ["query": "coffee shop"])
))
```

### Dependency Injection

All tools accept a service protocol, enabling mock injection for testing:

```swift
let mockService = MockLocationService()
let tool = GetCurrentLocationTool(service: mockService)
```

## Permissions

Tools that access protected resources request authorization automatically. Add the required keys to your `Info.plist`:

| Framework | Key |
|-----------|-----|
| CoreLocation | `NSLocationWhenInUseUsageDescription` |
| Contacts | `NSContactsUsageDescription` |

UserNotifications requests permission at runtime. No `Info.plist` key is needed.

Side-effect operations (creating contacts, scheduling notifications, region monitoring) require `consent: true` in their arguments. If `consent` is `false`, the tool throws `CoreToolsError.permissionDenied`.

## Architecture

```
Sources/CoreTools/
├── Common/         # CoreToolsError, Coordinate, ToolRegistry
├── Services/       # Protocol + implementation per framework
├── Tools/          # Tool protocol conformances
└── Models/         # @Generable output types
```

Each tool is a stateless struct. Services are injected via protocol for testability.

## License

MIT
