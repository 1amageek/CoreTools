import Foundation

public enum CoreUILayout: String, Codable, Sendable {
    case vertical = "v"
    case horizontal = "h"
}

public enum CoreUIViewKind: String, Codable, Sendable {
    case map
    case image
    case calendar
    case health
    case loading
    case schemaError = "schema_error"
}

public enum CoreUIActionType: String, Codable, Sendable {
    case tool
    case fullscreen
    case dismiss
}

public struct CoreUIAction: Codable, Sendable {
    public let label: String
    public let type: CoreUIActionType
    public let name: String?
    public let input: JSONValue?

    public init(label: String, type: CoreUIActionType, name: String? = nil, input: JSONValue? = nil) {
        self.label = label
        self.type = type
        self.name = name
        self.input = input
    }
}

public struct CoreUIViewItem: Sendable, Identifiable {
    public let id: String
    public let kind: CoreUIViewKind
    public let payload: DecodedEmbeddedPayload
    public let actions: [CoreUIAction]

    public init(id: String, kind: CoreUIViewKind, payload: DecodedEmbeddedPayload, actions: [CoreUIAction]) {
        self.id = id
        self.kind = kind
        self.payload = payload
        self.actions = actions
    }
}

public struct CoreUIDocumentUI: Sendable {
    public let layout: CoreUILayout
    public let views: [CoreUIViewItem]
    public let actions: [CoreUIAction]

    public init(layout: CoreUILayout, views: [CoreUIViewItem], actions: [CoreUIAction]) {
        self.layout = layout
        self.views = views
        self.actions = actions
    }
}

public struct CoreUIDocument: Sendable {
    public let schemaVersion: String
    public let message: String
    public let ui: CoreUIDocumentUI?

    public init(schemaVersion: String, message: String, ui: CoreUIDocumentUI?) {
        self.schemaVersion = schemaVersion
        self.message = message
        self.ui = ui
    }
}
