import Foundation

public enum CoreUISpacing: String, Codable, Sendable {
    case tight
    case compact
    case regular
    case spacious
}

public enum CoreUIViewKind: String, Codable, Sendable {
    case map
    case image
    case calendar
    case health
    case places
    case system
}

public enum CoreUIViewType: String, Codable, Sendable {
    case mapSnapshot = "map.snapshot"
    case mapRoute = "map.route"
    case imagePreview = "image.preview"
    case imageGallery = "image.gallery"
    case calendarTimeline = "calendar.timeline"
    case healthTrend = "health.trend"
    case placesList = "places.list"
    case systemLoading = "system.loading"
    case systemError = "system.error"

    public var kind: CoreUIViewKind {
        switch self {
        case .mapSnapshot, .mapRoute:
            return .map
        case .imagePreview, .imageGallery:
            return .image
        case .calendarTimeline:
            return .calendar
        case .healthTrend:
            return .health
        case .placesList:
            return .places
        case .systemLoading, .systemError:
            return .system
        }
    }
}

public enum CoreUIViewState: String, Codable, Sendable {
    case content
    case empty
    case loading
    case error
    case permissionRequired
    case partial
}

public enum CoreUIActionType: String, Codable, Sendable {
    case invoke
    case fullscreen
    case dismiss
}

public struct CoreUIActionTarget: Codable, Sendable {
    public let kind: String
    public let name: String

    public init(kind: String, name: String) {
        self.kind = kind
        self.name = name
    }
}

public struct CoreUIActionSafety: Codable, Sendable {
    public let requiresConfirmation: Bool

    public init(requiresConfirmation: Bool = false) {
        self.requiresConfirmation = requiresConfirmation
    }
}

public struct CoreUIAction: Codable, Sendable {
    public let type: CoreUIActionType
    public let label: String
    public let target: CoreUIActionTarget?
    public let input: JSONValue?
    public let safety: CoreUIActionSafety?

    public init(
        type: CoreUIActionType,
        label: String,
        target: CoreUIActionTarget? = nil,
        input: JSONValue? = nil,
        safety: CoreUIActionSafety? = nil
    ) {
        self.type = type
        self.label = label
        self.target = target
        self.input = input
        self.safety = safety
    }
}

public struct CoreUIViewItem: Sendable, Identifiable {
    public let id: String
    public let type: CoreUIViewType
    public let state: CoreUIViewState
    public let data: DecodedEmbeddedPayload
    public let actions: [CoreUIAction]

    public var kind: CoreUIViewKind { type.kind }
    public var payload: DecodedEmbeddedPayload { data }

    public init(
        id: String,
        type: CoreUIViewType,
        state: CoreUIViewState,
        data: DecodedEmbeddedPayload,
        actions: [CoreUIAction] = []
    ) {
        self.id = id
        self.type = type
        self.state = state
        self.data = data
        self.actions = actions
    }
}

public struct CoreUIStack: Sendable {
    public let spacing: CoreUISpacing?
    public let content: [CoreUINode]

    public init(spacing: CoreUISpacing? = nil, content: [CoreUINode]) {
        self.spacing = spacing
        self.content = content
    }
}

public struct CoreUISection: Sendable {
    public let title: String
    public let subtitle: String?
    public let content: [CoreUINode]

    public init(title: String, subtitle: String? = nil, content: [CoreUINode]) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }
}

public indirect enum CoreUINode: Sendable {
    case vstack(CoreUIStack)
    case hstack(CoreUIStack)
    case section(CoreUISection)
    case view(CoreUIViewItem)

    public var leafViews: [CoreUIViewItem] {
        switch self {
        case .vstack(let stack), .hstack(let stack):
            return stack.content.flatMap(\.leafViews)
        case .section(let section):
            return section.content.flatMap(\.leafViews)
        case .view(let view):
            return [view]
        }
    }
}

public struct CoreUIDocumentUI: Sendable {
    public let body: CoreUINode

    public init(body: CoreUINode) {
        self.body = body
    }

    public var leafViews: [CoreUIViewItem] {
        body.leafViews
    }
}

public struct CoreUIDocumentContext: Codable, Sendable {
    public let locale: String?
    public let timezone: String?
    public let unitSystem: String?
    public let calendar: String?

    public init(
        locale: String? = nil,
        timezone: String? = nil,
        unitSystem: String? = nil,
        calendar: String? = nil
    ) {
        self.locale = locale
        self.timezone = timezone
        self.unitSystem = unitSystem
        self.calendar = calendar
    }
}

public struct CoreUIDocument: Sendable {
    public let schema: String
    public let message: String
    public let context: CoreUIDocumentContext?
    public let ui: CoreUIDocumentUI?

    public init(
        schema: String = "coreui/1",
        message: String,
        context: CoreUIDocumentContext? = nil,
        ui: CoreUIDocumentUI?
    ) {
        self.schema = schema
        self.message = message
        self.context = context
        self.ui = ui
    }
}
